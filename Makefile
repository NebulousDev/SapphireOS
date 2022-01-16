# Sapphire Makefile
# Ben Ratcliff 2022

.DEFAULT_GOAL		:= disk

ISO_NAME			:= sapphire.iso

GCC 				:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-gcc
NASM				:= nasm
LD					:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-ld
OBJCOPY				:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-objcopy
GDB					:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-gdb
NM					:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-nm
READELF				:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-readelf

GCC_ARGS			:= -m32 -Wall -mno-red-zone -ffreestanding -g
GCC_DEPEND_ARGS		:= -MMD -MF $(@:.o=.d)
NASM_ARGS			:= -f elf32 -F dwarf -g
NASM_DEPEND_ARGS	:= -MD $(@:.o=.d)
LD_ARGS				:= -m elf_i386
LD_SCRIPT			:= kernel.ld

SOURCE_PATH			:= ./source
BUILD_PATH			:= ./build
BIN_PATH			:= ./bin

SOURCE_TREE			:= $(shell find $(SOURCE_PATH) -type d)
SOURCE_FILES		:= $(addsuffix /*, $(SOURCE_TREE))
SOURCE_FILES		:= $(wildcard $(SOURCE_FILES))

C_SOURCES			:= $(filter %.c, $(SOURCE_FILES))
C_HEADERS			:= $(filter %.h, $(SOURCE_FILES))
C_OBJS				:= $(subst $(SOURCE_PATH),$(BUILD_PATH),$(C_SOURCES:%.c=%.o))
C_DEPEND			:= $(subst $(SOURCE_PATH),$(BUILD_PATH),$(C_SOURCES:%.c=%.d))

ASM_SOURCES			:= $(filter %.asm, $(SOURCE_FILES))
ASM_OBJS			:= $(subst $(SOURCE_PATH),$(BUILD_PATH),$(ASM_SOURCES:%.asm=%.o))
ASM_DEPEND			:= $(subst $(SOURCE_PATH),$(BUILD_PATH),$(ASM_SOURCES:%.asm=%.d))

ALL_OBJS			:= $(ASM_OBJS) $(C_OBJS)
BOOT_OBJS			:= $(filter $(BUILD_PATH)/boot/%, $(ALL_OBJS))
KERNEL_OBJS			:= $(filter-out $(BOOT_OBJS), $(ALL_OBJS))

################################
#       COMPILE RECIPIES       #
################################

-include $(C_DEPEND)

$(BUILD_PATH)/%.o: $(SOURCE_PATH)/%.asm
	@ echo "> [NASM] Compiling '$^'..."
	@ mkdir -p $(@D)
	@ $(NASM) $(NASM_ARGS) $(NASM_DEPEND_ARGS) -o $@ -i $(SOURCE_PATH)/ $^

$(BUILD_PATH)/%.o: $(SOURCE_PATH)/%.c
	@ echo "> [GCC] Compiling '$^'..."
	@ mkdir -p $(@D)
	@ $(GCC) $(GCC_ARGS) -o $@ -c $^

################################
#       UTILITY RECIPIES       #
################################

gcc:
	mkdir ./gcc
	cd ./gcc
	curl -O https://newos.org/toolchains/x86_64-elf-7.5.0-Linux-x86_64.tar.xz
	tar xf x86_64-elf-7.5.0-Linux-x86_64.tar.xz

qemu:
	qemu-system-x86_64 -drive format=raw,file=./bin/sapphire.iso

qemu-gdb:
	qemu-system-x86_64 -drive format=raw,file=./bin/sapphire.iso -smp 2 -s

gdb:
	$(GDB) \
		-ex "set confirm off" \
		-ex "set arch i386:x86-64:intel" \
		-ex "add-symbol-file ./build/symbols/boot.elf -readnow 0x7c00" \
		-ex "add-symbol-file ./build/symbols/entry.elf -readnow 0x7e00" \
		-ex "target remote :1234" \
		$(BUILD_PATH)/symbols/kernel.elf

bochs:
	bochs

nm:
	$(NM) -n $(BIN_PATH)/symbols/kernel.elf

readelf:
	$(READELF) -e $(BIN_PATH)/symbols/kernel.elf

clean:
	rm -rf $(BUILD_PATH) $(BIN_PATH)

all: disk

################################
#         ISO RECIPIES         #
################################

disk: $(ALL_OBJS)

	@ mkdir -p $(BIN_PATH)
	@ mkdir -p $(BIN_PATH)/symbols
	@ mkdir -p $(BIN_PATH)/binary

	@ echo "| Linking..."
	@ $(LD) $(LD_ARGS) -T $(LD_SCRIPT) -o $(BIN_PATH)/symbols/kernel.elf $(ALL_OBJS)

	@ echo "| Building Binary..."
	@ $(OBJCOPY) -O binary $(BIN_PATH)/symbols/kernel.elf $(BIN_PATH)/binary/kernel.bin
 
	@ #Create an image file (binary) of size 1.4M (512 x 2880)
	@ dd if=/dev/zero of=$(BIN_PATH)/$(ISO_NAME) bs=512 count=2880

	@ #Write sectors to image
	@ dd conv=notrunc if=$(BIN_PATH)/binary/kernel.bin of=$(BIN_PATH)/$(ISO_NAME) bs=512 count=4 seek=0

	@ echo "| '$(ISO_NAME)' compiled."
