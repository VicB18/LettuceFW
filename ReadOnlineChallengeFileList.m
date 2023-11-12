function L=ReadOnlineChallengeFileList(DataFolder)
L=struct([]);
LN=0;

text=fileread([DataFolder '\' 'GroundTruth\GroundTruth_All_388_Images.json']);
value=jsondecode(text);
FileList=fieldnames(value.Measurements);

for FileList_i=1:length(FileList)
    if isfile([DataFolder 'RGBImages\RGB_' FileList{FileList_i}(6:end) '.png'])
        R=eval(['value.Measurements.' FileList{FileList_i}]);
        if 1%contains(R.Variety,'Aphylion')% || contains(R.Variety,'Lugano')
            LN=LN+1;
            L(LN).Path=[DataFolder 'DepthImages\'];
            L(LN).TransformationQ=[0 0 0.9 0 0 0];
            L(LN).Date='';
            L(LN).FileName{1}=R.Depth_Information;
            L(LN).Path1=[DataFolder 'RGBImages\'];
            L(LN).FileName1{1}=R.RGB_Image;
            L(LN).PlantNo=R.Depth_Information(7:(strfind(R.Depth_Information,'.')-1));
            L(LN).CameraN=1;
            L(LN).RefFreshWeight=R.FreshWeightShoot;
            L(LN).Variety=R.Variety;
        end
    end
end
