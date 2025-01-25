% Maximum dose (total dose와 fractional dose)를 계산하고, 화면으로 출력하는 코드
% total dose는 코드의 rtdose
% fraction는 DICOM RT plan 파일에서 fraction 수를 가져다가 계산
% max() 함수


clear all;
close all;
clc;


workingFolder = 'C:\Users\DESKTOP\workspace\DICOM_matlab';
patientDataFolder = strcat(workingFolder, '\data', '\patient-example');


% get CT and RT Dose Folder from patient folder
folders = dir(sprintf('%s\\', patientDataFolder));

for ff = 1:size(folders, 1)
    if contains(folders(ff).name, '_RTDOSE_')
        RTDoseFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);   % RT Dose
    elseif contains(folders(ff).name, '_RTPLAN_')
        RTPLANFolder = sprintf('%s\\%s', folders(ff).folder, folders(ff).name);
    end
end

if exist(RTDoseFolder, 'dir')
    files_rtdose = dir(sprintf('%s\\*.dcm', RTDoseFolder));
end
RTDoseFile = fullfile(files_rtdose(1).folder, files_rtdose(1).name); % 지훈킴이 if exist, fullfile 사용

if exist(RTPLANFolder, 'dir')
    files_rtplan = dir(sprintf('%s\\*.dcm', RTPLANFolder));
end
RTPLANFile = fullfile(files_rtplan(1).folder, files_rtplan(1).name);


% reading RT Plan
rtplan_info = dicominfo(RTPLANFile);

fractionGroupSequence = rtplan_info.FractionGroupSequence;
nFraction = fractionGroupSequence.Item_1.NumberOfFractionsPlanned;

% reading RT dose
rtdose_info = dicominfo(RTDoseFile);

rtdose_data = dicomread(rtdose_info); % 143 267 1 317
rtdose_data = squeeze(rtdose_data);

rtdose_gridscaling = rtdose_info.DoseGridScaling;
rtdose = rtdose_gridscaling * double(rtdose_data); % uint16 -> double (안하면 반올림 처리됨)


% maximum dose
max_total_dose = max(max(max(rtdose)));
max_fraction_dose = max_total_dose / nFraction;

fprintf('Maximum doses: \n');
fprintf('Maximum total dose : %.2f Gy\n', max_total_dose);
fprintf('Maximum Fraction dose : %.2f Gy\n', max_fraction_dose); % 지훈킴 팁 : 단위를 나타낼 때는 숫자 꼭 쓰기