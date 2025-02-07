import os
import numpy as np
import pydicom
from dataclasses import dataclass


''' type : SpatialInfo '''
@dataclass
class SpatialInfo:

    PatientPositions: list
    PixelSpacings: list
    PatientOrientations : list
    ImageSize: list

    def __len__(self):
        return len(self.__list__())

    def __list__(self):
        return [self.PatientPositions, self.PixelSpacings, self.PatientOrientations, self.ImageSize]

    def __getitem__(self, key):
        if isinstance(key, int):  # key==int
            return [self.PatientPositions, self.PixelSpacings, self.PatientOrientations, self.ImageSize][key]
        elif isinstance(key, str):  # key==str
            return getattr(self, key, KeyError(f"{key} is not a valid key"))
        else:
            raise TypeError("Key must be an integer or string")


''' 
    - dicomreadVolume (for python = z y x)

    input :     folder_path (e.g. CT folder)
    output :    image   [N, y, x]
                spatial - PatientPositions [N, 3]
                        - PixelSpacings [N, 2]
                        - PatientOrientations [N, 2,3]
                        - ImageSize [3]
'''
def dcmread_volume(fp):
    file_list = []

    for file in os.listdir(fp):
        if file.endswith('.dcm'):
            file_list.append(os.path.join(fp, file))

    N = len(file_list) # num of slice

    PatientPositions = np.zeros((N, 3), dtype=np.double)
    PixelSpacings = np.zeros((N, 2), dtype=np.double)
    PatientOrientations = np.zeros((N, 2,3))
    ImageSize = np.zeros(3, dtype=np.int16)


    ''' CT meta '''
    info_tmp = pydicom.dcmread(file_list[0])

    # size (z y x)
    ImageSize[0] = N
    ImageSize[1] = info_tmp.Rows
    ImageSize[2] = info_tmp.Columns


    ''' CT img '''
    info = None
    image = np.zeros(ImageSize)

    for i, file in enumerate(file_list):
        info = pydicom.dcmread(file)

        # origin, spacing
        PatientPositions[i, :] = info.ImagePositionPatient
        PixelSpacings[i, :] = info.PixelSpacing
        PatientOrientations[i, 0,:] = info.ImageOrientationPatient[:3]
        PatientOrientations[i, 1,:] = info.ImageOrientationPatient[3:]

        # img
        image[i, :, :] = info.pixel_array


    ''' processing '''
    # sorting (by z)
    x_ori = PatientOrientations[:,0,:]
    y_ori = PatientOrientations[:,1,:]
    z_ori = np.cross(x_ori, y_ori, axis=1)

    sorting_val = np.ones(N)
    for i in range(N):
        sorting_val[i] = PatientPositions[i,:] @ z_ori[i,:]

    sorting_idx = np.argsort(sorting_val)

    PatientPositions = PatientPositions[sorting_idx]
    PixelSpacings = PixelSpacings[sorting_idx]
    PatientOrientations = PatientOrientations[sorting_idx, :,:]
    image = image[sorting_idx, :,:]

    spatial = SpatialInfo(PatientPositions, PixelSpacings, PatientOrientations, ImageSize)

    return [image, spatial]