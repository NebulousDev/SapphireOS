# Sapphire OS

Sapphire is a simple [WIP] operating system built from scratch in C and NASM x86.

## Building Sapphire
### Linux (Ubuntu): 

Make sure you have make and nasm installed:

	sudo apt-get install -y nasm build-essential

Clone the repo:

	git clone https://github.com/NebulousDev/SapphireOS.git

Install GCC cross compiler binaries:

	make gcc

Then finally run the make instruction to build `bin/sapphire.iso`.

    make

Done!

## Running Sapphire

### Running in QEMU:
If you do not already have qemu, install via this command:

	sudo apt-get install -y qemu-kvm qemu virt-manager virt-viewer libvirt-bin

Run qemu:

	make qemu

---

### Running in Bochs:

Sapphire is also optionally setup to run in Bochs with the included `.bochsrc` config file

If you do not already have bochs, install via this command:*

	sudo apt-get install -y bochs bochs-x vgabios

Run bochs:

	make bochs

_*Note: you may not need `vgabios`, though some systems (WSL2) will require it_

---

### A Note on Bochs and QEMU in WSL2
Bochs and QEMU both require X11 to run, but Windows WSL2 does not natively support X11 apps. This can be resolved by running a Windows X-Server app like [VcXsrv](https://sourceforge.net/projects/vcxsrv/). Further instructions can be found [here](https://medium.com/javarevisited/using-wsl-2-with-x-server-linux-on-windows-a372263533c3).

## Cleaning
If you need to clean the build files

	make clean