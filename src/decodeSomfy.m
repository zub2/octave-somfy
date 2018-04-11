## -*- texinfo -*-
## @deftypefn {Function File} {@var{frame} =} decodeSomfy (@var{y})
## @deftypefnx {Function File} {@var{frame} =} decodeSomfy (@var{y}, @var{verbose})
## Decode a somy frame from its signal representation @var{y} and return a
## structure containing the decoded payload.
##
## The signal @var{y} is an n-by-2 matrix, typically an output of cropSignal
## applied to indices found via findSomfy.
##
## This is based on https://pushstack.wordpress.com/somfy-rts-protocol/ but the
## timing seems to be different for my somfy.  Also, i tried to make the
## manchester decoding as robust as possible without depending on particular
## clock frequency.  This is unnecessarily complex but in the beginning I didn't
## trust the timing.
##
## The optional parameter @var{verbose} can be used to increase verbosity.
## Defaults to 0.
##
## @seealso{findSomfy}
## @seealso{cutSignal}
## @seealso{printSomfyFrame}
##
## @end deftypefn

function frame = decodeSomfy(y, verbose)
  narginchk(1, 2);

  if nargin == 1
    verbose = 0;
  end

  % use k-means clustering just for the "fun"... everything seems too fuzzy
  durations = calculateDurations(y);
  [clusterIdx, clusterCenters] = kmeans(durations(:,1), 2);
  [~, shortClusterIdx] = min(clusterCenters);
  [~, longClusterIdx] = max(clusterCenters);

  if (verbose >= 1)
    fprintf("estimated half-symbol width: %fµs\n", clusterCenters(shortClusterIdx)*1e6);
    fprintf("estimated symbol width: %fµs\n", clusterCenters(longClusterIdx)*1e6);
    fprintf("full/half ratio (should be close to 2): %f\n", clusterCenters(longClusterIdx)/clusterCenters(shortClusterIdx));
  end

  shortClusterIndices = clusterIdx == shortClusterIdx;
  longClusterIndices = clusterIdx == longClusterIdx;

  maxShortCluster = max(durations(shortClusterIndices));
  minLongCluster = min(durations(longClusterIndices));

  % mid point between the clusters
  LONG_THRESHOLD = (maxShortCluster + minLongCluster) / 2;

  fprintf("using treshold %fµs\n", LONG_THRESHOLD*1e6);

  if (durations(1, 1) > LONG_THRESHOLD)
    error('the first symbol is not a half-width symbol!');
  end

  waitingHalfSym = false;
  bits = [~durations(1,2)];

  for i = 2:rows(durations)
    d = durations(i, 1);
    v = durations(i, 2);
    if (waitingHalfSym)
      if (d > LONG_THRESHOLD)
        error('expecting a half-symbol but got a full symbol');
      end
      bits = [bits, ~v];
      waitingHalfSym = false;
    elseif (d > LONG_THRESHOLD)
      % full-width symbol -> new bit = !prev bit
      bits = [bits, ~v];
    else % d <= LONG_THRESHOLD
      % half-width symbol
      waitingHalfSym = true;
    end
  end

  % data should always end with a half-symbol
  if (!waitingHalfSym)
    warning('unexpected: data ends with a full-width symbol (half-width symbol expected)');
  end

  if (verbose >= 1)
    % print raw received bits
    s = "";
    for i = 1:numel(bits)
      if (i ~= 1 && i ~= numel(bits))
        if (mod(i-1, 8) == 0)
          s = strcat(s, "|");
        elseif (mod(i-1, 4) == 0)
          s = strcat(s, ".");
        end
      end
      s = strcat(s, sprintf("%d", bits(i)));
    end
    fprintf("raw decoded bits: %s\n", s);
  end

  EXPECTED_BITS = 56;
  if (numel(bits) ~= EXPECTED_BITS)
    error("decoded unxpected number of bits: expected %d, got %d", EXPECTED_BITS, numel(bits));
  end

  % gather into bytes
  rawBytes = [];
  for i = 1:numel(bits)
    bit = bits(i);
    bitWeight = 7 - mod(i-1, 8);
    if (bitWeight == 7)
      rawBytes = [rawBytes, 0];
    end
    rawBytes(numel(rawBytes)) += bit * 2^bitWeight;
  end

  if (verbose >= 1)
    % print raw received bytes
    s = "";
    for i = 1:numel(rawBytes)
      if (i ~= 1)
        s = cstrcat(s, " ");
      end
      s = cstrcat(s, sprintf("%02X", rawBytes(i)));
    end
    fprintf("raw decoded bytes: %s\n", s);
  end

  % deobfuscate
  bytes = rawBytes;
  for i = numel(bytes):-1:2
    bytes(i) = bitxor(bytes(i), bytes(i-1));
  end

  % decode fields
  frame.rawBits = bits;
  frame.rawBytes = rawBytes;
  frame.bytes = bytes;
  
  decoded = cell();
  decoded.key = bytes(1);
  decoded.ctrl = bitshift(bytes(2), -4);
  decoded.ctrlName = getSomfyCtrlName(decoded.ctrl);
  decoded.checksum = bitand(bytes(2), 0xf);
  decoded.rollingCode = bitshift(bytes(3), 8) + bytes(4);
  decoded.address = bitshift(bytes(5), 2*8) + bitshift(bytes(6), 8) + bytes(7);

  frame.decoded = decoded;
endfunction

function name = getSomfyCtrlName(ctrlValue)
  switch ctrlValue
    case 1
      name = "my";
    case 2
      name = "up";
    case 3
      name = "my+up";
    case 4
      name = "down";
    case 5
      name = "my+down";
    case 6
      name = "up+down";
    case 8
      name = "prog";
    case 9
      name = "sun+flag";
    case 10
      name = "flag";
    otherwise
      name = "unknown";
  end
endfunction
