function classNi = mrGrayConvertFirstToClass(firstNifti, fastNifti, outFileName, fastCsfWmGm, fastWmSmooth)
% Generate an initial segmentation from FSL FIRST and FAST output.
% 
%   mrGrayConvertFirstToClass(firstNifti, fastNifti, outFileName, fastCsfWmGm=[1 3 2])
%
%
% 2007.12.21 RFD: wrote it.
% 2008.12.31 RFD: fixed a bug that was labeling a perimeter around the
%       lateral ventricle as gray matter. Also added option to skip the FAST
%       segmentation. This is useful if you want to just do the FIRST part and
%       then merge it with an old class file. Eg:
%       scgNi = mrGrayConvertFirstToClass('t1/t1_sgm_all_th4_first.nii.gz', [], []);
%       l = mrGrayGetLabels;
%       c = niftiRead('t1/t1_class.nii.gz');
%       bm = niftiRead('t1/t1_mask.nii.gz');
%       c.data(~bm.data) = 0;
%       % Add a perimeter of CSF to ensure that the brain is encased in CSF.
%       perim = imdilate(bm.data>0,strel('disk',5)) & bm.data==0;
%       m = scgNi.data>0;
%       c.data(m) = scgNi.data(m);
%       c.data(perim) = l.CSF;
%       movefile('t1/t1_class.nii.gz','t1/t1_class_OLD.nii.gz');
%       writeFileNifti(c);
% 2010.08.10 LMP: removed the isempty clause from both firstNifti and
%       fastNifti so that the user can pass in either argument as an
%       empty struct [] and only use the other file as a class file via scripting.
%       I'm not sure that this is the best way that it can be done, but it
%       works.
% 2010.08.11 LMP: Added the ability to pass in a value for the fastWmSmooth
%       arg. If nothing is passed in it defaults to 0 (no smoothing).
% 2010.10.21 LMP: Code now writes out a .lbl file, through mrGrayGetLabels.
%       Also again assigns the CSF into a label (1). 
% 
% RFD (c) VISTASOFT Stanford Team  

if ~exist('fastWmSmooth','var'), fastWmSmooth = 0;  end

if ~exist('firstNifti','var')
    opts = {'*.nii.gz;*.nii', 'NIFTI files'; '*.*','All Files (*.*)'};
    [f, p]=uigetfile(opts, 'Select a first segmentation file (generated by run_first_all)...');
    if(isequal(f,0)|| isequal(p,0))
        disp('Skipping sub-cort GM.');
        firstNifti = [];
    else
        if(isempty(p)); p = pwd; end
        firstNifti = fullfile(p,f);
    end
else
    if isempty(firstNifti)
        firstNifti = [];
    else
        if(isstruct(firstNifti)), [p,f] = fileparts(firstNifti.fname);
        else [p,f] = fileparts(firstNifti); end
        [junk,f] = fileparts(f);
    end
end
if(islogical(firstNifti)), firstNifti = []; end

if ~exist('fastNifti','var')
    opts = {'*.nii.gz;*.nii', 'NIFTI files'; '*.*','All Files (*.*)'};
    [f2, p2]=uigetfile(opts, 'Select a fast segmentation file (generated by fast)...');
    if(isequal(f2,0)|| isequal(p2,0))
        disp('Skipping fast.');
        fastNifti = [];
    else
        fastNifti = fullfile(p2,f2);
    end
end
if(islogical(fastNifti)) || isempty(fastNifti), fastNifti = []; end

if(nargout==0 && (~exist('outFileName','var')||isempty(outFileName)))
    outFileName = fullfile(p, [f '_class.nii.gz']);
    [f,p] = uiputfile('*.nii.gz','Save new NIFTI class file as...',outFileName);
    if(isequal(f,0)|| isequal(p,0)); disp('user canceled.'); return; end
    outFileName = fullfile(p,f);
else
    %outFileName = [];
end
if(ischar(firstNifti)&&~isempty(firstNifti))
    firstNifti = niftiRead(firstNifti);
end
if(ischar(fastNifti)&&~isempty(fastNifti))
    fastNifti = niftiRead(fastNifti);
end
% Make sure they are in cannonical orientation
if(~isempty(fastNifti))
    fastNifti = niftiApplyCannonicalXform(fastNifti);
end
if(~isempty(firstNifti))
    firstNifti = niftiApplyCannonicalXform(firstNifti);
    firstNifti.data = uint8(firstNifti.data);
end

