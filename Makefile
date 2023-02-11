BUILDDIR := build
DUNE_PROJECT := aslim
DUNE_BUILD := $(DUNE_PROJECT)/_build

.PHONY: all clean

all: $(DUNE_BUILD)
	@mkdir -p $(BUILDDIR)
	@cp $(DUNE_BUILD)/default/bin/main.exe $(BUILDDIR)/aslim

clean:
	@rm -rf $(DUNE_BUILD)

cleanall: clean
	@rm -rf $(BUILDDIR)

$(DUNE_BUILD):
	@cd $(DUNE_PROJECT) && dune build --profile release
