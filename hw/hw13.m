% Mask image에 contour를 overlay하는 코드 작성
% GTV, ITV, PTV중 하나


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


%%
% loop 1 : ROI 선택

% loop 2 : ROI의 slice(z) 선택
%           contour 그리기
%           mask 그리기 (ROI에 해당하는 index(roi,1) 찾아서 마스크 만들기)


for roi = 1:nROIs_selected

    % fig
    fig = figure('color', 'w');
    set(gcf, 'units', 'inches');
    set(gcf, 'outerPosition', [1,1,10,9]);
    set(gcf, 'defaultAxesLooseInset', [0.05,0.1,0.03,0.03]);

    tiledlayout(fig,5,5, 'tileSpacing', 'compact', 'padding', 'compact');

    
    % ROI별
    contourData_selected = roiData(roi).ContourData; % contour
    color_selected = roiData(roi).Color;
    z_roi = roiData(roi).z_roi;

    [mask, x_mask, y_mask, z_mask] = createMaskJK(contour, index(roi,1)); % mask


    % slice별 mask, contour
    for zz = min(z_roi):max(z_roi)

        % plot mask
        z_index = find(z_mask == zz); % 전체 CT의 z좌표 == 현 slice의 z좌표

        nexttile;
        hold on;
        imagesc(x_mask, y_mask, mask(:,:,z_index));
        colormap('gray');
        set(gca, 'YDir', 'reverse')
        axis equal
        axis([20 70 -10 40]);
        title(sprintf('z = %.1f', zz), 'FontSize', 12);


        % plot contour
        z_roi_index = find(z_roi == zz);

        contourData_slice = contourData_selected{z_roi_index};
        contourData_slice(end+1, :) = contourData_slice(1,:);
        x = contourData_slice(:, 1);
        y = contourData_slice(:, 2);
        
        plot(x, y, 'color', color_selected/255, 'linewidth', 2.0); % contour
        hold off;
    end

    % ROI별 figure 제목
    sgtitle(sprintf('ROI = %s', ROIname_selected{roi}), 'FontSize', 16, 'FontWeight', 'bold');
end