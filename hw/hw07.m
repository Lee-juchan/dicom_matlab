% for문 사용, 아래와 같은 행렬 만들기

% 1 2 .. 10
% 4 6 .. 22
% 7 10.. 34
% ..     ..
% 25 34 106

clear all;
close all;
clc;

%% hw 7 %%
sequence = zeros(9, 10);

for i = 1:10
    for j = 1:9
        sequence(j,i) = i + (j-1)*(i+2);
    end
end

disp(sequence)