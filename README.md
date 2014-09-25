Overview
===
pario: Latin for "to bring forth", which this firmware can do in
abundance.  It generates up to 55 parallel output channels from the
BeagleBone Black's PRU, at 2.5 MHz per channel for over 100 Mbps of
output bandwidth.

This is a work in progress to try to adapt the LEDscape PRU code to work
with arbitrary output protocols.  That way we don't need to change the
firmware for ws2812, DMX, matrix or SPI outputs.  Instead all of the
bit-slicing and re-arranging can be done in the user-space on the 1 GHz ARM,
rather than the 200 MHz PRU.

Currently it seems to be limited to about 2.5 MHz on the outputs,
or 400 ns, which is sufficient for most applications that we are
considering.

However, there appear to be occasional DDR stalls that can lead to
multi-hundred ns delays in reading the data from the user buffer.
For the WS2812 or DMX outputs, this can cause a zero to be
interpreted as a one or other problems. So it might be necessary to
use both PRU devices, with one of them buffering from DDR into the
shared DRAM.  The DRAM is single ported, but the stalls are on the
order of 5ns, rather than 100ns.


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
meet the timing requirement.


Matrix
===
With a 400ns bit clock, a 256 pixel chain will take 100 usec per row.
Each panel has 8 (or 16) rows and needs to be re-scanned 8 times
for the PWM control.  This is 6500 usec, allowing for 153 Hz updates
or five scans per 30 Hz video.

This allows the reformatting of the bitmap to be done once rather than
repeated for each output.


DMA Helper
===
<pre>
uint32_t length[2];
const size_t buflen = 8192;
uint8_t buffer[2][buflen];
uint8_t * source;
size_t length;

void copier()
{
	while (!source)
		;
	uint8_t * s = source;
	size_t len = length;
	*source = NULL;

	int which = 0;
	while (len > 0)
	{
		while (ready[which])
			;
		size_t block_len = len;
		if (block_len > buflen)
			block_len = buflen;
		memcpy(buffer[which], s, buflen);
		s += block_len;
		len -= block_len;
		ready[which] = block_len;

		which = (which + 1) % 2;
	}

	while (ready[which])
		;
	ready[which] = -1;
}

void reader()
{
	int which = 0;
	while (1)
	{
		while (ready[which] == 0)
			;
		size_t len = ready[which];
		if (len == -1)
			break;
		send(buffer[which], len);
		ready[which] = 0;
		which = (which + 1) % 2;
	}
}
</pre>
