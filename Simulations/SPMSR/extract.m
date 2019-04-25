function [features] = extract(conf,X)
% extract - Extracts patches from a given image with centers on a coarse grid
if ~isfield(conf,'origin')
    conf.origin=[0 0];
end
grid = sampling_grid(size(X), ...
    conf.window, conf.overlap, conf.border, conf.scale, conf.origin);

% Current image features extraction [feature x index]
f = double(X(grid));
features = reshape(f, [size(f, 1) * size(f, 2) size(f, 3)]);