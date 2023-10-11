comp:
	spin -a game.pml
	# gcc -BFS -DMEMLIM=8192 -DNFAIR=100 -O2 -DXUSAFE -DVECTORSZ=2048 -DCOLLAPSE -w -o pan pan.c
	# try this one with multicore?
	gcc -BFS -DMEMLIM=8192 -DNFAIR=100 -O2 -DXUSAFE -DBITSTATE -DVECTORSZ=2048  -w -o pan pan.c
	./pan -m10000 -a -N goal
	spin -p -s -r -X -v -n123 -l -g -k game.pml.trail -u10000 game.pml

clean:
	rm -f pan* *.trail *.tmp