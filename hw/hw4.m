% - CT에서, volume 읽고 xyz 좌표 구하기 (dicomreadVolume() 이용)
% - x,y,z 범위를 txt 파일로 출력
% -> max(), min() + 2차원에서 좌표를 설정하는 코드 참조


clear all;
close all;
clc;

% folder (CT)
patientDataFolder = fullfile(pwd, 'data', 'patient-example');
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, 'CT')
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

% CT
[image, spatial] = dicomreadVolume(CTFolder);
image = squeeze(image);

image_origin = spatial.PatientPositions(1,:);
image_spacing(1:2) = spatial.PixelSpacings(1,:);
image_spacing(3) = spatial.PatientPositions(2,3) - spatial.PatientPositions(1,3);
image_size = spatial.ImageSize;

%% hw 4 %%
% image coordinates
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


% print min, max
filename = fullfile(pwd, 'data', 'hw4.txt');

fid = fopen(filename, 'w');
fprintf(fid, 'x = %f, %f\n', min(x), max(x));
fprintf(fid, 'y = %f, %f\n', min(y), max(y));
fprintf(fid, 'z = %f, %f\n', min(z), max(z));
fclose(fid);