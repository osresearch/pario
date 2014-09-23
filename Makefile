#########
#
# Build the PRU and LEDscape libraries as well as the PRU firmware.
#
#
TARGETS-y += $(LIBDIR)/pario.bin

BIN-y += test-pario
test-pario.srcs += \
	test-pario.c \

LIB-y += libpario.a
libpario.srcs += \
	pario.c \
	pru.c \
	util.c \

include ./Makefile.common

