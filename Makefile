CC=gcc
SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)
FLAG=-MMD
program: $(OBJS)
	$(info link all object files to $@)
	$(CC) $(OBJS) -o $@

%.o: %.c
	$(info build $< to $@)
	$(CC) -c $(FLAG) $< -o $@

debug:
	$(info sources: $(SRCS))
	$(info objects: $(OBJS))

clear: 
	rm *.o *.exe *.d

-include *.d
