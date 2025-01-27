% - CT에서, axial, sagittal, coronal views를 한 이미지에 plot하고 저장
% -> 중간 slice 추출
% -> tiledlayout 사용

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

% image coordinates
image_origin = spatial.PatientPositions(1,:);
image_spacing(1:2) = spatial.PixelSpacings(1,:);
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

%% hw 5 %%
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