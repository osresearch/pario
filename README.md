*DANGER*

This is a work in progress to try to adapt the LEDscape PRU code to work
with arbitrary output protocols.  That way we don't need to change the
firmware for ws2812, DMX, matrix or SPI outputs.

Currently it seems to be limited to about 2.5 MHz on the outputs,
or 400 ns, which is sufficient for most applications.


WS2812
===
The WS2812 "NeoPixel" at 800 KHz are 1200ns per bit.

 +---+      +------+   +---
 |   |______|      |___|
 300ns = 0   600ns = 1

The timing spec is loose enough that 400ns/800ns for the high bits
should work.


DMX
===
250 Kbps is easy, and 750 Kbps is doable since that is more than three time
the maximum bit clock.  The delay code can be used to stretch the pulses to
meet the timing.


Matrix
===
With a 400ns bit clock, a 256 pixel chain will take 100 usec per row.
Each panel has 8 (or 16) rows and needs to be re-scanned 8 times
for the PWM control.  This is 6500 usec, allowing for 153 Hz updates
or five scans per 30 Hz video.

