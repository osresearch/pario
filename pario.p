// \file
 /* PRU based parallel output driver.
 *
 * Generates up to 55 output signals from a memory mapped user buffer.
 * Optionally also drive a clock on one pin.
 *
.origin 0
.entrypoint START

#include "pru.hp"

START:
    // Enable OCP master port
    // clear the STANDBY_INIT bit in the SYSCFG register,
    // otherwise the PRU will not be able to write outside the
    // PRU memory space and to the BeagleBon's pins.
    LBCO	r0, C4, 4, 4
    CLR		r0, r0, 4
    SBCO	r0, C4, 4, 4

    // Configure the programmable pointer register for PRU0 by setting
    // c28_pointer[15:0] field to 0x0120.  This will make C28 point to
    // 0x00012000 (PRU shared RAM).
    MOV		r0, 0x00000120
    MOV		r1, CTPPR_0
    ST32	r0, r1

    // Configure the programmable pointer register for PRU0 by setting
    // c31_pointer[15:0] field to 0x0010.  This will make C31 point to
    // 0x80001000 (DDR memory).
    MOV		r0, 0x00100000
    MOV		r1, CTPPR_1
    ST32	r0, r1

// register map
#define data_addr	r0
#define count		r1
#define gpio0_mask	r2
#define gpio1_mask	r3
#define gpio2_mask	r4
#define gpio3_mask	r5
#define clock_mask	r6
#define delay_count	r7
#define gpio0		r10
#define gpio1		r11
#define gpio2		r12
#define gpio3		r13
#define gpio0_data	r14
#define gpio1_data	r15
#define gpio2_data	r16
#define gpio3_data	r17
#define clr_out		r18
#define set_out		r19 // must be clr_out+1

	MOV gpio0, GPIO0_BASE
	MOV gpio1, GPIO1_BASE
	MOV gpio2, GPIO2_BASE
	MOV gpio3, GPIO3_BASE

READ_LOOP:
        // Load the command structure from the PRU DRAM, which is
	// mapped into the user space.
	// r0 == pointer to data buffer
	// r1 == length in entries (4 32-bit words each)
	// r2 == gpio0 mask
	// r3 == gpio1 mask
	// r4 == gpio2 mask
	// r5 == gpio3 mask
	// r6 == clock mask (always in gpio1)
	// r7 == delay cycles

	// load all eight command words
        LBCO      data_addr, CONST_PRUDRAM, 0, 8*4

        // Wait for a non-zero command
        QBEQ READ_LOOP, data_addr, #0

        // Command of 0xFF is the signal to exit
        QBEQ EXIT, data_addr, #0xFF


OUTPUT_LOOP:
		CMP count, 0
		QBEQ READ_LOOP

		// read four gpio outputs worth of data
		LBBO gpio0_data, data_addr, 0, 4*4

		// and write them to their outputs
		// gpio1 is done last for clock reasons
		AND set_out, gpio0_data, gpio0_mask
		XOR clr_out, set_out, gpio0_mask
		SBBO out_clr, gpio0_base, GPIO_CLRDATAOUT, 8

		AND set_out, gpio2_data, gpio2_mask
		XOR clr_out, set_out, gpio2_mask
		SBBO out_clr, gpio2_base, GPIO_CLRDATAOUT, 8

		AND set_out, gpio3_data, gpio3_mask
		XOR clr_out, set_out, gpio3_mask
		SBBO out_clr, gpio3_base, GPIO_CLRDATAOUT, 8

		AND set_out, gpio1_data, gpio1_mask
		XOR clr_out, set_out, gpio1_mask
		SBBO out_clr, gpio1_base, GPIO_CLRDATAOUT, 8

		// toggle the clock, if it is set
		XOR set_out, set_out, clock_mask
		XOR clr_out, clr_out, clock_mask
		SBBO out_clr, gpio1_base, GPIO_CLRDATAOUT, 8

		// delay code goes here (not implemented yet)

		// and go onto the next one
		ADD data_addr, data_addr, 4*4
		SUB count, count, 1

		QBA OUTPUT_LOOP

EXIT:
#ifdef AM33XX
    // Send notification to Host for program completion
    MOV R31.b0, PRU0_ARM_INTERRUPT+16
#else
    MOV R31.b0, PRU0_ARM_INTERRUPT
#endif

    HALT