if(nargout==0 && (~exist('outFileName','var')||isempty(outFileName)))
    [p,f,e] = fileparts(firstNifti.fname);
    if(isempty(p)); p = pwd; end
    if(strcmpi(e,'.gz')); [junk,f] = fileparts(f); end
    outFileName = fullfile(p, [f '_class.nii.gz']);
    [f,p] = uiputfile('*.nii.gz','Save new NIFTI class file as...',outFileName);
    if(isequal(f,0)|| isequal(p,0)); disp('user canceled.'); return; end
    outFileName = fullfile(p,f);
end

if(~exist('fastCsfWmGm','var')||isempty(fastCsfWmGm))
    fastCsfWmGm = [1 3 2];
end

labels = mrGrayGetLabels;

if(isempty(firstNifti))
    xform = fastNifti.qto_xyz;
    CSF = zeros(size(fastNifti.data),'uint8');
    SGM = zeros(size(fastNifti.data),'uint8');
else
    % FIRST labels:
    % 4 Left-Lateral-Ventricle 40
    % 10 Left-Thalamus-Proper 40
    % 11 Left-Caudate 30
    % 12 Left-Putamen 40
    % 13 Left-Pallidum 40
    % 16 Brain-Stem /4th Ventricle 40
    % 17 Left-Hippocampus 30
    % 18 Left-Amygdala 50
    % 26 Left-Accumbens-area 50
    % 43 Right-Lateral-Ventricle 40
    % 49 Right-Thalamus-Proper 40
    % 50 Right-Caudate 30
    % 51 Right-Putamen 40
    % 52 Right-Pallidum 40
    % 53 Right-Hippocampus 30
    % 54 Right-Amygdala 50
    % 58 Right-Accumbens-area 50
    % The FIRST segmentation images (2:end) contain a perimeter of the
    % label value plus 100. So, to catch all CSF, we need to look for the
    % values 4, 104, 43 and 143.
    
    %all = any(firstNifti.data(:,:,:,2:end)>0,4);
    %CSF = any(firstNifti.data(:,:,:,2:end)==4 | firstNifti.data(:,:,:,2:end)==104 | firstNifti.data(:,:,:,2:end)==43 | firstNifti.data(:,:,:,2:end)==143,4);
    all = any(firstNifti.data(:,:,:,1)>0,4);
    CSF = any(firstNifti.data(:,:,:,1)==4 | firstNifti.data(:,:,:,1)==104 | firstNifti.data(:,:,:,1)==43 | firstNifti.data(:,:,:,1)==143,4);
    SGM = all&~CSF;
    xform = firstNifti.qto_xyz;
    clear firstNifti;
end
c = zeros(size(CSF),'uint8');

if fastWmSmooth >= 1
    fprintf('Smoothing mask with %smm kernel...\n',num2str(fastWmSmooth));
end

if(~isempty(fastNifti))
    % Add what fast thinks is CSF, as well as a perimeter of CSF to
    % ensure that the brain is encased in CSF.
    perim = imdilate(fastNifti.data>0,strel('disk',5));
    perim = perim&fastNifti.data==0;
    CSF = ~SGM & (CSF | fastNifti.data==fastCsfWmGm(1) | perim);
    clear perim;
    % Now extract the FAST white matter mask and split it into left
    % and right. Note that the splitting code is very crude and
    % assumes a cannonical axial orientation.
    WML = fastNifti.data==fastCsfWmGm(2);
    WMR = WML;
    ac = round(mrAnatXformCoords(fastNifti.qto_ijk,[0 0 0]));
    WMR(1:ac(1)-1,:,:) = 0;
    WML(ac(1)+1:end,:,:) = 0;
    WMR = dtiCleanImageMask(WMR,fastWmSmooth)>0.5;
    WML = dtiCleanImageMask(WML,fastWmSmooth)>0.5;
    c(WMR) = labels.rightWhite;
    c(WML) = labels.leftWhite;
end

c(CSF) = labels.CSF; % Temporary change.
if(any(SGM(:)))
    c(SGM) = labels.subCorticalGM;
end
classNi = niftiGetStruct(c, xform, 1, 'mrGray class file', 'mrGray', 1002);
classNi.fname = outFileName;

if(~isempty(outFileName))
    [p,f,e] = fileparts(outFileName);
    if(isempty(e))
        outFileName = [outFileName '.nii.gz'];
    elseif(strcmpi(e,'.gz'))
        [junk,f] = fileparts(f);
    end
labelFileName = fullfile(p,[f '.lbl']);
mrGrayGetLabels(labelFileName);
    
    fprintf('NIFTI classification saved in: %s\n\n', outFileName);
    writeFileNifti(classNi);
end

return;




