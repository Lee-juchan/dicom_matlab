% DICOM CT file 중 slice location이 -489인 file 찾아서 읽고, image로 저장
% image를 plot할 때, x축과 y축의 범위를 각각 -150~150, -350~-50으로 한정

% axis([xmin xmax ymin ymax])


clear all;
close all;
clc;


%% for octave
pkg load dicom; % for /octave

% contains()
function [res] = contains(str, pattern)
    if iscell(str)
        res = cellfun(@(s) ~isempty(strfind(s, pattern)), str);
    else
        res = ~isempty(strfind(str, pattern));
    end
end
%%


workingFolder = 'C:\Users\DESKTOP\workspace\DICOM_matlab';
patientDataFolder = strcat(workingFolder, '\data', '\patient-example')

% get CT Folder from patient folder
folders = dir(sprintf('%s\\', patientDataFolder));

for ff = 1:size(folders, dim=1)
    if contains(folders(ff).name, 'CT')
        CTFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);
    end
end

% get DICOM files
files = dir(sprintf('%s\\*.dcm', CTFolder));

for ff = 1:size(files, dim=1)
    filename =  sprintf('%s\\%s', files(ff).folder, files(ff).name);
    
    info = dicominfo(filename);
    sliceLocation = info.SliceLocation;

    if sliceLocation = -489.5
            image = dicomread(info);
        
            % get header information to create coordinates
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
            caxis([2500, 4500]); % clim() in matlab
            axis([-150, 150, -350, -50])
            xlabel('R-L distance (mm)', 'Fontsize', 20);
            ylabel('A-P distance (mm)', 'Fontsize', 20);
            title('Axial view');
        
            % save file
            fig_filename = sprintf('%s\\data\\hw3_ct.jpg', workingFolder);   % fig 저장
            print(fig_filename, '-djpeg', '-r300');                 % jpeg, 300 resolution (논문 작성시 300~600)
        break
    end
end

