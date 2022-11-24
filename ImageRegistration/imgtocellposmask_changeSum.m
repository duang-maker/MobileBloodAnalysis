function posmask = imgtocellposmask_changeSum(imgpath, resizefactor, imgtype, Rmin, Rmax)
% NolabelPath = grayimgpath;

img = imread(imgpath);
if length(size(img)) ==3
    Gray1 = im2double(rgb2gray(img));
else
    Gray1 = im2double(img);
end
if strcmp(imgtype,'nolabel') 
    Gray = imcrop(Gray1, [48 48 415 415]);
%     [H,W]= size(Gray);
%     disp(H);disp(W);
%     figure; imshow(Gray); title('Gray');
else
    Gray = Gray1;
end
% Gray = im2double(rgb2gray(imgpath));
% nolabelGrayMed = medfilt2(nolabelGray,[10,10],'symmetric');
grayresize = imresize(Gray, resizefactor);
[centers, radii, ~] = imfindcircles(grayresize,[Rmin Rmax], 'Sensitivity',0.95 ,...
'ObjectPolarity','dark', 'Method','TwoStage');
% figure;imshow(nolabelGrayMed);
% viscircles(centers, radii,'EdgeColor','b');
% radii
[centers, radii] = choosecir_changeSum(grayresize, centers,radii,imgtype);
% figure;imshow(grayresize);
% viscircles(centers, radii,'EdgeColor','b');
posmask = obtainmaskofcir(grayresize, centers, radii);

% figure; imshowpair(grayresize,posmask,'falsecolor');