% RT plan, RT dose, RT structure folder 가져오기

clear all;
close all;
clc;


%% for octave
pkg load dicom; % for /octave

% contains()
function [res] = contains(str, pattern)
    if iscell(str)
        res = cellfun(@(s) ~isempty(strfind(s, pattern)), str);
    else
        res = ~isempty(strfind(str, pattern));
    end
end
%%


workingFolder = 'C:\Users\DESKTOP\workspace\DICOM_matlab';
PatientDataFolder = strcat(workingFolder, '\data', '\patient-example')

% get CT Folder from patient folder
folders = dir(sprintf('%s\\', PatientDataFolder));      % sprintf : string print, 결과는 문자열, fprintf는 bytes 값
RTFolder = []

for ff = 1:size(folders, dim=1)
    if contains(folders(ff).name, 'RT') % CT 포함된 폴더                % contains() : str 포함 여부
        RTFolder = [RTFolder; sprintf('%s\\%s', folders(ff).folder, folders(ff).name)]
    end
end

RTFolder