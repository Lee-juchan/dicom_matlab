% - RTDOSE에서, Maximum dose (total dose & fractional dose) 계산하고 출력
% -> total dose :       기본 rtdose
% -> fraction dose :    total dose / # of fraction (using RTPLAN)
%
% -> max() 사용

clear all;
close all;
clc;

% folders, files (RTDOSE, RTPLAN)
patientDataFolder = fullfile(pwd, 'data', 'patient-example');
folders = dir(patientDataFolder);

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTDOSE_')
        RTDoseFolder = fullfile(folders(ff).folder, folders(ff).name);   % RT Dose
    elseif contains(folders(ff).name, '_RTPLAN_')
        RTPLANFolder = fullfile(folders(ff).folder, folders(ff).name);
    end
end

files_rtdose = dir(fullfile(RTDoseFolder, '*.dcm'));
files_rtplan = dir(fullfile(RTPLANFolder, '*.dcm'));

RTDoseFile = fullfile(files_rtdose(1).folder, files_rtdose(1).name);
RTPLANFile = fullfile(files_rtplan(1).folder, files_rtplan(1).name);


% RT Plan
rtplan_info = dicominfo(RTPLANFile);

fractionGroupSequence = rtplan_info.FractionGroupSequence;
nFraction = fractionGroupSequence.Item_1.NumberOfFractionsPlanned; % # of fx


% RT dose
rtdose_info = dicominfo(RTDoseFile);

rtdose_data = dicomread(rtdose_info);
rtdose_data = squeeze(rtdose_data);

rtdose_gridscaling = rtdose_info.DoseGridScaling;
rtdose = rtdose_gridscaling * double(rtdose_data); % = total dose

%% hw 12 %%
% maximum dose
max_total_dose = max(max(max(rtdose)));
max_fraction_dose = max_total_dose / nFraction;

fprintf('Maximum Total dose : %.2f Gy\n', max_total_dose);
fprintf('Maximum Fraction dose : %.2f Gy\n', max_fraction_dose); % 지훈킴 : 단위 꼭 표기