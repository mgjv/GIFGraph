PERL = perl5
.SUFFIXES: .gif .pl
.SILENT:
LIB = ..
OPTIONS = -Tw

GIFS =  sample11.gif sample12.gif sample13.gif sample14.gif \
		sample21.gif \
		sample31.gif \
		sample41.gif \
		sample51.gif sample52.gif \
		sample91.gif sample92.gif sample93.gif

all: $(GIFS)

.pl.gif:
	$(PERL) $(OPTIONS) -I$(LIB) $<

clean:
	rm -f *.gif

test:
	$(PERL) $(OPTIONS) -I$(LIB) -M$(MODULE) sample91.pl
