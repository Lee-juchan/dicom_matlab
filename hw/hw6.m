% - RT Plan에서, 각 빔의 gantry angle의 range를 텍스트 파일로 출력

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


% save txt
filename = fullfile(pwd, 'data', 'hw6.txt');
fid = fopen(filename, 'w');


% RT Plan
rtplan_info = dicominfo(RTPLANFile);

beamSequence = rtplan_info.BeamSequence; % beams
fieldnames_beamSequence = fieldnames(beamSequence);

nBeam = size(fieldnames_beamSequence, 1);

for bb = 1:nBeam
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb}); % beam

    ncontrolpoints = item_beamSequence.NumberOfControlPoints;

    controlPointSequence = item_beamSequence.ControlPointSequence; % cps
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);

    %% hw 6 %%
    gantryAngles = zeros(ncontrolpoints, 1); % gantry angles

    for cp = 1:ncontrolpoints
        item_controlPointSequence = controlPointSequence.(fieldnames_controlpointsequence{cp}); % cp
        
        gantryAngles(cp, 1) = item_controlPointSequence.GantryAngle;
    end
    
    % save txt
    fprintf(fid, 'Beam %d, Gantry angle: %.1f to %.1f\n', bb, min(gantryAngles), max(gantryAngles));
end

fclose(fid);