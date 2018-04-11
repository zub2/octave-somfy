## -*- texinfo -*-
## @deftypefn {Function File} plotSignal (@var{y})
## Plot signal @var{y}.
##
## @seealso{ookDemodulate}
## @seealso{loadGPIOLog}
## @seealso{makeTransitionsPolyline}
##
## @end deftypefn

function plotSignal(y)
  narginchk(1, 1);

  l = makeTransitionsPolyline(y);
  plot(l(:,1), l(:, 2));
  ylim([-1,2]);
endfunction
