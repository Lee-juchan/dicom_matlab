% - RT plan, RT dose, RT structure 폴더 읽기


clear all;
close all;
clc;

%% hw 2 %%
% folders (RTPLAN, RTDOSE, RTst)
patientDataFolder = fullfile(pwd, 'data', 'patient-example');
folders = dir(patientDataFolder);

RTFolders = {}; % cell array

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, 'RT') % 'RT' 포함
    RTFolders{end + 1} = [fullfile(folders(ff).folder, folders(ff).name)];
    end
end