function volume = computeVolume(filePath)

addpath('/home/charlesiglehart/Documents/Research/comparisonStudy/code/NIfTI_20140122');
nii = load_untouch_nii(filePath);
img = nii.img;
n = numel(find(img > 0));

volume = nii;
end