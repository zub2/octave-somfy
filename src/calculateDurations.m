## -*- texinfo -*-
## @deftypefn {Function File} {@var{d} =} calculateDurations (@var{y})
## Convert from timestamps of transitions into durations between transitions.
##
## This function converts a signal with transitions @var{y} (an n-by-2 matrix
## where each row denotes the timestamp of a transition and the new signal
## level) to an (n-1)-by-2 matrix where each row denotes the duration in the
## signal state stored in the second element of the row.
##
## @seealso{loadGPIOLog}
##
## @end deftypefn

function d = calculateDurations(y)
  narginchk(1, 1);

  d = [y(2:end,1) - y(1:end-1,1), y(1:end-1,2)];
endfunction
