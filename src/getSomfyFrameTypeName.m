## -*- texinfo -*-
## @deftypefn {Function File} {@var{name} =} getSomfyFrameTypeName (@var{type})
## Convert frame type integer @var{type} as returned by findSomfy to its name.
##
## The name can be used in messages.
##
## @seealso{findSomfy}
##
## @end deftypefn

function name = getSomfyFrameTypeName(type)
  narginchk(1, 1);

  switch type
    case 1
      name = "normal";
    case 2
      name = "repeat";
    otherwise
      name = "unknown";
  end
endfunction
