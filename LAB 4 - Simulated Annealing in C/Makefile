CC = gcc
CFLAGS = -g -Wall


all: place

%.o: %.c %.h
	$(CC) $(CFLAGS) -c $^

place : annealing.o place.c 
	$(CC) $(CFLAGS) -o $@ $^ 

clean: 
	rm *.o place
