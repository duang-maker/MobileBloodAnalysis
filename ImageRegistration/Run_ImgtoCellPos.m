addpath(genpath('C:\Users\Admin\Nutstore\1\ÑªÏ¸°û¼ì²âÏà¹Ø\code\matlab\register'))

SavePath = 'F:\blood_smear_project\TJ_Sed12\LabelWBC_Left\PosMskOfStainWBC\';
FileList = dir([LabelPath,'*.bmp']);
LabelNum = length(FileList);
LabelName = {FileList.name};
resizefactor = 1/4;
for i = 1:LabelNum
     LabelImgPath = [LabelPath,LabelName{i}];
     labelposmask = imgtocellposmask_changeSum( LabelImgPath , resizefactor,'label', 6, 12);
     imwrite(labelposmask, [SavePath, LabelName{i}]);
end