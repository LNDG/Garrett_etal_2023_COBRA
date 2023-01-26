function [ nii2Dmatrix ] = S_nii4dto2d ( nii4Dstruct )
%From 4D NIFTI structure to 2D data matrix
%   Quick function to reshape a 4D NIFTI data matrix, embedded in a NIFIT
%   structure. Returns just the 2D matrix, voxel by time.
%       Input:      Must be NIFIT structure from load_nii (https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image/content/load_nii.m)
%       Output:     2D matrix. Space (rows) by time (colums), if input was XYZ space by time.


if nii4Dstruct.hdr.dime.dim(1) == 4
    
    disp (sprintf (['\nInput is 4D. Dimensions = ', num2str(nii4Dstruct.hdr.dime.dim(2:5))]));
    nii2Dmatrix = reshape (nii4Dstruct.img, [], nii4Dstruct.hdr.dime.dim(5));
    disp (sprintf (['Outout reshaped to: ', num2str(size(nii2Dmatrix)), '\n']));
    
else error (['Input not 4D! Input has ',  num2str(nii4Dstruct.hdr.dime.dim(1)), ' dimensions instead...'])
    
end
end

