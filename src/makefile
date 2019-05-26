MAKE=make
NASM=nasm
DD=dd
RM=rm -f
VBM=VBoxManage
BOCHS=bochs -f
BOCHS_CONFIG=./bochs.config
HARD_DISK_UUID=be05eb0e-57d3-48fa-b778-71d464720cdb
VM_NAME=zmos

default:
	$(MAKE) img

img: mbr.o  makefile
	$(RM) myos.vhd
	$(DD) if=/dev/zero of=mbr.img count=10000
	$(DD) if=mbr.bin of=mbr.img conv=notrunc
	$(VBM) convertfromraw mbr.img myos.vhd --format VHD
	$(MAKE) clean

mbr.o : mbr.asm makefile 
	$(NASM) -f bin mbr.asm -o mbr.bin

.PYONY:debug
debug:
	$(BOCHS) $(BOCHS_CONFIG)
.PHONY:run
run:
	$(VBM) internalcommands sethduuid myos.vhd $(HARD_DISK_UUID)
	$(VBM) startvm $(VM_NAME)

.PHONY: clean
clean:
	-$(RM) *.bin
	-$(RM) mbr.img
