## -*- texinfo -*-
## @deftypefn {Function File} {@var{s} =} stringifyBits (@var{bits})
## Create an easy to read string representantion of an array of bits (logical
## values, or 0s and 1s).
##
## @end deftypefn

function s = stringifyBits(bits)
  narginchk(1, 1);

  s = "";
  for i = 1:numel(bits)
    if i ~= 1
      if mod(i-1, 8) == 0
        s = strcat(s, "|");
      elseif mod(i-1, 4) == 0
        s = strcat(s, ".");
      end
    end
    s = strcat(s, sprintf("%d", bits(i)));
  end
endfunction
