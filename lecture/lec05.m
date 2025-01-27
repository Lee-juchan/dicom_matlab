% 🌟 강의 목표:
% 1. 숙제4 해설: CT image의 x, y, z 좌표 설정, 좌표축 최대/최소값 출력,
% 2. Figure 영역 설정하기,
% 3. 하나의 figure에 여러 개의 plot하기 (axial/sagittal/coronal),

% 🌟 주요 MATLAB 함수
% 1. set(gcf, …) : 'units', 'inches' : 단위를 인치로
%                  'OuterPostion', [1,1,5,5] : margin w/h, width w/h
% 2. tiledlayout :  like subplots
%    nexttile :     다음 타일로 이동
% 3. squeeze()
%%

%%% 3.
% CT 좌표계
% x :   right-left
% y :   anterior-posterior (앞-뒤)
% z :   inferior-superior  (위-아래)

% voxel 가져오기
% image(m, n, p) m=y축, n=x축, p=z축
% 
% ex
% axial slice 1 = image(:, :, 1)
% sagittal 1    = image(:, 1, :) + squeeze()

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

% 3d image
[image, spatial] = dicomreadVolume(CTFolder);
image = squeeze(image);

% image coordinates
image_origin = spatial.PatientPositions(1,:);
image_spacing = spatial.PixelSpacings(1,:);
image_spacing(3) = spatial.PatientPositions(2,3) - spatial.PatientPositions(1,3);
image_size = spatial.ImageSize;

x_image = zeros(image_size(1), 1);
y_image = zeros(image_size(2), 1);
z_image = zeros(image_size(3), 1);

for ii = 1:image_size(1)
    x_image(ii) = image_origin(1) + image_spacing(1)*(ii-1);
end
for jj = 1:image_size(2)
    y_image(jj) = image_origin(2) + image_spacing(2)*(jj-1);
end
for kk = 1:image_size(3)
    z_image(kk) = image_origin(3) + image_spacing(3)*(kk-1);
end

%% lec5 %%
fig = figure('color', 'w');
set(fig, 'units', 'inches');
set(fig, 'outerPosition', [2,2,10,5]);

% subplot
tiledlayout(fig,1,2, 'tileSpacing', 'compact', 'padding', 'compact'); % compact가 시각화 유리

% axial
nexttile;
imagesc(y_image, x_image, image(:, :, 120)); % 120th slice
colormap(gray);
set(gca, 'YDir', 'reverse'); % anterior가 위로
axis equal tight;
xlabel('R-L distance (mm)', 'Fontsize', 12);
ylabel('A-P distance (mm)', 'Fontsize', 12);
title('Axial', 'FontSize', 12);

% sagittal
nexttile;
imagesc(y_image, z_image, squeeze(image(:, 256, :))')   % (y, z)' -> (z, y)
colormap(gray);
axis equal tight;
xlabel('A-P distance (mm)', 'Fontsize', 12);
ylabel('I-S distance (mm)', 'Fontsize', 12);
title('Sagittal', 'FontSize', 12);