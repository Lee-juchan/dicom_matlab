% 🌟 강의 목표:
% 1. 숙제9 해설: 모든 control point마다 MLC shape을 plot하는 코드 작성하기,
% 2. DICOM RT structure 파일 읽기, contour plot하기

% 🌟 주요 MATLAB 함수:
% 1. dicomContours() -> 모든 slice의 contour을 한번에
% 2. plot(x,y, marker) : 'color', 'linewidth'
%    axis([xmin xmax ymin ymax])


% rtst_info
% rtst_info = dicominfo(RTStFile, 'UseVRHeuristic', false);   % 'UseVRHeuristic', false : 없으면 오류

% rtst_info.StructureSetROISequence; % 18개 -> contour 수
% rtst_info.StructureSetROISequence.Item_1; % RT structure 번호, 이름만

% rtst_info.ROIContourSequence; % 18개 (RT structure별 = 장기별)
% rtst_info.ROIContourSequence.Item_1; % color, contour
% rtst_info.ROIContourSequence.Item_1.ContourSequence; % 9개 (slice별)
% rtst_info.ROIContourSequence.Item_1.ContourSequence.Item_1; % contour point 75 (포함된 포인트)
% rtst_info.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourData; % x y z 반복 (z 동일) 75*3 = 255

% RT structure (contour)는 어떤 형태로 저장?
% -> point set (각 axial slice에 정의된 3d 좌표)


clear all;
close all;
clc;


patientDataFolder = fullfile(pwd, 'data', 'patient-example');

%%
% get RT structure Folder from patient folder
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTst_')
        RTStFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

files = dir(fullfile(RTStFolder, '*.dcm'));
RTStFile = fullfile(files(1).folder, files(1).name);


% reading RT Structure
rtst_info = dicominfo(RTStFile, 'UseVRHeuristic', false);   % 'UseVRHeuristic', false : 없으면 오류
contour = dicomContours(rtst_info);
ROIs = contour.ROIs;

number = ROIs.Number;
name = ROIs.Name;
contourData = ROIs.ContourData; % 각 slice 수
geometricType = ROIs.GeometricType;
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

% plot contour for all slices
nSlice = size(contourData_selected, 1);

for ss = 1:nSlice
    contourData_slice = contourData_selected{ss, 1};

    x = contourData_slice(:, 1);
    y = contourData_slice(:, 2);
    z = contourData_slice(:, 3);

    figure('color', 'w');
    plot(x, y, 'color', 'b', 'linewidth', 1.5);
    axis([30 60 0 30]);
end