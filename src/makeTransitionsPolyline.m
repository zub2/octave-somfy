## -*- texinfo -*-
## @deftypefn {Function File} {@var{l} =} makeTransitionsPolyline (@var{y})
## Convert signal @var{y} into a poly-line representation useful for plotting.
##
## The polyline @var{l} is an m-by-2 matrix where each row represents a point
## in the polyline (x and y coordinates).  The result can be fed into plot,
## e.g.: plot(@var{l}(:,1), @var{l}(:, 2));
##
## @seealso{plotSignal}
## @seealso{plot}
##
## @end deftypefn

function l = makeTransitionsPolyline(y)
  narginchk(1, 1)

  % start and end are typically not transitions, just start/end of measurement
  % so don't add steps at start + end
  l = y(1,:);
  for i = 2:rows(y)-1
    % transition at y(i,1) from previous value (y(i-1,2)) to new value (y(i,2))
    l = [l; y(i,1), y(i-1,2)];
    l = [l; y(i,1), y(i,2)];
  end
  l = [l; y(end,1), y(end-1,2)];
endfunction
