%% 用于微型显微模组图像的红细胞计数算法
close all
% Sample = { '1_5','1_6','1_7','1_13','1_8','1_16', '2_10','2_2','3_G051_2063',...
%    '1_1_S3', '1_10','1_15','1_1','2_4','2_12','1_4','1_9','1_1_S2',...
%    'C','C2','X','1_1_S1','X2','1_16_region2','1_4_S2','1_9_S1',...
%    '1_9_S2','2_12_S1','2_12_S2','1_3'};
tic
Sample = {'1_5'};
SamplePath = 'H:\DPC_experimental_data\MICRO-RawData\'; %
VisualizeSeg = 0; % 是否可视化分割结果
IfSaveCount = 1;
IfSaveArea = 0;
IfSaveSegCell = 0;
SaveTxt =  'Fortesttime.txt'; % mean Hb 和 mean area 文本名
SaveTxtPth = [SamplePath, '\',SaveTxt];

SaveAreaPth = [SamplePath, '\','CellArea.txt'];

SampleFile = dir(SamplePath);
SampleFileName ={SampleFile.name};
IfisDirLogic = [SampleFile.isdir];
FileNum = length(SampleFileName);
type = '*.bmp';
% SampleFileName = SampleFileName(IfisDirLogic);
%%
% for k = 5 :7
for k = 1 : FileNum
    if IfisDirLogic(k)==1 && ~strcmp(SampleFileName{k} ,'.') && ~strcmp(SampleFileName{k} , '..')
        if ismember(SampleFileName{k}, Sample)
        
        ImgPath = [SamplePath,SampleFileName{k}, '\','SegRed\'];
        ImgFile = dir([ImgPath, type]);
        name = {ImgFile.name};
        ImgNum = length(name);
        % SampleHbList
        AllCount = 0;
        SumArea = 0;
        ValidAreaCount = 0;
        for i = 1: ImgNum
            ImgColor = imread([ImgPath, name{i}]); 
            if length(size(ImgColor)) == 3

                ImOneChannel = ImgColor(:,:,2);
            else
                ImOneChannel = ImgColor;
            end
    %=======================背景归一化================================
            NormlizeValue = 180;
            [num, gray] = imhist(ImOneChannel); % obtain the gray distribute curve
            % 找 极大值点
            Maximuns = find(diff(sign(diff(num)))==-2); % find the maximum 
            [Value_Index, Pos] = sort(num(Maximuns), 'descend');
        %     TheMaxIndex = find(Value_Index == max(Value_Index));
            if Maximuns(Pos(1))> Maximuns(Pos(2))   % BG is the first maximun
                BGGray = Maximuns(Pos(1));
            else
                BGGray = Maximuns(Pos(2));
            end
            % 背景归一化
            ImgGreenNorm = ImOneChannel.*(NormlizeValue/BGGray);
    %         figure;imshow(ImgGreenNorm);title('Norm BG')
            %% 
            UpAreaThresh = 8000; %5000
            LowAreaThresh = 500; % 500
            CircularityThresh = 0.3;
            ExtentThresh = 0.6;
            fillholeArea = 600;
            meanfilter = fspecial('average',[3,3]);
            FilterTheImg = imfilter(ImgGreenNorm, meanfilter);
            %     figure;imshow(FilterTheImg);title('FilterTheImg');
    %%
    % ====================otsu segmentation=======================
        thresh = graythresh(FilterTheImg)+0.02;
    %     thresh = graythresh(MassDensity);
        ImgNormBW = ~imbinarize(FilterTheImg, thresh);
   
%% 

 %  ==============morphological operation=================================
 %  =========== 1 fill while 2 open operation 3 watersplited
        WholeMassDilate = ImgNormBW;
        BW = WholeMassDilate;
        WholwMassOverFilled = imfill(BW, 'holes');
    %     figure; imshow(WholwMassOverFilled);title(' AllHoles')
        AllHoles = WholwMassOverFilled  & ~ BW;
    %     figure; imshow(AllHoles);title(' FillHoles');
        ValidHoles= bwRemoveLargeArea(AllHoles,fillholeArea,8);
    %     figure;
    %     subplot(1,2,1);imshow(AllHoles);title('AllHoles');
    %     subplot(1,2,2);imshow(ValidHoles);title('ValidHoles');
        WholeMassFill =  BW | ValidHoles;
    %     figure;imshow(WholeMassFill); title('after first fill')
        % WholeMassErode = imerode(WholeMassFill,se);
        % subplot(2,2,4);imshow(WholeMassErode);
    %     WholeMassFill = imfill(WholeMassFill, 'holes');
    %     figure;imshow(WholeMassFill); title('after second fill')
        % watershed operation
        se = strel('disk',18);
        WholeMassDilateopen=imopen(WholeMassFill,se);%初步开运算减少白色区域
    %     figure,imshow(WholeMassDilateopen),title('Open Image')
        BW2 = WholeMassDilateopen;
        D = bwdist(~BW2);
        % figure;
        % subplot(1,2,1);imshow(D,[],'InitialMagnification','fit');
        D=-D;
        % D(~WholeMassErode) =-Inf;
        mask=imextendedmin(D,2);
        D2=imimposemin(D,mask);
        Ld=watershed(D2);
        Water_splited=BW2;
        Water_splited(Ld==0)=0;
        %进行watershed分割并将分割结果以标记图形式绘出
        % L=watershed(D,8);
        % rgb = label2rgb(Ld,'jet',[.5 .5 .5]);
    %     figure;imshow(Water_splited,'InitialMagnification','fit');

 %%  ===========detected connect region=============================
        % 检测连通域
        [l,~] = bwlabel(Water_splited);
        RGBLabel = label2rgb(l);
        status = regionprops(l, 'Area', 'BoundingBox', 'Circularity', 'Extent', 'FilledImage');
        % status = regionprops(l, 'all');
        %% 
        AllAreaList = [status.Area];
    %     CircularityList = [status.Circularity];
        BoundingBoxList = {status.BoundingBox};
    %     ExtentList = [status.Extent];
        TotalCon = length(AllAreaList);
        
        %% cal the mean cell area
        AveargeArea = median(AllAreaList);
%         ValidCellIndex = zeros(length(AllAreaList),1);

        %% 可视化
        
        if VisualizeSeg
        figure; imshow(ImgColor); title(name)
    %     figure; imshow(Water_splited); title(name);
        hold on;
        for i = 1: TotalCon
    %         if (AllAreaList(i) < UpAreaThresh) && (AllAreaList(i) > LowAreaThresh) && (status(i).Circularity > CircularityThresh)  && (status(i).Extent > ExtentThresh)
    %         if (AllAreaList(i) < UpAreaThresh) && (AllAreaList(i) > LowAreaThresh) && (status(i).Extent > ExtentThresh)
    %         if (status(i).Extent > ExtentThresh)

%             rectangle('position', status(i).BoundingBox, 'edgecolor', 'r');
            if AllAreaList(i) > 2*AveargeArea
                count = round(AllAreaList(i)/AveargeArea);
                rectangle('position', status(i).BoundingBox, 'edgecolor', 'r');
                text(status(i).BoundingBox(1), status(i).BoundingBox(2), num2str(count),'color', 'r');
                AllCount = AllCount + count;
            else
                count = 1;
                rectangle('position', status(i).BoundingBox, 'edgecolor', 'b');
%                 text(status(i).BoundingBox(1), status(i).BoundingBox(2), num2str(1),'color', 'r');
                AllCount = AllCount + count;
                ValidCellIndex(i) = 1;
            end
    %         end
        end
        else 
            for i = 1: TotalCon


                if AllAreaList(i) > 2*AveargeArea
                    count = round(AllAreaList(i)/AveargeArea);
                    AllCount = AllCount + count;

                else
%                     SumArea = SumArea + AllAreaList(i);
%                     ValidAreaCount = ValidAreaCount +1;
                    count = 1;
                    AllCount = AllCount + count;
                end

            end

        end
       
        %% 

        SumArea = sum(AllAreaList) + SumArea;
        
        if IfSaveSegCell 
            FilledImgList = {status.FilledImage};
            SaveNum =10;
            SaveSegCellPth = 'F:\DPC_experimental_data\MICRO-RawData\Demo\SegResults\SegCells\';
            for k = 100:SaveNum
                BBox = BoundingBoxList{k};
%                 Left
            end
            
        end
        
        end
        MeanC = AllCount/ImgNum;
        
         %% 写入指定文本
         
        if IfSaveCount
            
            f = fopen(SaveTxtPth, 'a');
            fprintf(f,'%s\t %s  \t \n',SampleFileName{k}, num2str(MeanC));
            fclose(f);
            disp(['data of',' ', SampleFileName{k}, ' ', 'is saved']);
        end
        
        if IfSaveArea
            
            MeanArea = SumArea/AllCount;
            f1 = fopen(SaveAreaPth,'a');
            fprintf(f1,'%s\t %s  \t \n',SampleFileName{k}, num2str(MeanArea));
            fclose(f1);
            disp(['data of',' ', SampleFileName{k}, ' ', 'is saved']);
        end
    end
    end
end
toc
