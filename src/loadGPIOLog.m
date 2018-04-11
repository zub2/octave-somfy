## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} loadGPIOLog (@var{fname})
## Load data from a GPIO log file @var{fname}.
##
## The GPIO log file is a binary file that consists of a series of 64-bit
## unsigned integers.  Assuming c is an array of all the integers in the GPIO
## log, their meaning is:
##
## @itemize @bullet
## @item c(1) contains signal level (either a 0 or a 1) at the beginning of the log
## @item c(2:) contain durations of alternating levels, i.e.:
## @itemize @bullet
## @item c(2) = how long (in µs) the signal stayed at level c(1)
## @item c(3) = how long (in µs) the signal stayed at level ~c(1)
## @item c(4) = how long (in µs) the signal stayed at level c(1)
## @item etc.
## @end itemize
## @end itemize
##
## The input integers are converted into an n-by-2 matrix where each row
## consists of a transition denoted by transition time (in seconds) and the
## target level, i.e.:
##
## @itemize @bullet
## @item y(1,:) = [0, c(1)]; % pretend the start of file was a transition
## @item y(2,:) = [c(2)/1e6, ~c1]; % transition from c1 to ~c1 at c(2)/1e6 s
## @item y(3,:) = [c(3)/1e6, c1];  % transition from ~c1 to c1 at c(3)/1e6 s
## @item y(4,:) = [c(4)/1e6, ~c1]; % transition from c1 to ~c1 at c(4)/1e6 s
## @item etc...
## @end itemize
##
## @seealso{calculateDurations}
## @seealso{plotSignal}
##
## @end deftypefn

function y = loadGPIOLog(fname)
  narginchk(1, 1);

  f = fopen(fname, "r");
  if f < 0
    error("Can't open input file '%s'!", fname);
  end

  c = fread(f, Inf, "uint64");
  fclose(f);

  y = [ 0, c(1); cumsum(c(2:end))./1e6, mod(c(1) + (1:numel(c) - 1)', 2)];
endfunction
