# Sapphire OS
Sapphire is a simple [WIP] operating system built from scratch in C and NASM x86.

## Building Sapphire
### Linux (Ubuntu): 

Make sure you have make, nasm and qemu installed

	sudo apt-get install qemu-kvm qemu virt-manager virt-viewer libvirt-bin nasm build-essential

Simply clone the repo

	git clone https://github.com/NebulousDev/SapphireOS.git

Then run the included build script

    ./build.sh

Done!

## Running in QEMU
Sapphire is already setup to run in QEMU. Run the included script:

	./run.sh

## Cleaning
If you need to clean the build files

	make clean