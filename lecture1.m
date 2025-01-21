clear all
close all
clc

filename = 'D:\MATLAB\99_Lecture\2022_02\test.dcm';

info = dicominfo(filename)

%%
% get information from DICOM CT file
PixelSpacing = info.PixelSpacing;
PatientName = info.PatientName;
PatientGivenName = PatientName.GivenName;
PatientFamilyName = PatientName.FamilyName;
Width = info.Width;

% print out CT information
% 1. to the command window
fprintf('Pixel Spacing: %.3f, %.3f\n',PixelSpacing)
fprintf('Patient Name: %s, %s\n',PatientFamilyName,PatientGivenName)
fprintf('Width: %d\n',Width)

% 2. to a text file
fid = fopen('D:\MATLAB\99_Lecture\2022_02\test.txt','w');

fprintf(fid,'Pixel Spacing: %.3f, %.3f\n',PixelSpacing);
fprintf(fid,'Patient Name: %s, %s\n',PatientFamilyName,PatientGivenName);
fprintf(fid,'Width: %d\n',Width);

fclose(fid);