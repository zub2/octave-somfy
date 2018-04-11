## -*- texinfo -*-
## @deftypefn {Function File} loadAndDecodeGPIOLog (@var{fname})
## @deftypefnx {Function File} loadAndDecodeGPIOLog (@var{fname}, @var{verbose})
## High level function that reads GPIO log file @var{fname}, scans it for all
## somfy frames, decodes and prints them.
##
## The optional parameter @var{verbose} can be used to increase verbosity.
## Defaults to 0.
##
## @seealso{loadGPIOLog}
## @seealso{findSomfy}
## @seealso{cutSignal}
## @seealso{decodeSomfy}
## @seealso{printSomfyFrame}
##
## @end deftypefn

function loadAndDecodeGPIOLog(fname, verbose)
  narginchk(1, 2);

  if nargin == 1
    verbose = 0;
  end

  y = loadGPIOLog(fname);
  somfyFrames = findSomfy(y, verbose);

  fprintf("found %d frame(s)\n", rows(somfyFrames));

  for frameIdx = 1:rows(somfyFrames)
    fprintf("Frame #%d (%s):\n", frameIdx, getSomfyFrameTypeName(somfyFrames(frameIdx, 4)));
    frame = decodeSomfy(cutSignal(y, somfyFrames(frameIdx, 2), somfyFrames(frameIdx, 3)), verbose);
    printSomfyFrame(frame);
  end
endfunction
