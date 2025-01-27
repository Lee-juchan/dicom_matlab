% - RTst, CT에서, 함께 plot
% -> lec11 빈칸 채우기

clear all;
close all;
clc;

% folders, files (CT, RTst)
patientDataFolder = fullfile(pwd, 'data', 'patient-example');
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_CT_')
        CTFolder = fullfile(folders(ff).folder, folders(ff).name);     % CT
    elseif contains(folders(ff).name, '_RTst_')
        RTStFolder = fullfile(folders(ff).folder, folders(ff).name);   % RT Structure
    end
end

files = dir(fullfile(RTStFolder, '*.dcm'));
RTStFile = fullfile(files(1).folder, files(1).name);

% CT
[image, spatial, dim] = dicomreadVolume(CTFolder);

image = squeeze(image);
image = image - 3614; % for CT number

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


% RT Structure
rtst_info = dicominfo(RTStFile, 'UseVRHeuristic', false);   % 'UseVRHeuristic', false : 없으면 오류
contour = dicomContours(rtst_info);

ROIs = contour.ROIs; % rois

name = ROIs.Name;
contourData = ROIs.ContourData;
color = ROIs.Color;

nROIs = size(ROIs, 1);

% selected ROI
ROIname_selected = {'GTV'; 'ITV'; 'PTV 1250x4 Dmax~'};
nROIs_selected = size(ROIname_selected, 1);

index = zeros(nROIs_selected, 1);

for roi = 1:nROIs_selected
    for st = 1:nROIs
        if strcmp(name{st, 1}, ROIname_selected{roi,1})
            index(roi, 1) = st;
        end
    end
end

% contours (for selected ROI)
roiData = struct([]);

for roi = 1:nROIs_selected
    contourData_selected = contourData{index(roi, 1)};
    color_selected = color{index(roi, 1)};

    z_roi = []; % roi별 z list
    nSlice = size(contourData_selected, 1);

    for ss = 1:nSlice
        contourData_slice = contourData_selected{ss, 1};
        z_slice = contourData_slice(1, 3);
        z_roi = [z_roi; z_slice];
    end
    z_roi = unique(z_roi);

    roiData(roi).ContourData = contourData_selected;
    roiData(roi).Color = color_selected;
    roiData(roi).z_roi = z_roi;
end


% plot CT + contour
fig = figure('color', 'w');
set(gcf, 'units', 'inches');
set(gcf, 'outerPosition', [1,1,10,9]);
set(gcf, 'defaultAxesLooseInset', [0.05,0.1,0.03,0.03]);

t_profile = tiledlayout(fig,3,3, 'tileSpacing', 'compact', 'padding', 'compact');

for zz = -1064.5:-1056.5 % hard coding
    % CT
    z_index = find(z_image == zz); % zz of CT

    nexttile;
    imagesc(x_image, y_image, image(:,:,z_index));
    colormap('gray');
    set(gca, 'YDir', 'reverse');
    axis equal;
    axis([20 70 -10 40]);
    clim([-1000 1000]);
    title(sprintf('z = %.1f', zz), 'FontSize', 12);
    hold on;

    % contour
    for roi = 1:nROIs_selected
        contourData_selected = roiData(roi).ContourData;
        color_selected = roiData(roi).Color;
        z_roi = roiData(roi).z_roi;

        %% hw 11 %%
        z_roi_index = find(z_roi == zz); % zz of contour(ROI)
        contourData_slice = contourData_selected{z_roi_index};
        %%

        contourData_slice(end+1, :) = contourData_slice(1,:);
        x = contourData_slice(:, 1);
        y = contourData_slice(:, 2);
        z = contourData_slice(:, 3);

        plot(x, y, 'color', color_selected/255, 'linewidth', 2.0);
    end
end