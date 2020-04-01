CCFLAG=-Og -ggdb3 -m32 -Wall -no-pie -nostdlib

SRC=$(wildcard *.s)
all: $(addprefix ,$(SRC:.s=))

# run as and ld by CC
%: %.s
	$(CC) $(CCFLAG) -o $@ $<

pf%: %.s
	./profile.sh $<

clean:
	fd -t x -E "*.sh" -x rm {}
	fd -e out -e o -e profile -x rm {}
	fd --regex 'callgrind.out.[0-9].*' -x rm {}
