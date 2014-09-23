/** \file
 * Test the pario firmware with a square wave
 */
#include <stdio.h>
#include "pario.h"

int main(void)
{
	pario_t * const p = pario_init(0);
	uint32_t * const bits = (uint32_t*) p->virt;

	// generate a square wave on all ports
	for (int i = 0 ; i < 256 ; i += 2)
	{
		bits[i*4 + 0] = 0;
		bits[i*4 + 1] = 0;
		bits[i*4 + 2] = 0;
		bits[i*4 + 3] = 0;

		bits[(i+1)*4 + 0] = 0xFFFFFFFF & p->cmd->gpio0_mask;
		bits[(i+1)*4 + 1] = 0xFFFFFFFF & p->cmd->gpio1_mask;
		bits[(i+1)*4 + 2] = 0xFFFFFFFF & p->cmd->gpio2_mask;
		bits[(i+1)*4 + 3] = 0xFFFFFFFF & p->cmd->gpio3_mask;
	}

	while (1)
	{
		p->cmd->num_bits = 256;
		p->cmd->phys_addr = p->phys;

		// do something
	}

	return 0;
}
