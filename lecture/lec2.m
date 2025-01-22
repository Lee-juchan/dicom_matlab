% 🌟 강의 목표:
% 1. MIM에서 export한 환자 데이터에서 CT folder의 location (path) 가져오기
% 2. CT folder 내 다수의 CT images들을 가져오는 방법에 대해 이해
% 3. 각 CT마다 slice location 정보 가져오기

% 🌟 주요 MATLAB 함수
% 1. dir()
% 2. sprintf()
% 3. for/if statement
% 4. size()
% 5. contains()

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
patientDataFolder = strcat(workingFolder, '\data', '\patient-example')

% get CT Folder from patient folder
folders = dir(sprintf('%s\\', patientDataFolder));      % sprintf : string print, 결과는 문자열, fprintf는 bytes 값

for ff = 1:size(folders, dim=1)
    if contains(folders(ff).name, 'CT') % CT 포함된 폴더                % contains() : str 포함 여부
        CTFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);
    end
end

%%
% get DICOM files
files = dir(sprintf('%s\\*.dcm', CTFolder));

for ff = 1:size(files, dim=1)
    filename =  sprintf('%s\\%s', files(ff).folder, files(ff).name);
    
    info = dicominfo(filename);
    sliceLocation = info.SliceLocation;

    fprintf('Slice location = %.1f\n', sliceLocation)
end
%%