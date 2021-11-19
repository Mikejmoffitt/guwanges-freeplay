AS=asl
P2BIN=p2bin
SRC=src/main.a68
BSPLIT=bsplit  # git@github.com:mikejmoffitt/romtools.git
MAME=mame

ROME=gu-u0127b.bin
ROMO=gu-u0129b.bin

ASFLAGS=-i . -n -U

.PHONY: all clean prg.o prg.bin

all: guwanges

data: guwanges.zip
	mkdir -p $@
	cp guwange.zip $@/
	cp guwanges.zip $@/
	cd $@/ && unzip -o guwange.zip
	cd $@/ && unzip -o guwanges.zip
	rm $@/*.zip
	# Remove original version roms
	rm $@/gu-u0127.bin
	rm $@/gu-u0129.bin

prg.orig: data
	$(BSPLIT) c data/$(ROME) data/$(ROMO) prg.orig

prg.o: prg.orig
	$(AS) $(SRC) $(ASFLAGS) -o prg.o

prg.bin: prg.o
	$(P2BIN) $< $@ -r \$$-0xFFFFF

guwanges: prg.bin
	mkdir -p $@
	cp data/* $@/
	$(BSPLIT) s $< $@/$(ROME) $@/$(ROMO)

test: guwanges
	$(MAME) -debug guwanges -rompath $(shell pwd) -r 480x640

package: guwanges
	cp $< && zip -r $@-freeplay.zip *

clean:
	@-rm -rf guwanges
	@-rm -rf data
	@-rm -f guwanges-freeplay.zip
	@-rm -f prg.bin
	@-rm -f prg.o
	@-rm -f prg.orig
