CCFLAG=-Og -ggdb3 -m32 -Wall -nostdlib -e _start

SRC=$(wildcard *.s)
EXE=$(SRC:.s=)
all: $(addprefix ,$(EXE))
# make runtime at all executable
rt: $(addprefix runtime, $(EXE))
# make profile at all executable
pf: $(addprefix profile, $(EXE))

# run as and ld by CC
%: %.s
	$(CC) $(CCFLAG) -o $@ $<

profile%: %.s
	sed -iNOUSAGE -e "s/call print_usage//g" $<
	./profile.sh $< valgrind
	mv $<NOUSAGE $<

runtime%: %.s
	sed -iNOUSAGE -e "s/call print_usage//g" $<
	./profile.sh $< runtime
	mv $<NOUSAGE $<

clean:
	fd -t x -E "*.sh" -x rm {}
	fd -e out -e o -e profile -x rm {}
	fd --regex 'callgrind.out.[0-9].*' -x rm {}
