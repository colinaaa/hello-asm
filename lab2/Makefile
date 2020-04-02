CCFLAG=-Og -ggdb3 -m32 -Wall -nostdlib -e _start

SRC=$(wildcard *.s)
all: $(addprefix ,$(SRC:.s=))

# run as and ld by CC
%: %.s
	$(CC) $(CCFLAG) -o $@ $<

pf%: %.s
	sed -iNOUSAGE -e "s/call print_usage//g" $<
	./profile.sh $<
	mv $<NOUSAGE $<

clean:
	fd -t x -E "*.sh" -x rm {}
	fd -e out -e o -e profile -x rm {}
	fd --regex 'callgrind.out.[0-9].*' -x rm {}
