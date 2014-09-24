#ifndef _pario_h_
#define _pario_h_

/** \file
 * Parallel Output driver.
 */
#include <stdint.h>

typedef struct
{
	uintptr_t phys_addr;
	uint32_t num_bits;
	uint32_t gpio0_mask;
	uint32_t gpio1_mask;
	uint32_t gpio2_mask;
	uint32_t gpio3_mask;
	uint32_t clock_mask; // clock in gpio1
	uint32_t delay_time; // in pru clocks
} pario_cmd_t;

typedef struct
{
	pario_cmd_t * const cmd;
	void * const virt;
	const uintptr_t phys;
} pario_t;

pario_t *
pario_init(
	int pru_num
);

#endif
