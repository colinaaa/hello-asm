SUBDIRS := $(wildcard lab*/.)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

rt:
	$(MAKE) -C lab2 rt

.PHONY: all $(SUBDIRS) rt
