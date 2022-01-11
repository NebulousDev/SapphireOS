# Sapphire Makefile
# Ben Ratcliff 2022

SOURCE_PATH	:= ./source
BUILD_PATH	:= ./build
BIN_PATH	:= ./bin

$(BUILD_PATH) : 
	mkdir $(BUILD_PATH)

$(BIN_PATH) : 
	mkdir $(BIN_PATH)

boot_sector: $(SOURCE_PATH)/boot/boot_sector.asm | $(BUILD_PATH)
	nasm -f bin $(SOURCE_PATH)/boot/boot_sector.asm -o $(BUILD_PATH)/boot_sector.bin -i $(SOURCE_PATH)

kernel_sector: $(SOURCE_PATH)/boot/kernel_sector.asm | $(BUILD_PATH)
	nasm -f bin $(SOURCE_PATH)/boot/kernel_sector.asm -o $(BUILD_PATH)/kernel_sector.bin -i $(SOURCE_PATH)

clean:
	rm -rf $(BUILD_PATH)
	rm -rf $(BIN_PATH)

sapphire: boot_sector kernel_sector | $(BIN_PATH)

	# Create an image file (binary) of size 1.4M (512 x 2880)
	dd if=/dev/zero of=$(BIN_PATH)/sapphire.iso bs=512 count=2880

	# Write sectors to image
	dd conv=notrunc if=$(BUILD_PATH)/boot_sector.bin of=$(BIN_PATH)/sapphire.iso bs=512 count=1 seek=0
	dd conv=notrunc if=$(BUILD_PATH)/kernel_sector.bin of=$(BIN_PATH)/sapphire.iso bs=512 count=1 seek=1
