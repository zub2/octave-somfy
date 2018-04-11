## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} cutSignal (@var{y}, @var{startTime}, @var{endTime})
## Return a portion of the input signal @var{y} that starts at
## max(@var{startTime}, signal start) and ends at min(@var{endTime}, signal end).
##
## The signal @var{y} is expected to be a m-by-2 matrix with each row
## representing a transition at time @var{y}(i, 1) seconds into state
## @var{y}(i, 2).
##
## @seealso{ookDemodulate}
## @seealso{loadGPIOLog}
## @end deftypefn

function y = cutSignal(y, startTime, endTime)
  narginchk(3, 3);

  % cut at startTime
  idxStart = find(y(:,1) >= startTime, 1);
  if (idxStart > 1 && y(idxStart, 1) > startTime)
    % not exactly at a transition
    y = y(idxStart - 1:end, :);
    y(1,1) = startTime;
  else
    % exactly at a transition, easy peasy
    y = y(idxStart:end, :);
  end

  % cut at endTime
  idxEnd = find(y(:,1) <= endTime, 1, "last");
  if (idxEnd < rows(y) && y(idxEnd, 1) < endTime)
    % not exactly at a transition
    y = y(1:idxEnd + 1, :);
    y(end,1) = endTime;
  else
    % exactly at a transition
    y = y(1:idxEnd, :);
  end
end
