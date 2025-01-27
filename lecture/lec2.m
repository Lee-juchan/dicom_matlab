% 🌟 강의 목표:
% 1. MIM에서 export한 환자 데이터에서 CT folder의 location (path) 가져오기
% 2. CT folder 내 다수의 CT images들을 가져오는 방법에 대해 이해
% 3. 각 CT마다 slice location 정보 가져오기

% 🌟 주요 MATLAB 함수
% 1. dir()
% 2. sprintf()  : str print (결과: 문자열) <-> fprintf (결과: bytes)
% 3. for/if
% 4. size()
% 5. contains() : str 포함 여부
%%

clear all;
close all;
clc;

%% lec 2 %%
% folders (CT)
patientDataFolder = fullfile(pwd, 'data', 'patient-example');
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, 'CT') % 'CT' 포함된 폴더
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

% files (.dcm)
files = dir(fullfile(CTFolder, '*.dcm'));

for ff = 1:size(files, 1)
    filename =  fullfile(files(ff).folder, files(ff).name);
    
    % read
    info = dicominfo(filename);

    sliceLocation = info.SliceLocation;
    fprintf('Slice location = %.1f\n', sliceLocation);
end