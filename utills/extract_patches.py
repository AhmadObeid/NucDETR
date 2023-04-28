"""extract_patches.py

Patch extraction script.
"""

import re
import glob
import os
import tqdm
import pathlib

import numpy as np

from misc.patch_extractor import PatchExtractor
from misc.utils import rm_n_mkdir, mkdir

from dataset import get_dataset
import pdb
from PIL import Image
import scipy.io as sio
# -------------------------------------------------------------------------------------
def extract_mask(img,directory,file_name):
    mask = img[:,:,3]
    mkdir(directory+'/mask_info/')
    sio.savemat(directory+'/mask_info/'+file_name+'.mat',{'mask':mask})
    
def binarize(mask):
    non_zeroIdx = np.where(mask>0)[0]
    mask[non_zeroIdx] = 1
    return mask

if __name__ == "__main__":
    extract_mask_only = False
    typ = "Positive"
    
    # Determines whether to extract type map (only applicable to datasets with class labels).
    type_classification = True

    win_size = [300, 300]
    step_size = [164, 164]
    extract_type = "mirror"  # Choose 'mirror' or 'valid'. 'mirror'- use padding at borders. 'valid'- only extract from valid regions.

    # Name of dataset - use Kumar, CPM17 or CoNSeP.
    # This used to get the specific dataset img and ann loading scheme from dataset.py
    dataset_name = "consep"
    save_root = "F:/%s"% dataset_name

    # a dictionary to specify where the dataset path should be
    dataset_info = {
        "train": {
            "img": (".png", "F:/CRCDatasets/"+dataset_name+"/train/Images"+typ[0]+"/"),
            "ann": (".mat", "F:/CRCDatasets/"+dataset_name+"/train/Labels/"),
        },
        "val": {
            "img": (".png", "dataset/"+dataset_name+"/val/Images"+typ[0]+"/"),
            "ann": (".mat", "dataset/"+dataset_name+"/val/Labels/"),
        },
    }

    patterning = lambda x: re.sub("([\[\]])", "[\\1]", x)
    parser = get_dataset(dataset_name)
    xtractor = PatchExtractor(win_size, step_size)
    for split_name, split_desc in dataset_info.items():
        img_ext, img_dir = split_desc["img"]
        ann_ext, ann_dir = split_desc["ann"]

        out_dir_imgs = "%s/Images/%dx%d_%dx%d/%s/%s/" % (
            save_root, 
            win_size[0],
            win_size[1],
            step_size[0],
            step_size[1],
            split_name,
            typ,
            
        )
        out_dir_masks = "%s/masks/%dx%d_%dx%d/%s/%s/" % (
            save_root, 
            win_size[0],
            win_size[1],
            step_size[0],
            step_size[1],
            split_name,
            typ,
            
        )
        
        file_list = glob.glob(patterning("%s/*%s" % (ann_dir, ann_ext)))
        file_list.sort()  # ensure same ordering across platform

        mkdir(out_dir_imgs)
        mkdir(out_dir_masks)

        pbar_format = "Process File: |{bar}| {n_fmt}/{total_fmt}[{elapsed}<{remaining},{rate_fmt}]"
        pbarx = tqdm.tqdm(
            total=len(file_list), bar_format=pbar_format, ascii=True, position=0
        )

        for file_idx, file_path in enumerate(file_list):
            base_name = pathlib.Path(file_path).stem

            img = parser.load_img("%s/%s%s" % (img_dir, base_name, img_ext))
            ann = parser.load_ann(
                "%s/%s%s" % (ann_dir, base_name, ann_ext), type_classification
            )

            # *
            img = np.concatenate([img, ann], axis=-1)
            if extract_mask_only:
                extract_mask(img,
                                 img_dir[:-7],
                                 base_name)
                continue
        
            sub_patches = xtractor.extract(img, extract_type)

            pbar_format = "Extracting  : |{bar}| {n_fmt}/{total_fmt}[{elapsed}<{remaining},{rate_fmt}]"
            pbar = tqdm.tqdm(
                total=len(sub_patches),
                leave=False,
                bar_format=pbar_format,
                ascii=True,
                position=1,
            )

            for idx, patch in enumerate(sub_patches):                
                patch_im = patch[:,:,:3].astype('uint8')
                mask = patch[:,:,3]
                if sum(patch[:,:,-1].flatten()) == 0 and typ == "Positive":
                    print('this patch ({0}) is empty\n'.format(idx))
                    continue
                
                patch_im =  Image.fromarray(patch_im,mode="RGB")
                
                
                patch_im.save("{0}_{1:03d}.jpeg".format(out_dir_imgs+base_name+typ[0], idx))
                if typ == "Positive":
                    sio.savemat("{0}_{1:03d}.mat".format(out_dir_masks+base_name+typ[0], idx),{'mask':mask})
                
                # np.save("{0}/{1}_{2:03d}.npy".format(out_dir, base_name, idx), patch)
                
                
                pbar.update()
            pbar.close()
            # *

            pbarx.update()
        pbarx.close()
