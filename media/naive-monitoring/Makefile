GRAPHS := drift flat pathological spiky-naive spiky

all: $(GRAPHS:%=%.svg)

%.svg: %.pdf
	inkscape -l $@ $<
