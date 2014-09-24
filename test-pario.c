/** \file
 * Test the pario firmware with a square wave
 */
#include <stdio.h>
#include "pario.h"

int main(void)
{
	pario_t * const p = pario_init(0);
	uint32_t * const bits = (uint32_t*) p->virt;

	printf("virt: %p\n", (const void*) p->virt);
	printf("phys: %p\n", (const void*) p->phys);
	printf("cmd:  %p\n", (const void*) p->cmd);
	printf("mask0:  %08x\n", p->cmd->gpio0_mask);
	printf("mask1:  %08x\n", p->cmd->gpio1_mask);
	printf("mask2:  %08x\n", p->cmd->gpio2_mask);
	printf("mask3:  %08x\n", p->cmd->gpio3_mask);

	//p->cmd->clock_mask = 1 << 12; // gpio44
	p->cmd->clock_mask = 0;
	p->cmd->gpio1_mask &= ~p->cmd->clock_mask;

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

	p->cmd->num_bits = 256;

	while (1)
	{
		sleep(1);
		p->cmd->phys_addr = p->phys;

		//sleep(1);
		//p->cmd->phys_addr = 0;
	}

	return 0;
}
