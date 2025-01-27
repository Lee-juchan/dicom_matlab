% DICOM RT Plan 파일을 읽고, 각 빔의 gantry angle의 range를 텍스트 파일로 출력하는 코드를 작성


clear all;
close all;
clc;


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


% save txt
filename = fullfile(pwd, 'data', 'hw6.txt');

fid = fopen(filename, 'w');


% reading RT Plan
rtplan_info = dicominfo(RTPLANFile);

beamSequence = rtplan_info.BeamSequence;
fieldnames_beamSequence = fieldnames(beamSequence); % beam의 수 만큼 나옴

nBeam = size(fieldnames_beamSequence, 1);

for bb = 1:nBeam
    item_beamSequence = beamSequence.(fieldnames_beamSequence{bb});

    beamname = item_beamSequence.BeamName;
    ncontrolpoints = item_beamSequence.NumberOfControlPoints;

    controlPointSequence = item_beamSequence.ControlPointSequence;
    fieldnames_controlpointsequence = fieldnames(controlPointSequence);

    gantryAngles = zeros(ncontrolpoints, 1);

    for cp = 1:ncontrolpoints
        item_controlPointSequence = controlPointSequence.(fieldnames_controlpointsequence{cp});
        
        gantryAngles(cp, 1) = item_controlPointSequence.GantryAngle;
    end
    
    fprintf(fid, 'Beam %d, Gantry angle: %.1f to %.1f\n', bb, min(gantryAngles), max(gantryAngles));
end

% end save txt
fclose(fid);