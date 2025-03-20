sim: shell.c sim.c sim.h test.c test.h
	gcc -g -O0 shell.c sim.c test.c -o $@

.PHONY: clean
clean:
	rm -rf *.o *~ sim