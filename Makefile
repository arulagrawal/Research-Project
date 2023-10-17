file = wg_env

comp:
	spin -a ${file}.pml

	# gcc -DMEMLIM=8192 -O2 -DNOFAIR -DXUSAFE -DVECTORSZ=2048 -DCOLLAPSE -w -o pan pan.c
	# ./pan -m10000 -a -N goal

	gcc -DMEMLIM=8192 -O3 -DNOFAIR -DNOCOMP -DXUSAFE -DVECTORSZ=4096 -DBITSTATE -w -o pan pan.c
	./pan -m10000 -a -N -G4 goal
	# try this one with multicore?
	# gcc -DBFS -DMEMLIM=8192 -O2 -DNOFAIR -DXUSAFE -DBITSTATE -DVECTORSZ=2048  -w -o pan pan.c
	# ./pan -m10000 -a -N goal
	spin -X -n123 -l -g -k ${file}.pml.trail -u10000 ${file}.pml

clean:
	rm -f pan* *.trail *.tmp