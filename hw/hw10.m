% - RTst에서, 시작점과 끝점까지 다 이어진 contour를 그리도록 수정
% - GTV 사용, 3*3 tildelayout 사용

clear all;
close all;
clc;

% folder, files (RTst)
patientDataFolder = fullfile(pwd, 'data', 'patient-example');
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTst_')
        RTStFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

files = dir(fullfile(RTStFolder, '*.dcm'));
RTStFile = fullfile(files(1).folder, files(1).name);


% RT Structure
rtst_info = dicominfo(RTStFile, 'UseVRHeuristic', false);   % 'UseVRHeuristic', false : 없으면 오류
contour = dicomContours(rtst_info);

ROIs = contour.ROIs;
name = ROIs.Name;
contourData = ROIs.ContourData;
color = ROIs.Color;

nROIs = size(ROIs, 1);

% selected ROI
ROIname_selected = 'GTV';

for st = 1:nROIs
    if strcmp(name{st, 1}, ROIname_selected)
        index = st;
    end
end

% contour (for selected ROI)
contourData_selected = contourData{index};
color_selected = color{index};

nSlice = size(contourData_selected, 1);

%% hw 10 %%
% plot (all slices)
fig = figure('color', 'w');
set(fig, 'units', 'inches');
set(fig, 'outerPosition', [1,1,7,7]);

tiledlayout(fig,3,3, 'tileSpacing', 'compact', 'padding', 'compact');

for ss = 1:nSlice
    contourData_slice = contourData_selected{ss, 1};

    contourData_slice(end+1, :) = contourData_slice(1,:); % 양 끝 잇기 (1 - end)
    
    x = contourData_slice(:, 1);
    y = contourData_slice(:, 2);
    z = contourData_slice(:, 3);

    nexttile;
    plot(x, y, 'color', 'b', 'linewidth', 1.5);
    axis([30 60 0 30]);
    title(sprintf('z = %.1f', z(1)), 'FontSize', 12)
end