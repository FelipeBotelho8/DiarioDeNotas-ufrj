CP=fpc

TRABALHO= main

all: $(TRABALHO)

main:
	$(CP) -o$(TRABALHO) $(TRABALHO).pas

clean:
	rm -f *.o *.ppu $(TRABALHO)