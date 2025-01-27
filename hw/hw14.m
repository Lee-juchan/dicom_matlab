% - DVH에서, GTV, ITV, PTV의 정보 계산 (volume, D99, D98, D95)
%
% -> volume = volume of 1 voxel (unit volume) * voxel 수
% -> D99, D98, D95 = interp1() 사용

clear all;
close all;
clc;

patientDataFolder = fullfile(pwd, 'data', 'patient-example');


% get CT, RT Structure, RT Plan, RT Dose Folder from patient folder
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_CT_')
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);     % CT
    elseif contains(folders(ff).name, '_RTst')
        RTStFolder = fullfile(folders(ff).folder, folders(ff).name);   % RT structure
    elseif contains(folders(ff).name, '_RTPLAN_')
        RTPlanFolder = fullfile(folders(ff).folder, folders(ff).name);   % RT plan
    elseif contains(folders(ff).name, '_RTDOSE_')
        RTDoseFolder = fullfile(folders(ff).folder, folders(ff).name);   % RT Dose
    end
end

if exist(RTStFolder, 'dir')
    files_rtdose = dir(fullfile(RTStFolder, '*.dcm'));
end
RTStFile = fullfile(files_rtdose(1).folder, files_rtdose(1).name);

if exist(RTPlanFolder, 'dir')
    files_rtplan = dir(fullfile(RTPlanFolder, '*.dcm'));
end
RTPlanFile = fullfile(files_rtplan(1).folder, files_rtplan(1).name);

if exist(RTDoseFolder, 'dir')
    files_rtdose = dir(fullfile(RTDoseFolder, '*.dcm'));
end
RTDoseFile = fullfile(files_rtdose(1).folder, files_rtdose(1).name);


% CT
[image, spatial, dim] = dicomreadVolume(CTFolder);

image = squeeze(image);
image = image - 3614; % raw value -> CT number

image_origin = spatial.PatientPositions(1,:);
image_spacing = spatial.PixelSpacings(1,:);
image_spacing(3) = spatial.PatientPositions(2,3) - spatial.PatientPositions(1,3);
image_size = spatial.ImageSize;

x_image = zeros(image_size(1), 1);
y_image = zeros(image_size(2), 1);
z_image = zeros(image_size(3), 1);

for ii = 1:image_size(1)
    x_image(ii) = image_origin(1) + image_spacing(1)*(ii-1);
end
for jj = 1:image_size(2)
    y_image(jj) = image_origin(2) + image_spacing(2)*(jj-1);
end
for kk = 1:image_size(3)
    z_image(kk) = image_origin(3) + image_spacing(3)*(kk-1);
end


% RT Structure
rtst_info = dicominfo(RTStFile, 'UseVRHeuristic', false);   % 'UseVRHeuristic', false : 없으면 오류
contour = dicomContours(rtst_info);
ROIs = contour.ROIs;

name = ROIs.Name;
contourData = ROIs.ContourData; % 각 slice 수
color = ROIs.Color;

nRTStructure = size(ROIs, 1);

% selected ROI
ROIname_selected = {'GTV'; 'ITV'; 'PTV 1250x4 Dmax~'};
nROIs_selected = size(ROIname_selected, 1);

index = zeros(nROIs_selected, 1);

for roi = 1:nROIs_selected
    for st = 1:nRTStructure
        if strcmp(name{st, 1}, ROIname_selected{roi,1})
            index(roi, 1) = st;
        end
    end
end

% contour (for selected ROI)
roiData = struct([]);

for roi = 1:nROIs_selected
    contourData_selected = contourData{index(roi, 1)};
    color_selected = color{index(roi, 1)};

    z_roi = [];
    nSlice = size(contourData_selected, 1);

    for ss = 1:nSlice
        contourData_slice = contourData_selected{ss, 1};
        z_slice = contourData_slice(:, 3);
        z_roi = [z_roi; z_slice];
    end
    z_roi = unique(z_roi);

    roiData(roi).ContourData = contourData_selected;
    roiData(roi).Color = color_selected;
    roiData(roi).z_roi = z_roi;
end


% RT dose
rtdose_info = dicominfo(RTDoseFile);

rtdose_data = dicomread(rtdose_info);
rtdose_data = squeeze(rtdose_data);

rtdose_gridscaling = rtdose_info.DoseGridScaling;
rtdose = rtdose_gridscaling * double(rtdose_data); % for real dose

rtdose_origin = rtdose_info.ImagePositionPatient;
rtdose_spacing(1:2) = rtdose_info.PixelSpacing;
rtdose_spacing(3) = rtdose_info.SliceThickness;
rtdose_size = size(rtdose_data);

x_rtdose = zeros(rtdose_size(2), 1);
y_rtdose = zeros(rtdose_size(1), 1);
z_rtdose = zeros(rtdose_size(3), 1);

for ii = 1:rtdose_size(2)
    x_rtdose(ii) = rtdose_origin(1) + rtdose_spacing(1)*(ii-1);
end
for jj = 1:rtdose_size(1)
    y_rtdose(jj) = rtdose_origin(2) + rtdose_spacing(2)*(jj-1);
end
for kk = 1:rtdose_size(3)
    z_rtdose(kk) = rtdose_origin(3) + rtdose_spacing(3)*(kk-1);
end


% DVH
[X_rtdose, Y_rtdose, Z_rtdose] = meshgrid(x_rtdose, y_rtdose, z_rtdose);    % dose grid

for roi = 1:nROIs_selected
    [mask, x_mask, y_mask, z_mask] = createMaskJK(contour, index(roi,1));
    [X_mask, Y_mask, Z_mask] = meshgrid(x_mask, y_mask, z_mask);            % mask grid
    
    % dvh
    rtdose_mask_interp = interp3(X_rtdose,Y_rtdose,Z_rtdose, rtdose, X_mask,Y_mask,Z_mask); % 영역 맞추기
    rtdose_masked = rtdose_mask_interp(mask == 1);
    rtdose_dvh = sort(rtdose_masked, 'descend');
    
    % volume (acc)
    acc_percent_volume = (1:size(rtdose_dvh,1))';
    acc_percent_volume = acc_percent_volume / size(rtdose_dvh, 1) * 100;
    
    % unit volume (cc)
    unit_volume = 1^3/1000;   % mm3 -> cc(cm3)

    %% hw 14 %%
    % volume
    volume = unit_volume * size(rtdose_dvh, 1);

    % Dose of N Volumne
    d99 = interp1(acc_percent_volume, rtdose_dvh, 99);
    d98 = interp1(acc_percent_volume, rtdose_dvh, 98);
    d95 = interp1(acc_percent_volume, rtdose_dvh, 95);

    fprintf('ROI = %s\n', ROIname_selected{roi});
    fprintf('\tVolumne : %.3f cc\n', volume);
    fprintf('\tD99 : %.3f Gy\n', d99);
    fprintf('\tD98 : %.3f Gy\n', d98);
    fprintf('\tD95 : %.3f Gy\n', d95);
    %%
end
