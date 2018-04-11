## -*- texinfo -*-
## @deftypefn {Function File} {@var{s} =} stringifyBytes (@var{bits})
## Create an easy to read string representantion of an array of bytes (integers
## in the range [0, 255]).
##
## @end deftypefn

function s = stringifyBytes(bytes)
  narginchk(1, 1);

  s = "";
  for i = 1:numel(bytes)
    if i ~= 1
      s = cstrcat(s, " ");
    end
    s = cstrcat(s, sprintf("%02X", bytes(i)));
  end
endfunction
