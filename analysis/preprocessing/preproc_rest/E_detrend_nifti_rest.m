function E_detrend_nifti_rest
%% Load Detrend and Save a Nifti
%   load nifti and reshap it to voxel x time
%   Input: 
%   - DATAPATH: Folderpath where nifit can be found
%   - ID: subject ID
%   - k : polynominal degree of derending

% 21-10-20

%detrend nifti

ID={'001', '002', '003', '006', '007', '008', '009', '010', '011', '013', '014', '015', '016', '017', '018', '019', '021', '022', '023', '024', '025', '026', '028', '029', '030', '031', '032', '033', '034', '035', '038', '039', '040', '041', '043', '044', '045', '046', '047', '049', '050', '051', '052', '053', '054', '', '056', '057', '058', '059', '060', '061', '063', '064', '065', '066', '067', '068', '069', '071', '072', '073', '074', '075', '076', '079', '080', '081', '082', '083', '084', '085', '087', '090', '091', '092', '093', '094', '095', '096', '097', '098', '099', '104', '105', '106', '107', '108', '109', '110', '112', '114', '116', '117', '118', '119', '120', '121', '122', '123', '126', '127', '129', '130', '131', '132', '133', '134', '135', '136', '137', '138', '139', '140', '141', '142', '143', '144', '146', '148', '149', '150', '152', '153', '154', '155', '156', '158', '159', '160', '161', '162', '163', '164', '165', '168', '169', '170', '172', '173', '176', '178', '179', '180', '181', '183', '184', '185', '186', '187', '188', '190', '191', '192', '193', '194', '195', '196', '197', '198', '199', '200', '201', '202', '203', '204', '205', '206', '208', '210', '211', '212', '213', '214', '216', '217', '219', '220'};

k=2; 

% test if k is a string and make it number
if ischar(k) == 1
    k = str2double(k);
end

BASEPATH='BASE';

    %% get exact file location
for i=1:length(ID)
    DATAPATH=([BASEPATH, '/imaging_files/Resting-state/filtered_denoised_detrend_data/C', ID{i}, '/']);
    fname = ([DATAPATH, 'swuaCOBRA_', ID{i}, '_rest_despiked_BPfilt_denoised.nii']);

    
    %% load nifti
    % check in datafolder if nifit ends with .nii or .nii.gz and load
    % specific file (x by y by z by time)
    if exist([fname, '.nii.gz'], 'file') == 2
        nii = load_nii (fname);

% 
%     % 4 here refers to 4th dimension in 4D file....time.
     data = double(reshape(nii.img,[],size(nii.img,4)));
%     
     data = S_detrend_data2D(data, 2); % detrend data up to quadratic trend
%     
    nii.img = reshape(data,nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4),size(nii.img,4));
    fname = ([DATAPATH, 'swuaCOBRA_', ID{i}, '_rest_despiked_BPfilt_denoised_detrend.nii.gz']);

   save_nii (nii, fname);
   clear nii data DATAPATH
    
disp(' ')
disp('save nifit: Done')

end
    

end

