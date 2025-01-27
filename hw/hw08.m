% - RT PLAN에서, 첫번째 arc/cp의 MLC/Jaw로 생성된 aperture의 넓이를 계산

% -> Jaw가 열려있는 leaf :
%
% YJawPositinos = [-15, 20]
%   - lower jaw 길이    = -15 - (-200) = 185     (YJawPosition(1) + 200)
%   - lower MLC 수      = 185/5 = 37            (YJawPositions(1) + 200) / 5 
%                             -> 38th부터 열림    ((YJawPositions(1) + 200) / 5) + 1 


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


% RT Plan
rtplan_info = dicominfo(RTPLANFile);

beamSequence = rtplan_info.BeamSequence; % beams
fieldnames_beamSequence = fieldnames(beamSequence);
nBeams = size(fieldnames_beamSequence, 1);

for bb = 1%:nBeams % -> for 1st beam
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb}); % beam

    beamname = item_beamSequence.BeamName;
    fprintf('Beam: %s\n', beamname);

    ncontrolpoints = item_beamSequence.NumberOfControlPoints;
    fprintf('\tNumber of control points: %d\n', ncontrolpoints);

    controlPointSequence = item_beamSequence.ControlPointSequence; % cps
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);

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

        %% hw 8 %%
        % MLC 면적 구하기 (Y-jaw 고려 o)
        MLC_top = (YjawPositions(2) + 200)/5;
        MLC_bottom = (YjawPositions(1) + 200)/5 + 1;
        
        mlc = MLC_bottom:MLC_top;
        MLCOpeningWidth = MLCPositions_right(mlc, 1) - MLCPositions_left(mlc, 1);
        MLCOpeningArea2 = sum(MLCOpeningWidth*5);
        disp(MLCOpeningArea2);

    end
end