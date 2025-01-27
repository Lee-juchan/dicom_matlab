% 🌟 강의 목표:
% 1. 숙제7 해설 (이중 for문으로 matrix 만들기),
% 2. DICOM RT plan 파일로부터 Y-jaw and MLC positions 구하기

% 🌟 Learning objectives: 
% 1. Solution to HW7: create a two-dimensional matrix using for statements,
% 2. Obtain Y-jaw and MLC positions from DICOM RT plan file.
%%

% Elekta VersaHD plan
%
% BeamLimitingDevicePositionSequence -> 3 items:
%   - Item_1: x-jaw
%   - Item_2: y-jaw
%   - Item_3: MLC       (min gap=2.5mm, left=1~80, right=81~160)

clear all;
close all;
clc;

% folder, file (RTPLAN)
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

for bb = 1%:nBeams
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb}); % beam

    controlPointSequence = item_beamSequence.ControlPointSequence; % cps
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);
    
    ncontrolpoints = item_beamSequence.NumberOfControlPoints;

    %% lec 8 %%
    for cp = 1%:ncontrolpoints
        item_controlPointSequence = controlPointSequence.(fieldnames_controlpointsequence{cp}); % cp
        
        bldPositionSequence = item_controlPointSequence.BeamLimitingDevicePositionSequence; % blds

        % y-jaw positions
        Yjaw = bldPositionSequence.Item_2;
        YjawPositions = Yjaw.LeafJawPositions;
        
        % MLC positions
        MLC = bldPositionSequence.Item_3;
        MLCPositions = MLC.LeafJawPositions;

        MLCPositions_left = MLCPositions(1:80, 1);
        MLCPositions_right = MLCPositions(81:160, 1);

        % MLC 면적 구하기 (Y-jaw 고려 x)
        % 1. 누적합
        MLCOpeningArea1 = 0;
        for mlc = 1:80
            MLCOpeningWidth = MLCPositions_right(mlc, 1) - MLCPositions_left(mlc, 1);
            MLCOpeningArea1 = MLCOpeningArea1 + 5*MLCOpeningWidth;
        end
        fprintf('MLC opening area1 : %s\n', MLCOpeningArea1);

        % 2. 벡터합
        MLCOpeningWidth = MLCPositions_right - MLCPositions_left;
        MLCOpeningArea2 = sum(5*MLCOpeningWidth);
        fprintf('MLC opening area2 : %s\n', MLCOpeningArea2);
    end
end

