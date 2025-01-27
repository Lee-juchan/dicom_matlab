% 🌟 강의 목표:
% 1. DICOM CT 파일 하나를 열고, axial image를 plot
% 2. DICOM image의 coordinates에 대해 이해
% 3. Plot한 결과를 그림 파일로 저장하는 방법을 공부

% 🌟 주요 MATLAB 함수
% 1. dicomread()
% 2. zeros()
% 3. figure(), imagesc(), colormap(), axis(), clim()
% 4. xlabel(), ylabel(), title()
% 5. print() : fig img 파일로 저장      '-djpeg':jpeg 형태, '-r300': 해상도 300 (논문 300~600)

%%% 1.
% dicominfo : header
% dicomread : data

%%% 2.
% DIMCOM 영상 좌표 설정에 필요한 값
% Origin    : 기준 픽셀 위치 (가장 작은 픽셀)    -> 오-왼, inter-poster / 강의에서는 좌상단
% Spacing   : 픽셀 크기/간격
% Size      : 픽셀의 수

% clim([cmin, cmax]) : like truncate    -> caxis() in octave


clear all;
close all;
clc;

% get CT Folder from patient folder
patientDataFolder = fullfile(pwd, 'data', 'patient-example');

folders = dir(patientDataFolder);

for ff = 1:size(folders, 1) % dim=1
    if contains(folders(ff).name, 'CT')
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

% get DICOM files
files = dir(fullfile(CTFolder, '*.dcm'));

for ff = 1:1%size(files, 1)
    filename =  fullfile(files(ff).folder, files(ff).name);
    
    info = dicominfo(filename);
    sliceLocation = info.SliceLocation;

    fprintf('Slice location = %.1f\n', sliceLocation);

    %% lec3 %%
    % get header information to create coordinates
    image = dicomread(info);

    image_origin = info.ImagePositionPatient;
    image_spacing = info.PixelSpacing;
    image_size = size(image);

    % define coordinates in x,y directions
    x = zeros(image_size(1), 1);
    y = zeros(image_size(2), 1);

    for ii = 1:image_size(1)
        x(ii) = image_origin(1) + image_spacing(1)*(ii-1);
    end
    for jj = 1:image_size(2)
        y(jj) = image_origin(2) + image_spacing(2)*(jj-1);
    end

    % plot
    figure('Color', 'w');
    imagesc(x,y, image); % -> x, y 좌표가 이미지에 표시됨 (-250 ~ 250)
    colormap('gray');
    axis equal;
    axis tight;
    clim([2500, 4500]);
    xlabel('R-L distance (mm)', 'Fontsize', 20);
    ylabel('A-P distance (mm)', 'Fontsize', 20);
    title('Axial view');

    % save file
    fig_filename = fullfile(pwd, 'data', 'lec3.jpg');
    print(fig_filename, '-djpeg', '-r300');
end