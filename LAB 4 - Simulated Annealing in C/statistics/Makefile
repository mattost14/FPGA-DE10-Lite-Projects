CC = gcc
CFLAGS = -g -Wall


all: place_stat

%.o: %.c %.h
	$(CC) $(CFLAGS) -c $^

place_stat : annealing.o place_stat.c 
	$(CC) $(CFLAGS) -o $@ $^ 

clean: 
	rm *.o place_stat
