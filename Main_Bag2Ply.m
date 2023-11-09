DataFolder='F:\Lettuce\Piikkio_2023\2023_04_04_Day_21\';
% DataFolder='F:\Lettuce\Piikkio_2023\2023_05_16_Day_21\';

s_Prog='C:\"Program Files (x86)"\"Intel RealSense SDK 2.0"\tools\rs-convert.exe  ';
% https://github.com/IntelRealSense/librealsense/tree/master/tools/convert
FolderList=dir(DataFolder);
for FolderList_i=4:length(FolderList)
    FolderName=FolderList(FolderList_i).name;
    if ~isfolder([DataFolder FolderName])
        continue;
    end
  
    FileList=dir([DataFolder FolderName]);
    BagFileList={}; BagN=0;
    for File_i=3:length(FileList)
        FileName=FileList(File_i).name;
        if contains(FileName,'.bag')
            BagN=BagN+1;
            BagFileList{BagN}=FileName;
        end
    end
    if BagN==4
        fi=0;
    elseif BagN==1
        fi=3;
    end
    for File_i=1:BagN
        FileName=BagFileList{File_i};
        fi=fi+1;
        s_BagName=[' -i ' DataFolder FolderName '\' FileName];
        s_PlyName=[' -l ' DataFolder FolderName '\' 'Cam' num2str(fi)];
        s_RGBName=[' -p ' DataFolder FolderName '\' 'Cam' num2str(fi)];
        s_DepthName=[' -b ' DataFolder FolderName '\' 'Cam' num2str(fi)];
        status=system([s_Prog s_BagName s_PlyName s_RGBName s_DepthName]);
    end
    FileList=dir([DataFolder FolderName]);
    col_f=ones(4,1);
    ply_f=ones(4,1);
    dep_f=[0 0 0 1];
    depg_f=[0 0 0 1];
    for File_i=3:length(FileList)
        FileName=FileList(File_i).name;
        if contains(FileName,'.txt')
            delete([DataFolder FolderName '\' FileName]);
        end
        if contains(FileName,'_Color_') && contains(FileName,'.png')
            k=str2num(FileName(4));
            if col_f(k)==0
                delete([DataFolder FolderName '\' FileName]);
            else
                movefile([DataFolder FolderName '\' FileName],[DataFolder FolderName '\' 'Cam' FileName(4) '.png']);
                col_f(k)=0;
            end
        end
        
        if contains(FileName,'.ply')
            k=str2num(FileName(4));
            if ply_f(k)==1
                movefile([DataFolder FolderName '\' FileName],[DataFolder FolderName '\' 'Cam' FileName(4) '.ply']);
                ply_f(k)=0;
            else
                delete([DataFolder FolderName '\' FileName]);
            end
        end

        if contains(FileName,'_Depth') && contains(FileName,'.bin')
            k=str2num(FileName(4));
            if dep_f(k)==1
                D=ReadDepthBin([DataFolder FolderName '\'],FileName,1280,720);
                imwrite(D,[DataFolder FolderName '\' 'Depth' FileName(4) '_Gray.png']);
                movefile([DataFolder FolderName '\' FileName],[DataFolder FolderName '\' 'Depth' FileName(4) '.bin']);
                dep_f(k)=0;
                D=uint16((h_WUR-D+h_Pii)*1000);
                imwrite(D,[DataFolder FolderName '\' 'Depth4.png']);
            else
                delete([DataFolder FolderName '\' FileName]);
            end
        end
        if contains(FileName,'_Depth') && contains(FileName,'.png')
            delete([DataFolder FolderName '\' FileName]);
        end
    end
end
% load gong.mat
% sound(y)