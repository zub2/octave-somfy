## -*- texinfo -*-
## @deftypefn {Function File} {[@var{z}, @var{fs}] =} loadWav (@var{fname})
## Read analytic signal from the wav file @var{fname} and return the analytic
## signal @var{z} and the sampling rate @var{fs}.
##
## The wav file is expeced to contain two channels.  The first stores the real
## part and the second stores the complex part of the signal.
##
## The input data is converted into the vector of complex numbers (one sample
## for each sample in the input file) @var{z}.
##
## @seealso{ookDemodulate}
## @seealso{loadWav}
## @end deftypefn

function [z, fs] = loadWav(fname)
  narginchk(1, 1);

  [z, fs] = audioread(fname);

  % combine pairs (I, Q) into I + i*Q
  z = z(:,1) + i*z(:,2);
endfunction
