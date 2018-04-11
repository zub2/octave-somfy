# helper to load dependencies and make somfy-octave available in octave search path
pkg load signal
pkg load statistics

addpath(fullfile(fileparts(mfilename("fullpath")), "src"));
