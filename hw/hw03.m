% - slice location이 -984.5인 CT plot하고 저장
% - x축범위=(-150~150), y축범위=(-350~-50)
% -> axis([xmin xmax ymin ymax])

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

% files (.dcm)
files = dir(fullfile(CTFolder, '*.dcm'));

for ff = 1:size(files, 1)
    filename =  fullfile(files(ff).folder, files(ff).name);
    
    %% hw 3 %%
    % CT
    info = dicominfo(filename);
    sliceLocation = info.SliceLocation;
    
    if sliceLocation == -984.5
        image = dicomread(info);
    
        image_origin = info.ImagePositionPatient;
        image_spacing = info.PixelSpacing;
        image_size = size(image);
    
        % image coordinates
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
        imagesc(x,y, image);
        colormap('gray');
        axis equal tight;
        clim([2500, 4500]);
        axis([-150, 150, -350, -50])
        xlabel('R-L distance (mm)', 'Fontsize', 20);
        ylabel('A-P distance (mm)', 'Fontsize', 20);
        title('Axial view');
    
        % save fig
        fig_filename = fullfile(pwd, 'data', 'hw3.jpg');
        print(fig_filename, '-djpeg', '-r300');
    end
end

