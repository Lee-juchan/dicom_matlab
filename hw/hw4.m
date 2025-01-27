% dicomreadVolume() 함수 이용하여, CT volume 읽고, xyz 좌표 구하기
% 각 축 범위를 텍스트 파일로 출력

% max(), min() 사용 + 2차원에서 좌표를 설정하는 코드 참조


%%
clear all;
close all;
clc;

%%
% get CT Folder from patient folder
patientDataFolder = fullfile(pwd, 'data', 'patient-example');

folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, 'CT')
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

%%
% load image volume
[image, spatial] = dicomreadVolume(CTFolder);   % 4d (512, 512, 1, 337)
image = squeeze(image);                         % 1인 차원 제거 -> (1, 5)??

% get origin, spacing, size
image_origin = spatial.PatientPositions(1,:);
image_spacing = spatial.PixelSpacings(1,:); % x,y 간격
image_spacing(3) = spatial.PatientPositions(2,3) - spatial.PatientPositions(1,3); % z 간격
image_size = spatial.ImageSize; % = size(image);

%%
% define coordinates in x,y,z directions
x = zeros(image_size(1), 1);
y = zeros(image_size(2), 1);
z = zeros(image_size(3), 1);

for ii = 1:image_size(1)
    x(ii) = image_origin(1) + image_spacing(1)*(ii-1);
end
for jj = 1:image_size(2)
    y(jj) = image_origin(2) + image_spacing(2)*(jj-1);
end
for kk = 1:image_size(3)
    z(kk) = image_origin(3) + image_spacing(3)*(kk-1);
end

%%
% print min, max
filename = fullfile(pwd, 'data', 'hw4.txt');

fid = fopen(filename, 'w');

fprintf(fid, 'x = %f, %f\n', min(x), max(x));
fprintf(fid, 'y = %f, %f\n', min(y), max(y));
fprintf(fid, 'z = %f, %f\n', min(z), max(z));

fclose(fid);