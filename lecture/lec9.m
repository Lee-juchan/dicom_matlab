% 🌟 강의 목표:
% 1. 숙제8 해설: MLC aperture 면적 구하기
% 2. DICOM RT plan 파일: MLC visualization

% 🌟 주요 MATLAB 함수:
% 1. rectangle('Position', [x y w h])
%%

% Y-jaw
% lower jaw
% x = -200
% y = -200
% w = 400
% h = YjawPositions(1) - y

% upper jaw
% x = -200
% y = YjawPositions(2)
% w = 400
% h = 200 - y

% MLC
% left n-leaf
% x = -200
% y = -200 + 5*(n-1)
% w = MLCPositions_left(n,1) - x
% h = 5

% right n-leaf
% x = MLCPositions_right(n,1)
% y = -200 + 5*(n-1)
% w = 200 - x
% h = 5

clear all;
close all;
clc;

% folder, files (RTPLAN)
patientDataFolder = fullfile(pwd, 'data', 'patient-example');
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTPLAN_')
        RTPLANFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

files = dir(fullfile(RTPLANFolder, '*.dcm'));
RTPLANFile = fullfile(files(1).folder, files(1).name);

% RT plan
rtplan_info = dicominfo(RTPLANFile);

beamSequence = rtplan_info.BeamSequence; % beams
fieldnames_beamSequence = fieldnames(beamSequence);
nBeams = size(fieldnames_beamSequence, 1);

%% lec 9 %%
% plot MLC
fig = figure('color', 'w');
set(fig, 'units', 'inches');
set(fig, 'outerPosition', [1,1,9,9]);
axis equal;
axis([-200, 200 ,-200, 200]);

%%
for bb = 1%:nBeams % -> for 1st beam
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb}); % beam

    controlPointSequence = item_beamSequence.ControlPointSequence; % cps
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);
    
    ncontrolpoints = item_beamSequence.NumberOfControlPoints;

    for cp = 1%:ncontrolpoints % for 1st cp
        item_controlPointSequence = controlPointSequence.(fieldnames_controlpointsequence{cp}); % cp
        
        bldPositionSequence = item_controlPointSequence.BeamLimitingDevicePositionSequence; % blds

        % y-jaw positions
        Yjaw = bldPositionSequence.Item_2;
        YjawPositions = Yjaw.LeafJawPositions;

        %% lec 9 %%
        % lower jaw
        x_jaw_low = -200;
        y_jaw_low = -200;
        w_jaw_low = 400;
        h_jaw_low = YjawPositions(1,1) - y_jaw_low;
        rectangle('position', [x_jaw_low, y_jaw_low, w_jaw_low, h_jaw_low], 'faceColor', [0.5, 0.5, 0.5]);
        
        % upper jaw
        x_jaw_up = -200;
        y_jaw_up = YjawPositions(2,1);
        w_jaw_up = 400;
        h_jaw_up = 200 - y_jaw_up;
        rectangle('position', [x_jaw_up, y_jaw_up, w_jaw_up, h_jaw_up], 'faceColor', [0.5, 0.5, 0.5]);
        %%

        % MLC positions
        MLC = bldPositionSequence.Item_3;
        MLCPositions = MLC.LeafJawPositions;

        MLCPositions_left = MLCPositions(1:80, 1);
        MLCPositions_right = MLCPositions(81:160, 1);

        %% lec 9 %%
        for mlc = 1:80
            % left n-leaf
            x_mlc_left = -200;
            y_mlc_left = -200 + 5*(mlc-1);
            w_mlc_left = MLCPositions_left(mlc,1) - x_mlc_left;
            h_mlc_left = 5;
            rectangle('position', [x_mlc_left, y_mlc_left, w_mlc_left, h_mlc_left]);

            % right n-leaf
            x_mlc_right = MLCPositions_right(mlc,1);
            y_mlc_right = -200 + 5*(mlc-1);
            w_mlc_right = 200 - x_mlc_right;
            h_mlc_right = 5;
            rectangle('position', [x_mlc_right, y_mlc_right, w_mlc_right, h_mlc_right]);
        end
    end
end