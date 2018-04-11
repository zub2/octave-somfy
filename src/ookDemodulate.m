## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} ookDemodulate (@var{iqSignal}, @var{fs})
## Demodulate OOK signal.
##
## This function performs OOK demodulation on analytic signal at the sample rate
## @var{fs}.
##
## The result is an n-by-2 matrix where each row consists of a timestamp and
## signal value.  The first row is the start of the signal, subsequent rows
## signify transitions.  The second row of the return value alternates between 0
## and 1.
##
## Inspired by the code in rtl_433 which is described here:
## https://github.com/merbanan/rtl_433/wiki/OOK-Signal-Demodulation
##
## @seealso{loadIQ}
## @seealso{loadWav}
## @seealso{plotSignal}
##
## @end deftypefn

function y = ookDemodulate(iqSignal, fs)
  narginchk(2, 2);

  x = abs(iqSignal);
  Fcutoff = 1e5; % 100 kHz... this is also used by rtl_433
  [Fb, Fa] = butter(1, Fcutoff / (fs/2));
  x = filter(Fb, Fa, x);

  % threshold
  b = x >= (min(x) + max(x)) / 2;

  % filter some more (debounce)
  minDuration = 50e-6;
  minSamples = minDuration*fs;

  startIdx = NaN;
  startValue = NaN;
  state = NaN;
  count = 0;
  y = [];

  for idx = 1 : numel(b)
    if count > 0
      if b(idx) == startValue
        count++;
      else
        count = 0;
      end

      if count > minSamples
        y = [ y; startIdx/fs, startValue ];
        state = startValue;
        startIdx = NaN;
        count = 0;
      end
    elseif state ~= b(idx)
      startIdx = idx;
      startValue = b(idx);
      count = 1;
    elseif idx == numel(b)
      % end of data, create an entry even if there is no transition
      y = [ y; idx/fs, ~y(end,2) ];
    end
  end

endfunction
