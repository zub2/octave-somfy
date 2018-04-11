# Octave-Somfy

This repository contains [GNU Octave](https://www.gnu.org/software/octave/) functions that can decode the Somfy RTS Protocol. This implementation is based in the description available at the [Pushstack blog](https://pushstack.wordpress.com/somfy-rts-protocol/).

The input data can come from several sources:

* analytic signal captured by [rtl_sdr](https://osmocom.org/projects/sdr/wiki/rtl-sdr)
* a wav file containing the analytic signal as two separate channels
* a log of the output of an [OOK](https://en.wikipedia.org/wiki/On-off_keying) receiver (e.g. the following widely available [MX-05 receiver module](http://hobbycomponents.com/wired-wireless/615-433mhz-wireless-receiver-module-mx-05))

The functions in this repository can do the steps necessary to decode the content:

* perform OOK demodulation (not needed for data that is already demodulated)
* find Somfy frames
* perform [Manchester](https://en.wikipedia.org/wiki/Manchester_code) decoding of the payload
* interpret the decoded bytes

All the functions come with documentation, so - assuming the directory `src` is added to octave path- typing e.g. `help ookDemodulate` should print more info on that function. The script `somfy.m` can be used to add the `src` subdirectory to the octave path, for example by `run("path-to-this-repo/somfy")`.

## Input Formats

### rtl_sdr

If you have a receiver supported by [rtl_sdr](https://osmocom.org/projects/sdr/wiki/rtl-sdr), you can capture the signal like this:

```shell
rtlsdr -f 433420000 -s 2600000 -g 1 captured_data.iq
```

In my experience one has to disable auto gain (hence the `-g 1`). You can use the script `record-dat.sh` which does the same thing as above.

Log created in this way can be directly fed to the function `loadIQ`:

```octave
z = loadIQ('captured_data.iq');
```

Alternatively, to perform all the steps, you can use the function `loadAndDecodeIQ`:
```octave
loadAndDecodeIQ('captured_data.iq');
```
If everything works OK you should see output similar to this:
```
Running ookDemodulate...
ookDemodulate finished
found 2 frame(s)
Frame #1 (normal):
using treshold 958.269231µs
raw bits: 1010.1101|1110.0010|1110.0111|0110.1111|0101.1011|0011.0010|0111.0111
raw bytes: AD E2 E7 6F 5B 32 77
deobfuscated bytes: AD 4F 05 88 34 69 45
key: 0xad
ctrl: 0x4 (down)
checksum: 0xf
rolling code: 0x0588
address: 0x346945
Frame #2 (repeat):
using treshold 966.730769µs
raw bits: 1010.1101|1110.0010|1110.0111|0110.1111|0101.1011|0011.0010|0111.0111
raw bytes: AD E2 E7 6F 5B 32 77
deobfuscated bytes: AD 4F 05 88 34 69 45
key: 0xad
ctrl: 0x4 (down)
checksum: 0xf
rolling code: 0x0588
address: 0x346945
```

### Wav File

A wav file can be useful if you want to do some manual cropping of the recorded data. It can be produced by converting the rtlsdr log by e.g. [SoX](http://sox.sourceforge.net/):
```shell
sox -t raw -r 2600000 -e unsigned-integer -b 8 -c 2 captured_data.iq captured_data.wav
```
or you can use the script `dat-to-wav.sh`. The wav file can then be cropped e.g. in [Audacity](https://www.audacityteam.org/).

The wav file can be opened using `loadWav`:
```octave
[z, fs] = loadWav('captured_data.wav');
```
(`fs` is the sample rate; for the value suggested above it will always be 2.6*10⁶).

To perform everything including the decoding use the function `loadAndDecodeWav`.

### Demodulated Input

Demodulated input can be opened using `loadAndDecodeGPIOLog`. The expected format of the input file is a sequence of 64-bit unsigned integers. Assuming `c` is an array of all the integers in the log, their meaning is:

* `c(1)` contains signal level (either a 0 or a 1) at the beginning of the log
* `c(2:)` contain durations of alternating levels, i.e.:
  * `c(2)`: how long (in µs) the signal stayed at level `c(1)`
  * `c(3)`: how long (in µs) the signal stayed at level `~c(1)`
  * `c(4)`: how long (in µs) the signal stayed at level `c(1)`
  * etc.

Such a log can be opened by `loadGPIOLog`:
```octave
y = loadGPIOLog('gpio.log');
```
and the whole sequence including decoding can be performed by:
```octave
loadAndDecodeGPIOLog('gpio.log');
```

## Demodulated Format Representation

The OOK-demodulated signal (returned by either `loadGPIOLog` or `ookDemodulate`) is represented as an n-by-2 matrix where each row denotes a transition (with the exception of the first and last row which pertain to the start and end of data, not necessarily a transition).

Each row contains the time of the event in seconds in the first element and the target signal value (either a 0 or a 1) in the second element. The rows are expected to be ordered by time in ascending order. Only the difference between the time values is important. In other words, `y` and `[y(:,1)+T, y(:,2)]` for any "reasonable" `T` should yield the same results.

`calculateDuration` can be used to convert this representation into durations, that is `d = calculateDurations(y)` returns an (n-1)-by-2 matrix where each row consists of two elements, the first one being the duration (in seconds) the signal stayed at the value contained in the second element (either a 0 or a 1).

The demodulated signal can be plotted by `plotSignal`.

## Debugging

Some functions (`findSomfy`, `decodeSomfy` and `loadAndDecodeGPIOLog`, `loadAndDecodeIQ` and `loadAndDecodeWav`) accept second optional parameter `verbose`. It defaults to 0, but setting it to either 1 or 2 makes the functions produce more logs about what is happening.

The function `plotSignal` can be useful too.
