% 🌟 강의 목표:
% 1. 숙제 11 해설: 여러 개의 contour를 CT 위에 plot하기
% 2. DICOM RT dose 파일 읽기, dose를 CT 위에 plot하기

% 🌟 주요 MATLAB 함수:
% 1. double()
% 2. axes, linkaxes, alpha


% CT / dose plot 어려움
% 1. thickness 다름     -> 공통 z만 plot
% 2. overlay 문제       -> 2개 좌표계 사용해서 다른 cmap적용 (linkaxes로 연결), 투명도 조정


clear all;
close all;
clc;

patientDataFolder = fullfile(pwd, 'data', 'patient-example');

% get CT and RT Dose Folder from patient folder
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_CT_')
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);     % CT
    elseif contains(folders(ff).name, '_RTDOSE_')
        RTDoseFolder = fullfile(folders(ff).folder, folders(ff).name);   % RT Dose
    end
end

files = dir(fullfile(RTDoseFolder, '*.dcm'));
RTDoseFile = fullfile(files(1).folder, files(1).name);


% reading CT (3d volumne)
[image, spatial, dim] = dicomreadVolume(CTFolder);

image = squeeze(image);
image = image - 3614; % raw value -> CT number

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

%%
% reading RT dose
rtdose_info = dicominfo(RTDoseFile);

rtdose_data = dicomread(rtdose_info); % 143 267 1 317
rtdose_data = squeeze(rtdose_data);

rtdose_origin = rtdose_info.ImagePositionPatient; % CT image와 상당히 유사, but 영역자체가 다름
rtdose_spacing(1:2) = rtdose_info.PixelSpacing; % 2 2 2 (voxel size)
rtdose_spacing(3) = rtdose_info.SliceThickness;
rtdose_size = size(rtdose_data);

% to convert raw data -> dose
rtdose_gridscaling = rtdose_info.DoseGridScaling;
rtdose = rtdose_gridscaling * double(rtdose_data); % uint16 -> double (안하면 반올림 처리됨)

x_rtdose = zeros(rtdose_size(2), 1); % y x z 순서 -> 지훈킴은 CT(x y z)랑 다르다고 했는데 CT도 y x z 아닌가? (행 열 높이)가 보통 axis 0 1 2 인데?
y_rtdose = zeros(rtdose_size(1), 1);
z_rtdose = zeros(rtdose_size(3), 1);

for ii = 1:rtdose_size(2)
    x_rtdose(ii) = rtdose_origin(1) + rtdose_spacing(1)*(ii-1);
end
for jj = 1:rtdose_size(1)
    y_rtdose(jj) = rtdose_origin(2) + rtdose_spacing(2)*(jj-1);
end
for kk = 1:rtdose_size(3)
    z_rtdose(kk) = rtdose_origin(3) + rtdose_spacing(3)*(kk-1);
end

%
% plot dose/contour on CT
fig = figure('color', 'w');
set(gcf, 'units', 'inches');
set(gcf, 'outerPosition', [1,1,10,9]);
set(gcf, 'defaultAxesLooseInset', [0.05,0.1,0.03,0.03]);

% get axial CT image corresponding to contour slice
zz = -1060.5;
z_index = find(z_image == zz);
z_rtdose_index = find(z_rtdose == zz);

ax1 = axes;
im_ct = imagesc(ax1, x_image,y_image, image(:,:,z_index));
colormap(ax1, 'gray');
axis equal;
axis([-100 100 -100 100]);
clim([-1000 1000]);
xlabel('R-L distance (mm)', 'fontsize', 14);
ylabel('A-P distance (mm)', 'fontsize', 14);

hold on;
ax2 = axes;
im_dose = imagesc(ax2, x_rtdose,y_rtdose, rtdose(:,:,z_rtdose_index));
colormap(ax2, 'jet');
axis equal;
axis([-100 100 -100 100]);
alpha(ax2, 0.4);

linkaxes([ax1 ax2], 'xy'); % 스케치북 맞추고,
ax2.Visible = 'off'; % 스케치북 안보이게 (안겹치게 흰바탕 제거)