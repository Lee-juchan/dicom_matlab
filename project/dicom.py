import os
import numpy as np
import pydicom
from dataclasses import dataclass


''' type : SpatialInfo '''
@dataclass
class SpatialInfo:

    PatientPositions: list
    PixelSpacings: list
    ImageSize: list

    def __len__(self):
        return len(self.__list__())

    def __list__(self):
        return [self.PatientPositions, self.PixelSpacings, self.ImageSize]

    def __getitem__(self, key):
        if isinstance(key, int):  # key==int
            return [self.PatientPositions, self.PixelSpacings, self.ImageSize][key]
        elif isinstance(key, str):  # key==str
            return getattr(self, key, KeyError(f"{key} is not a valid key"))
        else:
            raise TypeError("Key must be an integer or string")


''' 
    - dicomreadVolume (for python)

    input :     folder_path (e.g. CT folder)
    output :    image   [x, y, N]
                spatial - PatientPositions [N, 3]
                        - PixelSpacings [N, 2]
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
    ImageSize = np.zeros(3, dtype=np.int16)


    ''' CT meta '''
    info_tmp = pydicom.dcmread(file_list[0])

    # size
    ImageSize[0] = info_tmp.Rows
    ImageSize[1] = info_tmp.Columns
    ImageSize[2] = N


    ''' CT img '''
    info = None
    image = np.zeros(ImageSize)

    for i, file in enumerate(file_list):
        info = pydicom.dcmread(file)

        # origin, spacing
        PatientPositions[i, :] = info.ImagePositionPatient
        PixelSpacings[i, :] = info.PixelSpacing

        # img
        image[:, :, i] = info.pixel_array


    ''' processing '''
    # sorting (by z)
    idx_sorted = np.argsort(PatientPositions[:, 2])

    PatientPositions = PatientPositions[idx_sorted]
    PixelSpacings = PixelSpacings[idx_sorted]
    image = image[:, :, idx_sorted]

    spatial = SpatialInfo(PatientPositions, PixelSpacings, ImageSize)

    return [image, spatial]