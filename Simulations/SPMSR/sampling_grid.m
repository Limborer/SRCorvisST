function [grid] = sampling_grid(img_size, window, overlap, border, scale, origin)
% sampling_grid - Returns a coarse sampling grid for a given image size
if nargin < 5
    scale = 1;
    origin = [0 0];
end
if nargin < 4
    border = [0 0];   
end
if nargin < 3
    overlap = [0 0];    
end

% Scale all grid parameters
window = window * scale;
overlap = overlap * scale;
border = border * scale;

% Create sampling grid for overlapping window
index = reshape(1:prod(img_size), img_size);
grid = index(1:window(1), 1:window(2)) - 1;

% Compute offsets for grid's displacement.
skip = window - overlap; % for small overlaps
offset = index(1+border(1)+origin(1):skip(1):img_size(1)-window(1)+1-border(1)+origin(1), ...
    1+border(2)+origin(2):skip(2):img_size(2)-window(2)+1-border(2)+origin(2));
offset = reshape(offset, [1 1 numel(offset)]);

% Prepare 3D grid - should be used as: sampled_img = img(grid);
grid = repmat(grid, [1 1 numel(offset)]) + repmat(offset, [window 1]);