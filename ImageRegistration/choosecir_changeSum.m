function [ oldcenter, oldradii] = choosecir_changeSum(grayimg, oldcenter, oldradii,choose)
    [height, width] = size(grayimg);
    [W, H] = meshgrid(1:width, 1:height);
    labelcirnum = length(oldcenter);
    graylist = zeros(labelcirnum,1);
    for i =1 :labelcirnum
        circle = ((W-oldcenter(i,1)).^2 + (H-oldcenter(i,2)).^2 < oldradii(i)^2);
        graycir = grayimg.*circle;
    %     graysum = sum(labelcir,'all');
    %     area = sum(circle,'all');
        avegray = sum(sum(graycir))/ sum(sum(circle));
        graylist(i)=avegray;
    %     figure;imshow( labelcir);
    end
    meangraylist = mean( graylist);
    if strcmp(choose,'label')
        deletindex = find(graylist<(meangraylist*0.90));
        
    elseif strcmp(choose,'nolabel')
        deletindex = find(graylist>(meangraylist*1.2));
    end
    oldcenter(deletindex,:)=[];
    oldradii(deletindex,:)=[];
   
end