% 모든 cp마다 MLC shape를 plot하는 코드

% cp1   : bldPositionSequence, Item 3개 (x-jaw, y-jaw, MLC)
% cp2~  : bldPositionSequence, Item 3개 (y-jaw, MLC)
%
% if 문 or RTBeamLimitingDeviceType 참조 (hard 코딩 하지 않도록)

% cla, pause() 활용


clear all;
close all;
clc;


workingFolder = 'C:\Users\DESKTOP\workspace\DICOM_matlab';
patientDataFolder = strcat(workingFolder, '\data', '\patient-example');

% get RT Plan Folder from patient folder
folders = dir(sprintf('%s\\', patientDataFolder));

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTPLAN_')
        RTPLANFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);
    end
end

files = dir(sprintf('%s\\*.dcm', RTPLANFolder));
RTPLANFile = sprintf('%s\\%s', files(1).folder, files(1).name);


% reading RT Plan
rtplan_info = dicominfo(RTPLANFile);

beamSequence = rtplan_info.BeamSequence;
fieldnames_beamSequence = fieldnames(beamSequence); % beam의 수 만큼 나옴
nBeams = size(fieldnames_beamSequence, 1);

%%
% plot MLC
fig = figure('color', 'w');
set(fig, 'units', 'inches');
set(fig, 'outerPosition', [1,1,9,9]);
axis equal;
axis([-200, 200 ,-200, 200]);

%%
for bb = 1%:nBeams % -> for 1st beam
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb});
    beamname = item_beamSequence.BeamName;

    ncontrolpoints = item_beamSequence.NumberOfControlPoints;
    controlPointSequence = item_beamSequence.ControlPointSequence;
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);

    for cp = 1:ncontrolpoints
        
        item_controlPointSequence = controlPointSequence.(fieldnames_controlpointsequence{cp});
        bldPositionSequence = item_controlPointSequence.BeamLimitingDevicePositionSequence;
        
        fieldnames_bldPositionSequence = fieldnames(bldPositionSequence);
        
        % y-jaw positions
        bldPositionSequence1 = bldPositionSequence.(fieldnames_bldPositionSequence{end-1});
        YjawPositions = bldPositionSequence1.LeafJawPositions;
        
        % MLC positions
        bldPositionSequence2 = bldPositionSequence.(fieldnames_bldPositionSequence{end});
        MLCPositions = bldPositionSequence2.LeafJawPositions;
        
        MLCPositions_left = MLCPositions(1:80, 1);
        MLCPositions_right = MLCPositions(81:160, 1);
        
        %%
        cla; % clear image

        % plot y-jaw
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

        % plot mlc
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
        
        pause(0.1);
    end
end