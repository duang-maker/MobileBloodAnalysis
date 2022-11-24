% Normalizing the BDPC Image to specific gray
CellIndex = 5; % the cell index of the cell type in 'CellType'
CellType = {'Neu', 'Lym', 'Eos', 'Bas', 'Mon'};
ImgPath = ['H:\Micro-Label-Free-5\label-free-data\LeucocyteSubcyte\BGNormalized\',CellType{CellIndex}, '\'];
SavePath = ['H:\Micro-Label-Free-5\label-free-data\LeucocyteSubcyte\BGNormalized\', CellType{CellIndex},'\BGNorm\'];
%% 
if ~exist(SavePath)
    mkdir(SavePath);
end
Files = dir([ImgPath,'*.bmp']);
ImgNameList = {Files.name};
ImgNum = length(ImgNameList);
for i = 1:ImgNum
    ImgColor = imread([ImgPath, ImgNameList{i}]); 
    if length(size(ImgColor)) == 3

        ImOneChannel = ImgColor(:,:,2);
    else
        ImOneChannel = ImgColor;
    end

    [num, gray] = imhist(ImOneChannel);
    % find the maximal value
    Maximuns = find(diff(sign(diff(num)))==-2);
    [Value_Index, Pos] = sort(num(Maximuns), 'descend');
    % TheMaxIndex = find(Value_Index == max(Value_Index));
    C = 8; % Campare Range
    BGGray = max(Maximuns(Pos(1:C)));
    % Mormalizing the image 
    NormalVale = 170;
    ImgGreenNorm = ImOneChannel.*(NormalVale/BGGray);
%     figure; imshow(ImgGreenNorm);
    imwrite( ImgGreenNorm, [SavePath,ImgNameList{i}]);
end