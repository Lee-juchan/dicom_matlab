
% createMaskJK 

function [mask, x_mask, y_mask, z_mask] = createMaskJK(contour,index) % (createMask(rtContours, roiIndex, spatial)에서 spatial 제거)
    % voxel size in mask image (mm)
    mask_grid_spacing = 1.0;
    padding = 40.0;

    ROIs = contour.ROIs;
    ContourData = ROIs.ContourData;
    ContourData_selected = ContourData{index};

    ContourData_all = [];
    for kk = 1:size(ContourData_selected,1)
        ContourData_temp = ContourData_selected{kk};

        ContourData_all = [ContourData_all; ContourData_temp];
    end

    xlim = [floor(min(ContourData_all(:,1)))-padding*mask_grid_spacing, ceil(max(ContourData_all(:,1)))+padding*mask_grid_spacing];
    ylim = [floor(min(ContourData_all(:,2)))-padding*mask_grid_spacing, ceil(max(ContourData_all(:,2)))+padding*mask_grid_spacing];
    zlim = [min(ContourData_all(:,3))-padding*mask_grid_spacing, max(ContourData_all(:,3))+padding*mask_grid_spacing];

    referenceInfo = imref3d;
    referenceInfo.ImageSize = [(ylim(2)-ylim(1))/mask_grid_spacing, (xlim(2)-xlim(1))/mask_grid_spacing, (zlim(2)-zlim(1))/mask_grid_spacing];
    referenceInfo.XWorldLimits = xlim;
    referenceInfo.YWorldLimits = ylim;
    referenceInfo.ZWorldLimits = zlim;

    mask = createMask(contour,index,referenceInfo);
    
    x_mask = xlim(1)+0.5*mask_grid_spacing:mask_grid_spacing:xlim(2)-0.5*mask_grid_spacing;
    y_mask = ylim(1)+0.5*mask_grid_spacing:mask_grid_spacing:ylim(2)-0.5*mask_grid_spacing;
    z_mask = zlim(1):mask_grid_spacing:zlim(2);
end