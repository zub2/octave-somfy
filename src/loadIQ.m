## -*- texinfo -*-
## @deftypefn {Function File} {@var{z} =} loadIQ (@var{fname})
## Read analytic signal from an IQ file @var{fname}.
##
## The IQ file is a binary file that consits of pairs of 8 bit unsigned
## integers where each pair are the real and complex parts of a sample of the
## analytic signal.  Such file is produced e.g. by rtl_sdr.
##
## The input data is converted into a vector of complex numbers (one sample for
## each pair in the input file).  The integers are converted to doubles in the
## range [-1, +1] (or more precisely: [-1, +127/128]).
##
## The following liks might be useful:
##
## @itemize @bullet
## @item http://aaronscher.com/wireless_com_SDR/RTL_SDR_AM_spectrum_demod.html
## @item http://whiteboard.ping.se/SDR/IQ
## @end itemize
##
## @seealso{ookDemodulate}
## @seealso{loadWav}
## @end deftypefn

function z = loadIQ(fname)
  narginchk(1, 1);

  f = fopen(fname, "rb");
  if f < 0
    error("Can't open file '%s'!", fname);
  endif

  z = fread(f, "uint8=>double");

  % map from [0, 255] to [-1, 127/128] in the same way audioread() does it for 8bit wavs
  z = z/128 - 1;

  % combine pairs (I, Q) into I + i*Q
  z = z(1:2:end) + i*z(2:2:end);

  fclose(f);
endfunction
