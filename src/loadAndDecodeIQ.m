## -*- texinfo -*-
## @deftypefn {Function File} loadAndDecodeIQ (@var{fname})
## @deftypefnx {Function File} loadAndDecodeIQ (@var{fname}, @var{verbose})
## High level function that reads analytic signal from an IQ file @var{fname},
## performs demodulation, scans the demodulated signal for all somfy frames,
## decodes and prints them.
##
## The optional parameter @var{verbose} can be used to increase verbosity.
## Defaults to 0.
##
## @seealso{loadIQ}
## @seealso{ookDemodulate}
## @seealso{findSomfy}
## @seealso{cutSignal}
## @seealso{decodeSomfy}
## @seealso{printSomfyFrame}
##
## @end deftypefn

function loadAndDecodeIQ(fname, verbose)
  narginchk(1, 2);

  if nargin == 1
    verbose = 0;
  end

  % must match record-dat.sh
  fs = 2.6e6;

  y = loadIQ(fname);
  fprintf("Running ookDemodulate...\n");
  fflush(stdout);
  y = ookDemodulate(y, fs);
  fprintf("ookDemodulate finished\n");
  fflush(stdout);

  somfyFrames = findSomfy(y, verbose);

  fprintf("found %d frame(s)\n", rows(somfyFrames));

  for frameIdx = 1:rows(somfyFrames)
    fprintf("Frame #%d (%s):\n", frameIdx, getSomfyFrameTypeName(somfyFrames(frameIdx, 4)));
    frame = decodeSomfy(cutSignal(y, somfyFrames(frameIdx, 2), somfyFrames(frameIdx, 3)), verbose);
    printSomfyFrame(frame);
  end
endfunction
