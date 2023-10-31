file = game

comp:
	spin -a ${file}.pml
	gcc -DMEMLIM=8192 -O3 -DNOFAIR -DNOCOMP -DXUSAFE -DVECTORSZ=4096 -DBITSTATE -w -o pan pan.c
	./pan -m10000 -a -N -G4 goal
	spin -X -n123 -l -g -k ${file}.pml.trail -u10000 ${file}.pml

clean:
	rm -f pan* *.trail *.tmp