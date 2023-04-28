% This script takes segmentation mask patches and extracts BBs from them,
% overlays the result on each patch, and the WSI patches, and saves these as images,
% and also saves the normalized locations of the BBs in each patch. 
% The patches are extracted from the python script patch_division.py
clear; close all
draw = false;

folders = dir('./');
for f_count = 4:length(folders)
    folder_name = folders(f_count).name;
    files = natsortfiles(dir([folder_name,'/masks/*.tiff']));
    if ~exist([folder_name,'/bbStructs'],'dir')
        mkdir([folder_name,'/bbStructs'])
    end
    if ~exist([folder_name,'/bb_mask'],'dir')
        mkdir([folder_name,'/bb_mask'])
    end
    if ~exist([folder_name,'/bb_wsi'],'dir')
        mkdir([folder_name,'/bb_wsi'])
    end

    for i = 1:length(files)
        if mod(i,100)==0
            fprintf("finished %d patch\n ",i)
        end

        name = files(i).name;
        xmask = imread([folder_name,'/masks/',name]);
        wsi = imread([folder_name,'/wsi/',name]);
    %     figure()
    %     imshow(xmask)    

        xbin = double(xmask);    
        x1 = xbin; x0 = xbin;
    %     [h,a] = hist(xbin(:));
    %     mid = a(round(length(a)/2));
        x1(x1<200)=0; x1(x1>200)=1;
        x0(x0>200)=0; x0(logical((x0<200).*(x0>0)))=1;
        
        
        CC1 = bwconncomp(x1,4); CC0 = bwconncomp(x0,4);
        BB_struct1 = regionprops(CC1,'BoundingBox');
        BB_struct0 = regionprops(CC0,'BoundingBox');

        save([folder_name,'/bbStructs/',name(1:length(name)-5),'.mat'],'BB_struct1','BB_struct0')
        if ~draw 
            continue;
        else
        
            f = figure('visible','off');%
            imshow(xmask,'Border','tight')
    
            hold on
            for j = 1:length(BB_struct0)
                rectangle('Position', BB_struct0(j).BoundingBox,'EdgeColor','b','LineWidth',2) ;
            end
            for j = 1:length(BB_struct1)
                rectangle('Position', BB_struct1(j).BoundingBox,'EdgeColor','r','LineWidth',2) ;
            end            
            hold off 

            % trying qudatree
%             S = qtdecomp(xbin,0.1);
%             blocks = repmat(0,size(S));
%             for dim = [512 256 128 64 32 16 8 4 2 1];    
%                 numblocks = length(find(S==dim));
%                 if (numblocks > 0)        
%                     values = repmat(1,[dim dim numblocks]);
%                     values(2:dim,2:dim,:) = 0;
%                     blocks = qtsetblk(blocks,S,dim,values);
%                 end
%             end
%             blocks(end,1:end) = 1;
%             blocks(1:end,end) = 1;
%             figure
%             imshow(blocks,[])
            % end of trying quadtree

            saveas(f,[folder_name,'/bb_mask/',name(1:length(name)-5)],'jpg');
    
            f2 = figure('visible','off');
            imshow(wsi,'Border','tight')
            hold on
            for j = 1:length(BB_struct0)
                rectangle('Position', BB_struct0(j).BoundingBox,'EdgeColor','b','LineWidth',2) ;
            end
            for j = 1:length(BB_struct1)
                rectangle('Position', BB_struct1(j).BoundingBox,'EdgeColor','r','LineWidth',2) ;
            end 
            hold off
            saveas(f2,[folder_name,'/bb_wsi/',name(1:length(name)-5)],'jpg');
        end
        
    end
    
end
