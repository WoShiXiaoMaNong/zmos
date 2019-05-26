MAKE=make
NASM=nasm
DD=dd
RM=rm -f
VBM=VBoxManage
HARD_DISK_UUID=be05eb0e-57d3-48fa-b778-71d464720cdb
VM_NAME=zmos
img: mbr.bin  makefile
	$(RM) myos.vhd
	$(DD) if=/dev/zero of=mbr.img count=10000
	$(DD) if=mbr.bin of=mbr.img conv=notrunc
	$(VBM) convertfromraw mbr.img myos.vhd --format VHD

	$(MAKE) clean
mbr.bin : ipl.asm makefile 
	$(NASM) ipl.asm -o mbr.bin


.PHONY:run
run:
	$(VBM) internalcommands sethduuid myos.vhd $(HARD_DISK_UUID)
	$(VBM) startvm $(VM_NAME)

.PHONY: clean
clean:
	-$(RM) *.bin
	-$(RM) mbr.img
