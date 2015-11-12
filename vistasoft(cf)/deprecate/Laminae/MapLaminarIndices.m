function laminarIndices = MapLaminarIndices(depthRange, radius, wMesh)

% laminarIndices = MapLaminarIndices([depthRange, radius, wMesh]);
%
% All input parameters are optional. The depthRange and radius will be
% queried from the user if not supplied. Input wMesh is the gray-white
% interface surface mesh structure generated by mrMesh. It should be
% provided as the first mesh defined in the VOLUME structure.
%
% Extend the entire mesh into the specified depthRange, a two-vector [min,
% max], negative values correspond to white matter. Input radius specifies
% the neighborhood around each node to gather the indices. 
%
% Ress, 07/05

mrGlobals

laminarIndices = {};

selectedVOLUME = viewSelected('Volume');
if ~strcmp(VOLUME{selectedVOLUME}.viewType, 'Gray')
  VOLUME{selectedVOLUME} = switch2Gray(VOLUME{selectedVOLUME});
end

% Build gray connection graph (if needed):
if ~isfield(VOLUME{selectedVOLUME}, 'grayConMat')
  VOLUME{selectedVOLUME}.grayConMat = ...
    makeGrayConMat(VOLUME{selectedVOLUME}.nodes, VOLUME{selectedVOLUME}.edges, 0);
end
view = VOLUME{selectedVOLUME};
vDims = size(view.anat);
layer1Verts = view.coords(:, view.nodes(6, :) == 1);
nNodes = size(layer1Verts, 2);

if isempty(layer1Verts)
  Alert('No segmentation data!')
  return
end

if ~exist('wMesh', 'var')
  if isfield(view, 'mesh')
    if ~isempty(view.mesh)
      wMesh = viewGet(view,'mesh',1);
    end
  end
end

if ~exist('wMesh', 'var')
  Alert('No gray-white mesh!')
  return
end

if ieNotDefined('deltaThick') | ieNotDefined('radius')
  % Prompt user for smoothing and baseFrames:
  prompt = {'Extension depth (mm)', 'Averaging radius (mm)'};
  dTitle = 'Laminar coordinate calculation parameters';
  defVal = {'2', '1.5'};
  response = inputdlg(prompt, dTitle, 1, defVal);
  if isempty(response)
    % User pushed cancel button, so quit:
    laminarIndices = {};
    return
  end
  dt = str2num(response{1});
  depthRange = [-dt, dt];
  radius = str2num(response{2});
end

% Get the gray-white interface surface and normals from the mrMesh
% structure:
whiteVerts = mrmGet(wMesh, 'vertices');
whiteNorms = mrmGet(wMesh, 'normals');

% Create nearest-neighbor associations between the gray-white surface and the layer-1
% mesh vertices. Use these to associate the mesh normals with the
% layer-1 vertices.
g2vMap = MapGrayToVertices(layer1Verts([2 1 3], :), whiteVerts, view.mmPerVox);
layer1Norms = whiteNorms([2 1 3], g2vMap);

% Calculate laminar dilation range:
dx = mean(view.mmPerVox);
range = [floor(depthRange(1)/dx), ceil(depthRange(2)/dx)];
dThick = diff(range);
t = range(1):0.5:range(2);

% Build map of all gray and white matter
cVol = logical(view.anat*0);
cVol(coords2Indices(view.coords, vDims)) = 1;

% Build reverse-lookup volume
iVol = int32(view.anat*0);
inds = coords2Indices(layer1Verts, vDims);
for ii=1:length(inds), iVol(inds(ii)) = ii; end

% Loop over the mesh:
laminarIndices = cell(1, nNodes);
waitH = waitbar(0, 'Mapping laminar coordinates...');
iVolC = [];
for ii=1:nNodes
  waitbar(ii/nNodes, waitH);
  [coords, layers] = CreateGrayDisk(view, layer1Verts(:, ii), radius);
  coords = coords(:, layers == 1);
  rInds = iVol(coords2Indices(coords, vDims));
  if length(rInds) > 1
    mNorm = mean(layer1Norms(:, rInds)')';
  else
    mNorm = layer1Norms(:, rInds);
  end
  [coords, eLayers, iVolC] = ExtendCoordsOutward(view, coords, mNorm, iVolC);
  nCoords = size(coords, 2);
  if nCoords >= 2
    roiBounds = [min(coords'); max(coords')]';
    % Create a subvolume that maps the ROI with padding to account
    % for the subsequent dilation
    bCoords = zeros(size(coords));
    for jj=1:3, bCoords(jj, :) = coords(jj, :) - roiBounds(jj, 1) + dThick + 1; end
    dbDims = diff(roiBounds') + 1 + 2*dThick;
    vol = zeros(dbDims);
    inds = coords2Indices(bCoords, dbDims);
    vol(inds) = 1;
    % Dilate ROI vertices along mean normal
    for jj=1:length(t)
      newCoords = round(bCoords + repmat(mNorm*t(jj), [1, nCoords]));
      inds = coords2Indices(newCoords, dbDims);
      vol(inds) = 1;
    end

    % Check for contention with gray matter outside of the ROI to
    % avoid growing over sulcal boundaries and the like.
    % Step 1: Extract the expanded ROI subvolume
    eBounds = zeros(3, 2);
    eBounds(:, 1) = roiBounds(:, 1) - dThick;
    delta0 =  1 - eBounds(:, 1);
    delta0(delta0 < 0) = 0;
    eBounds(delta0 > 0, 1) = 1;
    eBounds(:, 2) = roiBounds(:, 2) + dThick;
    delta1 = eBounds(:, 2) - vDims';
    delta1(delta1 < 0) = 0;
    eBounds(delta1 > 0, 2) = vDims(delta1 > 0);
    cVola = cVol(eBounds(1, 1):eBounds(1, 2), eBounds(2, 1):eBounds(2, 2), ...
      eBounds(3, 1):eBounds(3, 2));
    % If the subvolume exceeds the boundaries of the original
    % classification volume, pad the result with zeros
    cVol1 = vol * 0;
    cVol1(1+delta0(1):dbDims(1)-delta1(1), 1+delta0(2):dbDims(2)-delta1(2), ...
      1+delta0(3):dbDims(3)-delta1(3)) = cVola;
    % Step 2: Remove ROI gray matter:
    inds = coords2Indices(bCoords, dbDims);
    cVol1(inds) = 0;
    % Step 3: Mask off out-of-ROI gray matter
    vol = vol & ~cVol1;

    % Extract the volume coordinates and convert to indices
    laminarCoords = indices2Coords(find(vol), dbDims);
    for jj=1:3, laminarCoords(jj, :) = laminarCoords(jj, :) +  roiBounds(jj, 1) - dThick - 1; end
    laminarIndices{ii} = coords2Indices(laminarCoords, vDims);
  end
end

% Put the laminar coordinate system into the VOLUME structure and save it
% for future use:
VOLUME{selectedVOLUME}.laminarIndices = laminarIndices;
save(fullfile(viewDir(view), 'laminarIndices.mat'), 'laminarIndices', 'depthRange', 'radius');

close(waitH)