% DICOM CT 3d 이미지 읽고, axial, sagittal, coronal views를 한 이미지에 plot하고, 이미지로 저장
% 각 plane에서 이미지 볼륭 중간 정도의 slice 추출
% figure 사이즈 조정, tiledlayout에서 사이즈 조정

clear all;
close all;
clc;

% get CT Folder from patient folder
patientDataFolder = fullfile(pwd, 'data', 'patient-example');

folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, 'CT')
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

% load image volume
[image, spatial] = dicomreadVolume(CTFolder);
image = squeeze(image);
image = image - 3614; % raw value -> CT number (hard coding)

% define coordinates in x,y,z directions
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

% image plot
fig = figure('color', 'w');
set(fig, 'units', 'inches');
set(fig, 'outerPosition', [2,2,15,7]);

tiledlayout(fig,1,3, 'tileSpacing', 'compact', 'padding', 'compact');

% axial view
nexttile;
imagesc(y_image, x_image, image(:, :, 168));
colormap('gray');
axis xy equal tight;
set(gca, 'ydir', 'reverse');
xlabel('R-L distance (mm)', 'Fontsize', 12);
ylabel('A-P distance (mm)', 'Fontsize', 12);
title('Axial', 'FontSize', 12);

% sagittal view
nexttile;
imagesc(y_image, z_image, squeeze(image(:, 256, :))');
colormap('gray');
axis xy equal tight;
xlabel('A-P distance (mm)', 'Fontsize', 12);
ylabel('I-S distance (mm)', 'Fontsize', 12);
title('Sagittal', 'FontSize', 12);

% coronal view
nexttile;
imagesc(x_image, z_image, squeeze(image(256, :, :))');
colormap('gray');
axis xy equal tight;
xlabel('R-L distance (mm)', 'Fontsize', 12);
ylabel('I-S distance (mm)', 'Fontsize', 12);
title('Coronal', 'FontSize', 12);

% save fig
filename = fullfile(pwd, 'data', 'hw5.jpg');
print(filename, '-djpeg', '-r300');