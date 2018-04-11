## -*- texinfo -*-
## @deftypefn {Function File} {@var{offsets} =} findSomfy (@var{y})
## @deftypefnx {Function File} {@var{offsets} =} findSomfy (@var{y}, @var{verbose})
## Find somfy frames in signal @var{y} and return an m-by-5 matrix where each
## row corresponds to a matched beginning of a frame.
##
## Each row of @var{offsets} consists of:
##
## @enumerate
## @item somfy frame start time
## @item somfy payload start time % FIXME THIS IS BROKEN (too late value)
## @item somfy payload end time
## @item somfy frame type: 1 = normal frame, 2 = repeat frame
## @end enumerate
##
## The number of rows is equal to the number of located somfy frames.
##
## The time of frame start and payload end coincides with a transition while
## the time of payload start can lie between transition (this is because the
## header ends after a fixed time at level 0 and immediately frame starts,
## possible at the same level).  Use cutSignal to extract the relevant parts.
##
## The optional parameter @var{verbose} can be used to increase verbosity.
## Defaults to 0.
##
## @seealso{cutSignal}
## @seealso{decodeSomfy}
## @seealso{getSomfyFrameTypeName}
##
## @end deftypefn

function offsets = findSomfy(y, verbose)
  narginchk(1, 2);

  if nargin == 1
    verbose = 0;
  end

  offsets = [];

  % search for a sequence of pulses

  HW_SYNC = [
    2.47e-3, % hw sync (1)
    2.55e-3  % hw sync (0)
  ];

  % ordinary frame
  % (durations in seconds of expected 1s and 0s)
  FRAME_START = [
    10.4e-3, % wakeup (1)
    7.1e-3,  % wakeup (0)
    repmat(HW_SYNC, 2, 1),
    4.8e-3,  % sw sync (1)
    645e-6   % sw sync (0)
  ]';

  % repeat frame
  % (durations in seconds of expected 1s and 0s)
  REPEAT_FRAME_START = [
    repmat(HW_SYNC, 7, 1),
    4.8e-3,  % sw sync (1)
    645e-6   % sw sync (0)
  ];

  EXPECTED = {
    FRAME_START,
    REPEAT_FRAME_START
  };

  % tolerance (for a match, abs(expected - actual) < TOLERANCE*expected)
  TOLERANCE = 0.1;

  % minimal duration of a 0 after a frame is finished
  % findSomfy doesn't decode the bits, it only assumes a frame ends after
  % MIN_SILENCE_AFTER
  MIN_SILENCE_AFTER = 5e-3;

  function b = durationMatches(actual, expected)
    b = abs(actual - expected) < TOLERANCE * expected;
  endfunction

  function b = durationMatchesAtLeast(actual, expected)
    b = actual - expected > -TOLERANCE * expected;
  endfunction

  function sequenceIdx = matchSequenceStart(duration, sequenceIdxStart)
    sequenceIdx = sequenceIdxStart;
    while sequenceIdx <= numel(EXPECTED) && ~durationMatches(duration, EXPECTED{sequenceIdx}(1))
      sequenceIdx++;
    end
    if sequenceIdx > numel(EXPECTED)
      sequenceIdx = NaN;
    end
  endfunction

  seqIdx = NaN;
  matchStartIdx = NaN;
  matchLen = 0;
  idx = 1;
  while idx < rows(y)
    state = y(idx, 2);
    duration = y(idx + 1, 1) - y(idx, 1);

    if (isnan(matchStartIdx))
      % don't have sequence start
      if (state == 1)
        % try to match any of the sequences
        seqIdx = matchSequenceStart(duration, 1);
        if (~isnan(seqIdx))
          % found a possible sequence start
          if (verbose >= 1)
            fprintf("found possible sequence #%d start at offset %d\n", seqIdx, idx);
          end
          matchStartIdx = idx;
          matchLen = 1;
        end
      end
      % else: don't care
      idx++;
    elseif (matchLen < numel(EXPECTED{seqIdx}))
      % at least 1 element in sequence seqIdx is matched
      % assume the EXPECTED sequences start with 1 and then alternate
      expectedState = ((-1)^matchLen + 1)/2;

      if (state == expectedState && matchLen+1 < numel(EXPECTED{seqIdx}) &&
          durationMatches(duration, EXPECTED{seqIdx}(matchLen+1)))
        % next matched
        matchLen++;
        idx++;
      elseif (state == expectedState && matchLen+1 == numel(EXPECTED{seqIdx}) &&
          durationMatchesAtLeast(duration, EXPECTED{seqIdx}(end)))
        matchLen++;
        idx++;
        if (durationMatches(duration, EXPECTED{seqIdx}(end)))
          headerDeltaT = 0;
        else
          headerDeltaT = max([0, duration - EXPECTED{seqIdx}(end)]);
        end
        if (verbose >=1)
          fprintf("sequence #%d matched, searching for frame end...\n", seqIdx);
        end
      else
        % doesn't match, try remaining sequences
        if (verbose >= 1)
          fprintf("giving up on sequence #%d at offset %d (expectedState=%d, actualState=%d, expectedDuration=%f, actualDuration=%f, elements matched=%d\n",
            seqIdx, idx, expectedState, state, EXPECTED{seqIdx}(matchLen+1), duration, matchLen);
        end
        startDuration = y(matchStartIdx + 1, 1) - y(matchStartIdx, 1);
        seqIdx = matchSequenceStart(startDuration, seqIdx + 1);
        if (~isnan(seqIdx))
          if (verbose >= 1)
            fprintf("re-trying with sequence #%d start at offset %d\n", seqIdx, idx);
          end
          matchLen = 1;
        else
          % nothing matches, reset and try next
          idx = matchStartIdx + 1;
          matchStartIdx = NaN;
          matchLen = 0;
        end
      end
    else
      % all elements matched, searching for the end
      if (state == 0 && duration >= MIN_SILENCE_AFTER)
        % hooray, got a match
        if (verbose >= 1)
          fprintf("sequence #%d end matched at offset %d\n", seqIdx, idx);
        end

        # FIXME FIXME
        offsets = [offsets; y(matchStartIdx, 1), y(matchStartIdx + matchLen - 1, 1) + headerDeltaT, y(idx, 1), seqIdx];

        % search for next...
        matchStartIdx = NaN;
        seqIdx = NaN;
        matchLen = 0;
      end

      idx++;
    end
  end

  % if a frame beginning was found and end of data was reached while searching
  % for frame end, assume that is the end of the frame
  % This is a bit dodgy, but it's useful for pre-trimmed data.
  if (~isnan(matchStartIdx) && matchLen == numel(EXPECTED{seqIdx}))
    fprintf("WARNING: end of data reached while searching for frame end, assuming frame ends there.\n");
    offsets = [offsets; y(matchStartIdx, 1),  y(matchStartIdx + matchLen, 1) + headerDeltaT, y(idx, 1), seqIdx];
  end

endfunction
