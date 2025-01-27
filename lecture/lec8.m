% 🌟 강의 목표:
% 1. 숙제7 해설 (이중 for문으로 matrix 만들기),
% 2. DICOM RT plan 파일로부터 Y-jaw and MLC positions 구하기

% 🌟 Learning objectives: 
% 1. Solution to HW7: create a two-dimensional matrix using for statements,
% 2. Obtain Y-jaw and MLC positions from DICOM RT plan file.


clear all;
close all;
clc;

%%
patientDataFolder = fullfile(pwd, 'data', 'patient-example');

% get RT Plan Folder from patient folder
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTPLAN_')
        RTPLANFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

files = dir(fullfile(RTPLANFolder, '*.dcm'));
RTPLANFile = fullfile(files(1).folder, files(1).name);


% reading RT Plan
rtplan_info = dicominfo(RTPLANFile);

beamSequence = rtplan_info.BeamSequence;
fieldnames_beamSequence = fieldnames(beamSequence); % beam의 수 만큼 나옴
nBeams = size(fieldnames_beamSequence, 1);

for bb = 1%:nBeams % -> for 1st beam
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb});

    beamname = item_beamSequence.BeamName;
    fprintf('Beam: %s\n', beamname);

    ncontrolpoints = item_beamSequence.NumberOfControlPoints;
    fprintf('\tNumber of control points: %d\n', ncontrolpoints);

    controlPointSequence = item_beamSequence.ControlPointSequence;
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);

    % Elekta VersaHD plan
    %
    % BeamLimitingDevicePositionSequence -> 3 items:
    %   - Item_1: x-jaw
    %   - Item_2: y-jaw
    %   - Item_3: MLC       (min gap=2.5mm, left=1~80, right=81~160)

    for cp = 1%:ncontrolpoints % for 1st cp
        item_controlPointSequence = controlPointSequence.(fieldnames_controlpointsequence{cp});
        
        bldPositionSequence = item_controlPointSequence.BeamLimitingDevicePositionSequence;

        % y-jaw positions
        item2_bldPositionSequence = bldPositionSequence.Item_2;
        YjawPositions = item2_bldPositionSequence.LeafJawPositions;
        
        % MLC positions
        item3_bldPositionSequence = bldPositionSequence.Item_3;
        MLCPositions = item3_bldPositionSequence.LeafJawPositions;

        MLCPositions_left = MLCPositions(1:80, 1);
        MLCPositions_right = MLCPositions(81:160, 1);

        % MLC 면적 구하기 (Y-jaw 고려 x)
        % method1 : 누적합
        MLCOpeningArea1 = 0;
        for mlc = 1:80
            MLCOpeningWidth = MLCPositions_right(mlc, 1) - MLCPositions_left(mlc, 1);
            MLCOpeningArea1 = MLCOpeningArea1 + MLCOpeningWidth*5;
        end
        disp(MLCOpeningArea1);

        % method2 : 벡터합
        MLCOpeningWidth = MLCPositions_right - MLCPositions_left;
        MLCOpeningArea2 = sum(MLCOpeningWidth*5);
        disp(MLCOpeningArea2);

    end
end

