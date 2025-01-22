% 🌟 강의 목표:
% 1. MATLAB을열고간단한코드를실행할수있다.
% 2. DICOM CT 파일을 열고, 헤더정보를확인할수있다.
% 3. DICOM 데이터에서 추출한 헤더정보를 text파일형태로내보낼수있다.

% 🌟 주요 MATLAB 함수
% 1. dicominfo()
% 2. fopen()
% 3. fprintf()


clear all;
close all;
clc;

% for octave
pkg load dicom;
%


filename = 'C:\Users\DESKTOP\workspace\DICOM_matlab\data\test.dcm';

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
fid = fopen('C:\Users\DESKTOP\workspace\DICOM_matlab\test.txt','w');

fprintf(fid,'Pixel Spacing: %.3f, %.3f\n',PixelSpacing);
fprintf(fid,'Patient Name: %s, %s\n',PatientFamilyName,PatientGivenName);
fprintf(fid,'Width: %d\n',Width);

fclose(fid);
