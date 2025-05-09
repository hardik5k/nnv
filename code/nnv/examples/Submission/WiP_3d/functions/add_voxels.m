function I = add_voxels(vol, voxels, noise_disturbance)
    % noise_disturnamce can be kept fixed here, more interesting on number
    % of voxels changed

    % Return a VolumeStar of a brightening attack on a few pixels

    % Initialize vars
    vol = single(vol);
    at_vol = vol;

    % we can find the edge of the shape
    shape = edge3(vol,'approxcanny',0.6); % this should be okay for this data, but let's test it

    % select a random pixel
    idxs = setdiff(find(shape), find(vol));
    voxels = min(voxels,length(idxs));

    % For now, we can select the first ones
    at_vol(idxs(1:voxels)) = 255;

    % Define input set as VolumeStar
    dif_vol = -vol + at_vol;
    noise = dif_vol;
    V(:,:,:,:,1) = vol;   % center of set
    V(:,:,:,:,2) = noise; % basis vectors
    C = single([1; -1]);          % constraints
    d = single([1; -1]);          % constraints
    I = VolumeStar(V, C, d, 1-noise_disturbance, 1); % input set
    
end