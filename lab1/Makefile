CC=gcc
CCFLAG=-Og -ggdb3 -m32 -Wall -no-pie

SRC=$(wildcard *.s)
all: $(addprefix ,$(SRC:.s=))

# run as and ld by CC
%: %.s
	$(CC) $(CCFLAG) -o $@ $<

clean:
	find . -maxdepth 1 -type f -executable -delete
