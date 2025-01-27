% 🌟 강의 목표:
% 1.  숙제 5 해설: plot axial/sagittal/coronal images in a single figure,
% 2. DICOM RT plan 파일 열기, RT plan parameter 가져오기

% 🌟 주요 MATLAB 함수
% 1. dicominfo()
% 2. fieldnames()

% test : fieldnames(rtplan_info)
% rtplan_info.DoseReferenceSequence.Item_1    % prescription dose 등 확인 가능
% rtplan_info.FractionGroupSequence.Item_1    % fx 수, beam 수 확인 가능
% rtplan_info.BeamSequence.Item_1             % cp 수
% rtplan_info.BeamSequence.Item_1.ControlPointSequence.Item_1     % 공통정보 + 1정보 (CumulativeMetersetWeight = 0)
% rtplan_info.BeamSequence.Item_1.ControlPointSequence.Item_2     % 2정보
% rtplan_info.BeamSequence.Item_1.ControlPointSequence.Item_180   % (CumulativeMetersetWeight = 1)

% % MLC - Y-jaw : 서로 수직방향
% rtplan_info.BeamSequence.Item_1.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions    % X-jaw position : [-200, 200] 없음
% rtplan_info.BeamSequence.Item_1.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions    % Y-jaw Position : [-15, 20]
% rtplan_info.BeamSequence.Item_1.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_3.LeafJawPositions    % MLC position   : ...


clear all;
close all;
clc;

%%
% get RT Plan Folder from patient folder
patientDataFolder = fullfile(pwd, 'data', 'patient-example');

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

for bb = 1:size(fieldnames_beamSequence, 1)
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb});

    beamname = item_beamSequence.BeamName;
    fprintf('Beam: %s\n', beamname);

    ncontrolpoints = item_beamSequence.NumberOfControlPoints;
    fprintf('\tNumber of control points: %d\n', ncontrolpoints);

    controlPointSequence = item_beamSequence.ControlPointSequence;
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);

    fprintf('\tCumulative meterset: \n');
    for cp = 1:ncontrolpoints
        item_controlPointSequence = controlPointSequence.(fieldnames_controlpointsequence{cp});
        
        cumulativeMetersetWeight = item_controlPointSequence.CumulativeMetersetWeight;
        fprintf('\t\t#%d: %f\n', cp, cumulativeMetersetWeight);
    end
end

