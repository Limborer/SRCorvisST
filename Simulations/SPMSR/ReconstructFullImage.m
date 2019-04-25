function [I] = ReconstructFullImage(Y,conf,ImSize)
% ReconstructFullImage - Reconstructs an image from overlapping patches
if ~isfield(conf,'origin')
    conf.origin=[0 0];
end
grid = sampling_grid(ImSize,conf.window,conf.overlap,conf.border,conf.scale,conf.origin);
I=overlap_add(Y,ImSize,grid);