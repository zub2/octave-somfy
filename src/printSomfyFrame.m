## -*- texinfo -*-
## @deftypefn {Function File} printSomfyFrame (@var{frame})
## Print a decoded somfy frame.
##
## The @var{frame} is expected to be the result of decodeSomfy, a structure
## with the decoded contents of a somfy frame.
##
## @seealso{decodeSomfy}
##
## @end deftypefn

function printSomfyFrame(frame)
  narginchk(1, 1);

  fprintf("raw bits: %s\n", stringifyBits(frame.rawBits));
  fprintf("raw bytes: %s\n", stringifyBytes(frame.rawBytes));
  fprintf("deobfuscated bytes: %s\n", stringifyBytes(frame.bytes));

  decoded = frame.decoded;
  fprintf("key: 0x%02x\n", decoded.key);
  fprintf("ctrl: 0x%x (%s)\n", decoded.ctrl, decoded.ctrlName);
  fprintf("checksum: 0x%x\n", decoded.checksum);
  fprintf("rolling code: 0x%04x\n", decoded.rollingCode);
  fprintf("address: 0x%06x\n", decoded.address);
endfunction
