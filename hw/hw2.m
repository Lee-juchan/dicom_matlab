% RT plan, RT dose, RT structure folder 가져오기

%%
clear all;
close all;
clc;

%%
% get CT Folder from patient folder
workingFolder = 'C:\Users\DESKTOP\workspace\DICOM_matlab';
PatientDataFolder = strcat(workingFolder, '\data', '\patient-example');

folders = dir(sprintf('%s\\', PatientDataFolder));
RTFolder = {}; % cell array 사용

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, 'RT') % CT 포함된 폴더
    RTFolder{end + 1} = [sprintf('%s\\%s', folders(ff).folder, folders(ff).name)];
    end
end

RTFolder