function [image, spatial] = dicomreadVolume(path)
    % dicomreadVolume: DICOM 시리즈를 읽어 3D 볼륨 데이터를 4D 배열로 생성
    %
    % 입력:
    %   path - DICOM 파일이 저장된 디렉토리 경로
    %
    % 출력:
    %   image - 4D 배열 형태의 볼륨 데이터 [rows, cols, 1, numSlices]
    %   spatial - 구조체로 저장된 공간 정보 (PixelSpacing, SliceThickness 등)
    
    % 디렉토리 내 모든 DICOM 파일 검색
    files = dir(fullfile(path, '*.dcm'));
    if isempty(files)
        error('No DICOM files found in the specified directory.');
    end
    
    % 파일 이름 정렬
    fileNames = {files.name};
    [sortedFileNames, sortIdx] = sort_nat_octave(fileNames); % 자연 정렬
    files = files(sortIdx);
    
    % 첫 번째 파일로 이미지 크기 및 메타데이터 가져오기
    firstFilePath = fullfile(path, files(1).name);
    info = dicominfo(firstFilePath);
    firstSlice = dicomread(info);
    [rows, cols] = size(firstSlice);
    numSlices = numel(files);
    
    % 4D 배열 초기화 (이미지 크기 및 슬라이스 수 반영)
    image = zeros(rows, cols, 1, numSlices, 'like', firstSlice);
    
    % 공간 정보 초기화
    spatial = struct();
    spatial.PixelSpacing = info.PixelSpacing;           % 픽셀 간격 (mm)
    spatial.SliceThickness = info.SliceThickness;       % 슬라이스 두께 (mm)
    spatial.ImagePositionPatient = zeros(3, numSlices); % 각 슬라이스 위치 저장
    
    % 각 DICOM 파일에서 데이터를 읽어 배열 및 공간 정보에 저장
    for i = 1:numSlices
        filePath = fullfile(path, files(i).name);
        info = dicominfo(filePath);
        slice = dicomread(filePath);                    % 현재 슬라이스 읽기
        image(:, :, 1, i) = slice;                      % 4D 배열에 저장
        spatial.ImagePositionPatient(:, i) = info.ImagePositionPatient; % 슬라이스 위치 저장
    end
    
    % 슬라이스 위치 기준 정렬 (Z 방향)
    [~, sortIdx] = sort(spatial.ImagePositionPatient(3, :));
    image = image(:, :, :, sortIdx);                    % 4D 배열 정렬
    spatial.ImagePositionPatient = spatial.ImagePositionPatient(:, sortIdx);
end

function [sortedNames, sortIdx] = sort_nat_octave(fileNames)
    % sort_nat_octave: 문자열 배열을 자연 정렬
    %
    % 입력:
    %   fileNames - 정렬할 파일 이름의 셀 배열
    %
    % 출력:
    %   sortedNames - 자연 정렬된 파일 이름 배열
    %   sortIdx - 원래 배열에서의 정렬된 인덱스
    
    % 숫자를 추출하고 비교를 위한 인덱스 생성
    numExtract = @(str) sscanf(str, '%*[^0-9]%d');
    numericParts = cellfun(numExtract, fileNames, 'UniformOutput', false);
    numericParts = cellfun(@(x) ifelse(isempty(x), inf, x), numericParts); % 비어있는 값 처리
    
    % 정렬
    [~, sortIdx] = sortrows([numericParts(:), (1:numel(fileNames))']);
    sortedNames = fileNames(sortIdx);
end

function out = ifelse(cond, trueVal, falseVal)
    % 간단한 ifelse 구현
    if cond
        out = trueVal;
    else
        out = falseVal;
    end
end
