# Définition des Variables (à compléter)
CC = c99
CFLAGS =-Wextra -pedantic
LDFLAGS = 
EXE = 

# Règles (à compléter avec des variables automatiques)
all: exemple_file test_file 


test_file: file.c file.h test_file.c
	$(CC) $(CFLAGS) $^ -o $@

exemple_file: file.c file.h exemple_file.c
	$(CC) $(CFLAGS) $< exemple_file.c -o $@

makedepend:
	file.c
	test_file.c

clean:
	rm test_file exemple_file

.PHONY: clean all makedepend

