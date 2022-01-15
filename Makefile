# Sapphire Makefile
# Ben Ratcliff 2022

.DEFAULT_GOAL	:= sapphire

SOURCE_PATH		:= ./source
BUILD_PATH		:= ./build
BIN_PATH		:= ./bin

GCC 			:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-gcc
LD				:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-ld
OBJCOPY			:= ./gcc/x86_64-elf-7.5.0-Linux-x86_64/bin/x86_64-elf-objcopy

$(BUILD_PATH) : 
	mkdir $(BUILD_PATH)

$(BUILD_PATH)/binary : | $(BUILD_PATH)
	mkdir $(BUILD_PATH)/binary

$(BIN_PATH) : 
	mkdir $(BIN_PATH)

boot: $(SOURCE_PATH)/boot/boot.asm | $(BUILD_PATH)/binary
	nasm -f bin $(SOURCE_PATH)/boot/boot.asm -o $(BUILD_PATH)/binary/boot.bin -i $(SOURCE_PATH)

entry: $(SOURCE_PATH)/boot/entry.asm | $(BUILD_PATH)/binary
	nasm -f elf $(SOURCE_PATH)/boot/entry.asm -o $(BUILD_PATH)/entry.o -i $(SOURCE_PATH)

kernel: $(SOURCE_PATH)/kernel/kernel.c | $(BUILD_PATH) $(BUILD_PATH)/binary
	$(GCC) -m32 -mno-red-zone -ffreestanding -c $(SOURCE_PATH)/kernel/kernel.c -o $(BUILD_PATH)/kernel.o

gcc:
	mkdir ./gcc
	cd ./gcc
	curl -O https://newos.org/toolchains/x86_64-elf-7.5.0-Linux-x86_64.tar.xz
	tar xf x86_64-elf-7.5.0-Linux-x86_64.tar.xz

clean:
	rm -rf $(BUILD_PATH)
	rm -rf $(BIN_PATH)

qemu:
	qemu-system-x86_64 -drive format=raw,file=./bin/sapphire.iso

bochs:
	bochs

sapphire: boot entry kernel | $(BIN_PATH)

	$(LD) -m elf_i386 -o $(BUILD_PATH)/kernel.tmp -Ttext 0x9000 $(BUILD_PATH)/entry.o $(BUILD_PATH)/kernel.o

	$(OBJCOPY) -O binary $(BUILD_PATH)/kernel.tmp $(BUILD_PATH)/binary/kernel.bin

	# Create an image file (binary) of size 1.4M (512 x 2880)
	dd if=/dev/zero of=$(BIN_PATH)/sapphire.iso bs=512 count=2880

	# Write sectors to image
	dd conv=notrunc if=$(BUILD_PATH)/binary/boot.bin of=$(BIN_PATH)/sapphire.iso bs=512 count=1 seek=0
	dd conv=notrunc if=$(BUILD_PATH)/binary/kernel.bin of=$(BIN_PATH)/sapphire.iso bs=512 count=1 seek=1
