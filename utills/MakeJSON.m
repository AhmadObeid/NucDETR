% This script generates .JSON files for the annotation of the histo. images
% per the form required by the DETR authors. Done by Ahmad Obeid as part of
% his PhD work. Under the supervison of Dr. Naoufel, Dr. Sajid, and Dr.
% Jorge

clear;
fls = {'train','val'};
fl_cnt = [0,10000];
for fl = [1,2]
    fileID = fopen(['instances_',fls{fl},'2017.json'],'W');
    
    fprintf(fileID,'{\n');
    fprintf(fileID,[jsonencode("info"),': {\n',jsonencode("description"),': ',...
        jsonencode("Histopathology Detection Dataset"),',\n',...
        jsonencode("url"),': ',jsonencode("www.ku.ac.ae"),',\n',jsonencode("version"),...
        ': ',jsonencode("1.0"),',\n',jsonencode("year"),': 2021,\n',jsonencode("contributor"),...
        ': ', jsonencode("Ahmad Obeid, member of Dr. Naoufel's research group at KU"),...
        ',\n',jsonencode("date_created"),': ', jsonencode("2021"),'}\n,\n']);
    
    
    fprintf(fileID,[jsonencode("licenses"),': [{\n',jsonencode("url"),': ',...
        jsonencode("http://creativecommons.org/licenses/by-nc-sa/2.0/"),...
        ',\n',jsonencode("id"),': 1,\n',jsonencode("name"),': ',...
        jsonencode("Attribution-NonCommercial-ShareAlike License"),'},\n']);
    fprintf(fileID,['{\n',jsonencode("url"),': ',...
        jsonencode("http://creativecommons.org/licenses/by-nc-sa/2.0/"),...
        ',\n',jsonencode("id"),': 2,\n',jsonencode("name"),': ',...
        jsonencode("Attribution-NonCommercial-ShareAlike License"),'},\n']);
    fprintf(fileID,['{\n',jsonencode("url"),': ',...
        jsonencode("http://creativecommons.org/licenses/by-nc-sa/2.0/"),...
        ',\n',jsonencode("id"),': 3,\n',jsonencode("name"),': ',...
        jsonencode("Attribution-NonCommercial-ShareAlike License"),'},\n']);
    fprintf(fileID,['{\n',jsonencode("url"),': ',...
        jsonencode("http://creativecommons.org/licenses/by-nc-sa/2.0/"),...
        ',\n',jsonencode("id"),': 4,\n',jsonencode("name"),': ',...
        jsonencode("Attribution-NonCommercial-ShareAlike License"),'}],\n\n']);
    
    fprintf(fileID,[jsonencode("images"),': [\n']);
    images_files = natsortfiles(dir(['./',fls{fl},'/*.jpg']));
    for i = 1:length(images_files)
        nam = images_files(i).name;
        C = strsplit(nam,'_');
        pic_name = C{1}; patch_num = C{2};
        fprintf(fileID,['{\n',jsonencode("lisence"),': 1,\n',jsonencode("file_name"),...
            ': ',jsonencode(nam),',\n',...        
            jsonencode("height"),': ','512,\n',jsonencode("width"),...
            ': 512',',\n',jsonencode("date_captured"),': ',jsonencode("2021"),',\n',...        
            jsonencode("id"),': ',num2str(fl_cnt(fl)+i),'\n},\n']);
        %jsonencode("coco_url"),': ',jsonencode("www.ku.ac.ae"),',\n',...
        %jsonencode("flicker_url"),': ',jsonencode("www.ku.ac.ae"),',\n',...
        
    end
    fprintf(fileID,'],\n');
    fprintf(fileID,[jsonencode("annotations"),': [\n']);
    id_cnt = 1;
    for j = 1:length(images_files)
        nam = images_files(j).name;
        C = strsplit(nam,'_');
        pic_name = C{1}; patch_num = C{2};
        load(['../Patches3/',pic_name,'/bbStructs/',patch_num,'.mat'])
        for k = 1:length(BB_struct0)
            bb_info = BB_struct0(k).BoundingBox;
            x1 = bb_info(1)-0.5; y1 = bb_info(2)-0.5; width = bb_info(3); height = bb_info(4);
            x2 = x1+width; y2 = y1+height;
            %the above is python form for x1 and y1
            
            fprintf(fileID,...
            [',\n{\n',jsonencode("segmentation"),': ',...
            '[[',num2str(x1),',',num2str(y1),',',num2str(x2),',',num2str(y1),',',...
            num2str(x2),',',num2str(y2),',',num2str(x1),',',num2str(y2),']],\n',...
            jsonencode("area"),': 1000,\n',jsonencode("iscrowd"),...
            ': 0,\n',jsonencode("image_id"),': ',num2str(fl_cnt(fl)+j),',\n',jsonencode("bbox"),': ',...
            '[',num2str(x1),',',num2str(y1),',',num2str(width),',',num2str(height),...
            '],\n',...
            jsonencode("category_id"),': 1,\n',jsonencode("id"),': ',num2str(id_cnt+5000+fl_cnt(fl)),'}\n']);
            id_cnt = id_cnt + 1;
        end
        for k = 1:length(BB_struct1)
            bb_info = BB_struct1(k).BoundingBox;
            x1 = bb_info(1)-0.5; y1 = bb_info(2)-0.5; width = bb_info(3); height = bb_info(4);
            x2 = x1+width; y2 = y1+height;
            %the above is python form for x1 and y1
            
            fprintf(fileID,...
            [',\n{\n',jsonencode("segmentation"),': ',...
            '[[',num2str(x1),',',num2str(y1),',',num2str(x2),',',num2str(y1),',',...
            num2str(x2),',',num2str(y2),',',num2str(x1),',',num2str(y2),']],\n',...
            jsonencode("area"),': 1000,\n',jsonencode("iscrowd"),...
            ': 0,\n',jsonencode("image_id"),': ',num2str(fl_cnt(fl)+j),',\n',jsonencode("bbox"),': ',...
            '[',num2str(x1),',',num2str(y1),',',num2str(width),',',num2str(height),...
            '],\n',...
            jsonencode("category_id"),': 2,\n',jsonencode("id"),': ',num2str(id_cnt+5000+fl_cnt(fl)),'}\n']);
            id_cnt = id_cnt + 1;
        end
        
    end
    fprintf(fileID,'],\n');
    fprintf(fileID,[jsonencode("categories"),': \n[\n{\n',...
        jsonencode("supercategory"),': ',jsonencode("histo"),',\n',...
        jsonencode("id"),': 1,\n',...
        jsonencode("name"),': ',...
        jsonencode("normal"),'\n','},\n']);
    fprintf(fileID,['{\n',jsonencode("supercategory"),': ',jsonencode("histo"),',\n',...
        jsonencode("id"),': 2,\n',...
        jsonencode("name"),': ',...
        jsonencode("tumor"),'\n}\n]}\n']);
    
    
    fclose(fileID);
end

