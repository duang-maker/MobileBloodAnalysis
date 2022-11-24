function [HbList, AreaList, MeanHb, MeanArea,SegmentResult] = GetSingleErySta(MassDensity, VisualizeSeg, name, IfMicro)
    
    %%  阈�?设置
    UpAreaThresh = 8000; %5000
    LowAreaThresh = 1000; % 500
    CircularityThresh = 0.5;
    ExtentThresh = 0.3;
    fillholeArea = 600;
    meanfilter = fspecial('average',[3,3]);
    WholeMass = imfilter(MassDensity, meanfilter);
%%
% otsu segmentation
    thresh = graythresh(WholeMass)-0.015;
%     thresh = graythresh(MassDensity);
    WholeMassBW = imbinarize(MassDensity, thresh);
%     figure;imshow(WholeMassBW);
    % title('Otsu');

    % open operation
    se = strel('disk',2);
    WholeMassDilate = WholeMassBW;
%     WholeMassDilate = imopen(imclose(WholeMassBW,se),se);
%     WholeMassDilate = imclose(imopen(WholeMassBW,se),se);
    % figure;imshow(WholeMassDilate);
    % title('morph');

    % fill hole area<=300
    WholwMassOverFilled = imfill(WholeMassDilate, 'holes');
    AllHoles = WholwMassOverFilled  & ~ WholeMassDilate;
    ValidHoles= bwRemoveLargeArea(AllHoles,fillholeArea,8);
    % figure;
    % subplot(1,2,1);imshow(AllHoles);
    % subplot(1,2,2);imshow(ValidHoles);
    WholeMassFill =  WholeMassDilate | ValidHoles;
%     figure;imshow(WholeMassFill); title('after first fill')
    % WholeMassErode = imerode(WholeMassFill,se);
    % subplot(2,2,4);imshow(WholeMassErode);
    WholeMassFill = imfill(WholeMassFill, 'holes');
%     figure; imshow(WholeMassFill);
    % watershed operation
    D = bwdist(~WholeMassFill);
    % figure;
    % subplot(1,2,1);imshow(D,[],'InitialMagnification','fit');
    D=-D;
    % D(~WholeMassErode) =-Inf;
    mask=imextendedmin(D,2);
    D2=imimposemin(D,mask);
    Ld=watershed(D2);
    Water_splited=WholeMassFill;
    Water_splited(Ld==0)=0;
    %进行watershed分割并将分割结果以标记图形式绘出
    % L=watershed(D,8);
    % rgb = label2rgb(Ld,'jet',[.5 .5 .5]);
    % figure;imshow(Water_splited,'InitialMagnification','fit');

    % fill holes after watershed
    Water_splited_fill = imfill(Water_splited,'hole');
%     figure; imshow(Water_splited_fill); title('open\_close')
    % final = imopen(imclose(Water_splited_fill,se),se);
    % figure; imshow(final);title('finals');
    %% delete area with abnormal area
    % �?��连�?�?
    [l,~] = bwlabel(Water_splited_fill);
    status = regionprops(l, 'Area', 'BoundingBox', 'Circularity', 'Extent', 'FilledImage');
%     status = regionprops(l, 'Area', 'BoundingBox', 'Extent', 'FilledImage');
    % status = regionprops(l, 'all');
    if IfMicro
        S_Seg = strel('disk',9);
        SegmentResult = imerode(Water_splited_fill,S_Seg);
    else
        SegmentResult = Water_splited_fill;
    end
    %% 
    AllAreaList = [status.Area];
%     CircularityList = [status.Circularity];
    BoundingBoxList = {status.BoundingBox};
%     ExtentList = [status.Extent];
    TotalCon = length(AllAreaList);


    
    %% 可视�?
    if VisualizeSeg
        figure; imshow(SegmentResult); title(name);
        hold on;
        for i = 1: TotalCon
            if (AllAreaList(i) < UpAreaThresh) && (AllAreaList(i) > LowAreaThresh) && (status(i).Circularity > CircularityThresh)  && (status(i).Extent > ExtentThresh)
%             if (AllAreaList(i) < UpAreaThresh) && (AllAreaList(i) > LowAreaThresh) && (status(i).Extent > ExtentThresh)
                rectangle('position', status(i).BoundingBox, 'edgecolor', 'r');
                text(status(i).BoundingBox(1), status(i).BoundingBox(2), num2str(i),'color', 'r');
            end
        end
%         figure;imshowpair()
    end
    %% 
    CellIndex = zeros(1,TotalCon);
    for i = 1: TotalCon
        if (AllAreaList(i) < UpAreaThresh) && (AllAreaList(i) > LowAreaThresh) &&  (status(i).Extent > ExtentThresh && (status(i).Circularity > CircularityThresh))
%         if (AllAreaList(i) < UpAreaThresh) && (AllAreaList(i) > LowAreaThresh) && (status(i).Circularity > CircularityThresh)  && (status(i).Extent > ExtentThresh)
            CellIndex(i) = 1; % 筛�?出的细胞区域
        end
    end
    %% 统计每个细胞Hb 含量

    CellNum = sum(CellIndex);
    CellHb = zeros(1,CellNum);
    CellArea = zeros(1,CellNum);
    PixelArea = (4.8/40)^2;
    c = 1;
    for i = 1:TotalCon
        if CellIndex(i) ==1
            Yup = ceil(BoundingBoxList{i}(2));
            Ydown = ceil(BoundingBoxList{i}(2)) + BoundingBoxList{i}(4)-1;
            Xleft = ceil(BoundingBoxList{i}(1));
            Xright = ceil(BoundingBoxList{i}(1)) + BoundingBoxList{i}(3)-1;
            Cell = MassDensity(Yup: Ydown, Xleft: Xright);
            HbDensity = double(Cell).*status(i).FilledImage;
            temp = HbDensity*PixelArea;
            HbContent = sum(sum(temp));
            CellHb(c) =  HbContent;
            CellArea(c) = AllAreaList(i)*PixelArea;
            c = c+1;
        end
    end

    %% 去掉离群点，计算均�?
    % boxplot(CellHb);

    [HbList, RMIndex] = rmoutliers(CellHb);
    AreaList = CellArea(~RMIndex);
    MeanHb = mean(HbList);
    MeanArea = mean(AreaList);
%     boxplot(CellHbValid);

end