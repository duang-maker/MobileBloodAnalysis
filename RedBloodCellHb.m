%% used for analysis RBC Hb and area. Compile the regular microscope (40X, 0.95NA) and the micro scope (after upsamsple)
%% handle MULTIPLE SAMPLES 
% SAMPLE PATH IS TEH PATH FOR TEH DIR FILE 
tic % start time
SamplePath = 'H:\DPC_experimental_data\MICRO-RawData\'; %
% SamplePath = 'H:\DPC_experimental_data\gaofenbianmozu\test\'; %
% Sample= {'1_1','1_3','1_4','1_5','1_6','1_7','1_8','1_9','1_10','1_13','1_15','1_16','2_10','2_12','3_G004_5459'};
% % Sample = {'1_1','1_3','1_4','1_5','1_6','1_7','1_8','1_9','1_10','1_13','1_15','1_16','2_10','2_12','3_G004_5459', ...
% %    '1_16_region2', '1_1_S1', '1_1_S2', '1_1_S3','1_4_S1', '-1_4_S2', '1_9_S1', '1_9_S2', '2_12_S1', '2_12_S2', '2_2', '2_4', ...
% %    '3_G051_2063', 'C', 'C2', 'X', 'X2'};
Sample = {'1_5'};
% Sample= {'Red4'};
IfMicro = 1; % if the input is the mini microscope image Yes:1 No:0
SaveMass = 0;
SaveBGNorm = 0;
SaveMean = 1; % if save the mean Hb or area of RBCs for each sample Choose 1 for Y, 0 for N
VisualizeSeg =0; % if visualizing the segmentation results
SaveHbList =0; % if save the sample RBCs Hb list into a excel
SaveAreaList =0;  % if save the sample RBCs Areas list into a excel
meantxtname =  'ForTestTime.txt'; % the save path of mean Hb and Area
HbListFile = 'Hb_1_4_1_13S1.xlsx';
AreaListFile = 'Area_1_4_1_13_S2.xlsx';

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
        if ismember(SampleFileName{k},Sample)
  % 背景归一化函�?
%     ImgPath = 'D:\duan\�?��\记录\红细胞指标检测篇\data\1_2\';
    SampleFileName{k}
%     ImgPath = [SamplePath,SampleFileName{k}, '\','Test\']; % Image path for each sample
    ImgPath = [SamplePath,SampleFileName{k}, '\','CalHb\']; % Image path for each sample
    SaveBGNormPath = [ImgPath, 'BGNorm\'];
    SaveMassDensityPath = [ImgPath, 'MassDensity\'];
    
    %%
    Extinction = 363848; % L/cm mol 
    Molar = 64500; % molar mass unit (g/mol)
    Ebsilon = 0.01;

%     if ~exist(SavePath)
%         mkdir(SavePath);
%     end
    
    ImgFile = dir([ImgPath, type]);
    name = {ImgFile.name};
    ImgNum = length(name);
    % SampleHbList
    for i = 1: ImgNum
%     for i = 1: 1
        ImgColor = imread([ImgPath, name{i}]); 
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
        LimitC = length(Pos);
        C = min(LimitC, 8); % Campare Range
%         C = 8; % Campare Range
        BGGray = max(Maximuns(Pos(1:C)));
        % Mormalizing the image 
        NormalVale = 170;
        
    %     TheMaxIndex = find(Value_Index == max(Value_Index));
%         if Maximuns(Pos(1))> Maximuns(Pos(2))
%             BGGray = Maximuns(Pos(1));
%         else
%             BGGray = Maximuns(Pos(2));
%         end
        
        % Mormalizing the image 
%         NormalVale = 230;
        ImgGreenNorm = ImOneChannel.*(NormalVale/BGGray);
        % 计算干质量密�?
        [H,W] = size(ImOneChannel);
        I0 = ones(H, W).*(NormalVale/BGGray);
        Mass_Density = MassDensity(ImgGreenNorm,I0, Extinction, Molar);
%         figure; imshow(Mass_Density);
        if SaveMass
            if ~exist(SaveMassDensityPath)
                mkdir(SaveMassDensityPath);
            end
            imwrite(Mass_Density, [SaveMassDensityPath, name{i}]);
        end
        if SaveBGNorm
            if ~exist(SaveBGNormPath)
                mkdir(SaveBGNormPath);  
            end
            imwrite(ImgGreenNorm, [SaveBGNormPath, name{i}]);
        end
        % computer the RBCs para from one image
        [HbList, AreaList, MeanHb, MeanArea,SegmentResult] = GetSingleErySta(Mass_Density, VisualizeSeg, SampleFileName{k},IfMicro);
        if i ==1
            TotalHb = HbList;
            TotalArea = AreaList;
        else
            TotalHb = [TotalHb, HbList];
            TotalArea = [TotalArea, AreaList];
        end

    %     imwrite(Mass_Density, [SavePath, name{i}]);
    %     figure;imshow(ImgGreenNorm);
    %     GMMModal = fitgmdist(double(ImgGreenChannel(:)), 2);
    % 高斯混合模型
    %     Mu_BG = GMMModal.mu(2);

    %     figure; plot(gray,num);
    %     figure; imhist(ImgGreenChannel);
    %     figure; imshow(ImgGreenNorm);
    end
%     TotalHb = rmoutliers(TotalHb, 'quartiles');
%     TotalArea = rmoutliers(TotalArea, 'quartiles');
    MeanofTotalHb = mean(TotalHb);
    MeanofTotalArea = mean(TotalArea);
    %% 写入指定文本
    Tag =1;
    if SaveMean
        MeanValueTxt = ['H:\DPC_experimental_data\MICRO-RawData\StaRedBloodCell\RBCHb\RawTxt\',meantxtname];
%         MeanValueTxt = [ImgPath, meantxtname];
        f = fopen(MeanValueTxt, 'a');
        if Tag
            fprintf(f,'% \t %s \t %s\n','Sample','Hb', 'Area');
            Tag = 0;
        end
        fprintf(f,'%s \t %s \t %s\n',SampleFileName{k}, num2str(MeanofTotalHb),num2str(MeanofTotalArea));
        fclose(f);
    end
    %%  将单细胞Hb数据写入表格
    if SaveHbList
        HbPath = [SamplePath,'StaRedBloodCell\RBCHb\RawTxt\', HbListFile];
        SampleName = SampleFileName{k};
        if ~exist(HbPath, 'file')
            xlswrite(HbPath, TotalHb, 'sheet1','A1' );
        else
            existdata = xlsread(HbPath);
            [m,n] = size(existdata);
%             [ndata, mdata]=size(TotalHb);
            xlswrite(HbPath, TotalHb, 'Sheet1',['A',num2str(m+1)] );
        end
    end
    %%   将单细胞Area数据写入表格
    if SaveAreaList
        AreaPath = [SamplePath,'StaRedBloodCell\RBCHb\RawTxt\', AreaListFile];
        SampleName = SampleFileName{k};
        if ~exist(AreaPath, 'file')
            xlswrite(AreaPath, TotalArea, 'sheet1','A1' );
        else
            existdata = xlsread(AreaPath);
            [m,n] = size(existdata);
%             [ndata, mdata]=size(TotalArea);
            xlswrite(AreaPath, TotalArea, 'Sheet1',['A',num2str(m+1)] );
        end
    end
        end
    
    end
end
toc

