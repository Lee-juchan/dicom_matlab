% 🌟 강의 목표:
% 1. zeros() 공부하기
% 2. for문 공부하기
% 3. 숙제6 해설: DICOM RT Plan 파일을 읽고, 각 빔의 gantry angle의 range를 텍스트 파일로 출력하기

% 🌟 주요 MATLAB 함수
% 1. zeros()
% 2. for문
%%

% zeros(2) == zeros(2,2)

clear all;
close all;
clc;

%% lec 7 %%
% zeros + for
times_table_result = zeros(9,8);

for j = 1:8
    n = j + 1;

    % n-times table
    for i = 1:9
        times_table_result(j,i) = n*i;
    end
end