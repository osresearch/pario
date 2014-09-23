#########
#
# Build the PRU and LEDscape libraries as well as the PRU firmware.
#
#
TARGETS-y += $(LIBDIR)/pario.bin

LIB-y += libpario.a

libpario.srcs += \
	pru.c \
	util.c \

include ./Makefile.common

