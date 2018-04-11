## -*- texinfo -*-
## @deftypefn {Function File} loadAndDecodeWav (@var{fname})
## @deftypefnx {Function File} loadAndDecodeWav (@var{fname}, @var{verbose})
## High level function that reads analytic signal from a wave file @var{fname},
## performs demodulation, scans the demodulated signal for all somfy frames,
## decodes and prints them.
##
## The optional parameter @var{verbose} can be used to increase verbosity.
## Defaults to 0.
##
## @seealso{loadWav}
## @seealso{ookDemodulate}
## @seealso{findSomfy}
## @seealso{cutSignal}
## @seealso{decodeSomfy}
## @seealso{printSomfyFrame}
##
## @end deftypefn

function loadAndDecodeWav(fname, verbose)
  narginchk(1, 2);

  if nargin == 1
    verbose = 0;
  end

  [y,fs] = loadWav(fname);
  y = ookDemodulate(y, fs);
  somfyFrames = findSomfy(y, verbose);

  fprintf("found %d frame(s)\n", rows(somfyFrames));

  for frameIdx = 1:rows(somfyFrames)
    fprintf("Frame #%d (%s):\n", frameIdx, getSomfyFrameTypeName(somfyFrames(frameIdx, 4)));
    frame = decodeSomfy(cutSignal(y, somfyFrames(frameIdx, 2), somfyFrames(frameIdx, 3)), verbose);
    printSomfyFrame(frame);
  end
endfunction
