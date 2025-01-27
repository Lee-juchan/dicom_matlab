% GTV, ITV, PTV에 대해, 아래 정보를 계산하는 코드
%   Volumne, D99, D98, D95
%
%   volume = mask voxel 하나의 볼륨 * voxel 수
%   D99,,D95는 interp1 함수를 이용



clear all;
close all;
clc;

workingFolder = 'C:\Users\DESKTOP\workspace\DICOM_matlab';
patientDataFolder = strcat(workingFolder, '\data', '\patient-example');


% get CT, RT Structure, RT Plan, RT Dose Folder from patient folder
folders = dir(sprintf('%s\\', patientDataFolder));

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_CT_')
        CTFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);     % CT
    elseif contains(folders(ff).name, '_RTst')
        RTStFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);   % RT structure
    elseif contains(folders(ff).name, '_RTPLAN_')
        RTPlanFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);   % RT plan
    elseif contains(folders(ff).name, '_RTDOSE_')
        RTDoseFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);   % RT Dose
    end
end

if exist(RTStFolder, 'dir')
    files_rtdose = dir(sprintf('%s\\*.dcm', RTStFolder));
end
RTStFile = fullfile(files_rtdose(1).folder, files_rtdose(1).name);

if exist(RTPlanFolder, 'dir')
    files_rtplan = dir(sprintf('%s\\*.dcm', RTPlanFolder));
end
RTPlanFile = fullfile(files_rtplan(1).folder, files_rtplan(1).name);

if exist(RTDoseFolder, 'dir')
    files_rtdose = dir(sprintf('%s\\*.dcm', RTDoseFolder));
end
RTDoseFile = fullfile(files_rtdose(1).folder, files_rtdose(1).name);


% reading CT (3d volumne)
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


% reading RT Structure
rtst_info = dicominfo(RTStFile, 'UseVRHeuristic', false);   % 'UseVRHeuristic', false : 없으면 오류
contour = dicomContours(rtst_info);
ROIs = contour.ROIs;

name = ROIs.Name;
contourData = ROIs.ContourData; % 각 slice 수
color = ROIs.Color;

nRTStructure = size(ROIs, 1);

% get index for selected RT structure
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

% get contour data and color for selecte RT structure
roiData = struct([]);

for roi = 1:nROIs_selected
    contourData_selected = contourData{index(roi, 1)};
    color_selected = color{index(roi, 1)};

    z_roi = []; % ROI 마다 slice가 몇개 나올지 아직 모름
    nSlice = size(contourData_selected, 1);

    for ss = 1:nSlice
        contourData_slice = contourData_selected{ss, 1};
        z_slice = contourData_slice(:, 3);
        z_roi = [z_roi; z_slice];
    end
    z_roi = unique(z_roi); % 원하는 contour(ROI)의 slice 개수만큼의 z좌표

    roiData(roi).ContourData = contourData_selected;
    roiData(roi).Color = color_selected;
    roiData(roi).z_roi = z_roi;
end


% reading RT dose
rtdose_info = dicominfo(RTDoseFile);

rtdose_data = dicomread(rtdose_info);
rtdose_data = squeeze(rtdose_data);

rtdose_origin = rtdose_info.ImagePositionPatient; % CT image와 상당히 유사
rtdose_spacing(1:2) = rtdose_info.PixelSpacing;
rtdose_spacing(3) = rtdose_info.SliceThickness;
rtdose_size = size(rtdose_data);

% to convert raw data -> dose
rtdose_gridscaling = rtdose_info.DoseGridScaling;
rtdose = rtdose_gridscaling * double(rtdose_data);

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


% generate mask image and plot DVH curves
fig = figure('color', 'k');                             % fig=black
set(gcf, 'units', 'inches');
set(gcf, 'outerPosition', [1,1,10,9]);
set(gcf, 'defaultAxesLooseInset', [0.05,0.1,0.03,0.03]);
set(gca, 'color', 'k', 'xColor', 'w', 'yColor', 'w');   % axes=black, ticks=white
box on;     % 모든 코너에 축이 그려짐 (like box) JHK reccomend
hold on;


[xxx_rtdose, yyy_rtdose, zzz_rtdose] = meshgrid(x_rtdose, y_rtdose, z_rtdose); % 3d grid 생성

for roi = 1:nROIs_selected
    % create mask image for each RT structure
    [mask, x_mask, y_mask, z_mask] = createMaskJK(contour, index(roi,1));
    [xxx_mask, yyy_mask, zzz_mask] = meshgrid(x_mask, y_mask, z_mask);
    
    rtdose_mask_interp = interp3(xxx_rtdose, yyy_rtdose, zzz_rtdose, rtdose, xxx_mask, yyy_mask, zzz_mask); % mask, RT dose의 영역이 다름 -> rtdose를 mask 영역에 interp
    rtdose_mask_only = rtdose_mask_interp(mask == 1); % mask에 해당하는 rtdose 추출

    % create DVH curves
    rtdose_dvh = sort(rtdose_mask_only, 'descend');

    % volume of unit voxel
    unit_voxel_volume = 1^3/1000;   % mask image spacing: 1mm, converted mm3 to cc

    % accumulated volume (%）
    acc_percent_volume = (1:size(rtdose_dvh,1))';
    acc_percent_volume = acc_percent_volume / size(rtdose_dvh, 1) * 100;

    % contour data - color
    color_selected = roiData(roi).Color;

    plot(rtdose_dvh, acc_percent_volume, 'color', color_selected/256, 'LineWidth', 2.0);

    %%
    % volume
    volume = unit_voxel_volume * size(rtdose_dvh, 1);

    % Dose of N Volumne
    d99 = interp1(acc_percent_volume, rtdose_dvh, 99);
    d98 = interp1(acc_percent_volume, rtdose_dvh, 98);
    d95 = interp1(acc_percent_volume, rtdose_dvh, 95);

    fprintf('ROI = %s\n', ROIname_selected{roi});
    fprintf('\tVolumne : %.3f cc\n', volume);
    fprintf('\tD99 : %.3f Gy\n', d99);
    fprintf('\tD98 : %.3f Gy\n', d98);
    fprintf('\tD95 : %.3f Gy\n', d95);

end
xlabel('Dose (Gy)', 'FontSize', 14);
ylabel('Volumne (%)', 'FontSize', 14);
legend(ROIname_selected, 'Location', 'eastoutside', 'Color', 'k', 'TextColor', 'w', 'FontSize', 14, 'Box', 'off');

