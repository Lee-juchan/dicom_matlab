% 시작점과 끝점까지 다 이어진 contour를 그리도록 코드 수정
% GTV의 9 slice에서의 contour를 3*3 tildelayout의 각 tile에 그리는 코드를 작성


clear all;
close all;
clc;


workingFolder = 'C:\Users\DESKTOP\workspace\DICOM_matlab';
patientDataFolder = strcat(workingFolder, '\data', '\patient-example');

% get RT structure Folder from patient folder
folders = dir(sprintf('%s\\', patientDataFolder));

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTst_')
        RTStFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);
    end
end

files = dir(sprintf('%s\\*.dcm', RTStFolder));
RTStFile = sprintf('%s\\%s', files(1).folder, files(1).name);


% reading RT Structure
rtst_info = dicominfo(RTStFile, 'UseVRHeuristic', false);   % 'UseVRHeuristic', false : 없으면 오류
contour = dicomContours(rtst_info);
ROIs = contour.ROIs;

name = ROIs.Name;
contourData = ROIs.ContourData; % 각 slice 수
color = ROIs.Color;

nRTStructure = size(ROIs, 1);

% get index for selected RT structure
ROIname_selected = 'GTV';

for st = 1:nRTStructure
    if strcmp(name{st, 1}, ROIname_selected)
        index = st;
    end
end

% get contour data and color for selecte RT structure
contourData_selected = contourData{index};
color_selected = color{index};

nSlice = size(contourData_selected, 1);

%%
% plot contour for all slices
fig = figure('color', 'w');
set(fig, 'units', 'inches');
set(fig, 'outerPosition', [1,1,7,7]);

tiledlayout(fig,3,3, 'tileSpacing', 'compact', 'padding', 'compact');

for ss = 1:nSlice
    contourData_slice = contourData_selected{ss, 1};

    if ~isequal(contourData_slice(1,:), contourData_slice(end,:)) % 양 끝 잇기 (1 - end)
        contourData_slice(end+1, :) = contourData_slice(1,:);
    end

    x = contourData_slice(:, 1);
    y = contourData_slice(:, 2);
    z = contourData_slice(:, 3);

    nexttile;
    plot(x, y, 'color', 'b', 'linewidth', 1.5);
    axis([30 60 0 30]);
    title(sprintf('z = %.1f', z(1)), 'FontSize', 12)
end
