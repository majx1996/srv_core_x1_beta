#=========================================
# rc_core arch
#=========================================
ARCH = rv32im
ABI  = ilp32


#=========================================
# riscv tool
#=========================================
RV  = riscv32-unknown-elf

CC		= $(RV)-gcc
AS  	= $(RV)-as
RL  	= $(RV)-ranlib
LD  	= $(RV)-ld
OC  	= $(RV)-objcopy
OD  	= $(RV)-objdump
CPP 	= $(RV)-cpp
SP		= spike


#=========================================
# source
#=========================================
# test code
PATH_SRC1_DIR	= $(proj)/riscv-compliance/srcs_i
PATH_SRC2_DIR	= $(proj)/riscv-compliance/srcs_zicsr
PATH_SRC3_DIR	= $(proj)/riscv-compliance/srcs_fencei
PATH_SRC4_DIR	= $(proj)/riscv-compliance/srcs_im
PATH_LINK_DIR	= $(proj)/riscv-compliance/link
PATH_INC_DIR	= -I $(proj)/riscv-compliance/include

S_SRC			= $(wildcard $(PATH_SRC1_DIR)/*.S)
S_SRC		   += $(wildcard $(PATH_SRC2_DIR)/*.S)
S_SRC		   += $(wildcard $(PATH_SRC3_DIR)/*.S)
S_SRC		   += $(wildcard $(PATH_SRC4_DIR)/*.S)
H_INC			= $(wildcard $(PATH_INC_DIR)/*.h)
LINK_SCRIPT		= $(wildcard $(PATH_LINK_DIR)/*.ld)

# object
OBJS			= $(S_SRC:.S=.elf)
CLEAN_OBJS		= $(shell find . -name *.elf)
CLEAN_OBJS	   += $(shell find . -name *.bin)
CLEAN_OBJS	   += $(shell find . -name *.dump)
CLEAN_OBJS	   += $(shell find . -name *.trace.log)


#=========================================
# riscv tool option
#=========================================
CCFLAGS		= -march=$(ARCH) -mabi=$(ABI)  $(PATH_INC_DIR) -T $(LINK_SCRIPT)
CCFLAGS	   += -static -mcmodel=medany -fvisibility=hidden -nostartfiles -nostdlib -Wall
ODFLAGS		= -D
OCFLAGS		= -O binary
SPFLAGS0	= --log-commits -d --isa=rv32im_zicsr
SPFLAGS1	= --log-commits --isa=rv32im_zicsr


#=========================================
# command
#=========================================
.PHONY: all

all: $(OBJS)

$(OBJS): %.elf:%.S
	$(CC) $(CCFLAGS)	$< -o $@
	$(OD) $(ODFLAGS) 	$@ > $@.dump
	$(OC) $(OCFLAGS) 	$@ $@.text.bin --only-section .*text*
	$(OC) $(OCFLAGS) 	$@ $@.data.bin --only-section .*data*
	$(SP) $(SPFLAGS0)	$@ 2> $@.detail.trace.log
	$(SP) $(SPFLAGS1)	$@ 2> $@.sample.trace.log

.PHONY: clean

clean:
	rm -rf $(CLEAN_OBJS)

dbg:
	@echo $(CLEAN_OBJS)
