mock := $(subst mock/,,$(shell find mock/ -type f -iname '*.vhd' -o -iname '*.vhdl'))
src := $(subst src/,,$(shell find src/ -type f -iname '*.vhd' -o -iname '*.vhdl'))
sim := $(subst sim/,,$(shell find sim/ -type f -iname '*.vhd' -o -iname '*.vhdl'))

std ?= 08

workdir?=./.cache
wd=--workdir=$(workdir)

flags = --ieee=synopsys -fexplicit --std=$(std)

.PHONY: $(mock) $(src) $(sim) s r m clean

all: dirs $(mock) $(src) $(sim) done

dirs:
	@mkdir -p .cache
	@mkdir -p out

$(mock):
	@printf "$(ELABORATING)"
	@ghdl -a $(wd) $(flags) mock/$@
	@ghdl -e $(wd) $(flags) $(NAME)

$(src):
	@printf "$(ELABORATING)"
	@ghdl -a $(wd) $(flags) src/$@
	@ghdl -e $(wd) $(flags) $(NAME)
	
$(sim):
	@printf "$(ELABORATIN8)"
	@ghdl -a $(wd) $(flags) sim/$@
	@ghdl -e $(wd) $(flags) $(NAME)
	@printf "Executing $(PURPLE)$(basename $@)$(NC) testbench...\n"
	@ghdl -r $(wd) $(flags) $(NAME) --wave=out/$(NAME).ghw || true
	@printf "Done $(PURPLE)$(basename $@)$(NC) testbench, see $(BLUE)out/$(NAME).ghw$(NC) for results.\n"
	
# Abbreviations
sim: dirs $(sim)
src: dirs $(src)
mock: dirs $(mock)

done:
	@printf "$(BLUE)✅️ Done, thank you for simulating with us!$(NC)\n"
	
clean:
	@rm -rf out/*
	@rm -rf .cache/*

help:
	@printf "$(NC)Usage: make $(PURPLE)[params]$(NC) ...\n"
	@printf "Options:\n\
	  all                     Elaborate all and run testbenches ${BLUE}[default]${NC}.\n\
	  mock                    Elaborate mock, files inside $(PURPLE)mock/$(NC).\n\
	  sim                     Elaborate and run testbenches, files inside $(PURPLE)sim/$(NC). \n\
	  src                     Elaborate rtl, files inside $(PURPLE)src/$(NC).\n\
	  clean                   Clear cache and output.\n\
	\n\
	Parameters:\n\
	  mock=FILES              Explicit mock files, include inner path,\n\
	                          e.g. $(PURPLE)mock_sensor_readout.vhd$(NC)\n\
	  sim=FILES               Explicit sim files, include inner path,\n\
	                          e.g. $(PURPLE)read_write_file_ex.vhd$(NC)\n\
	  src=FILES               Explicit src/rtl files, include inner path,\n\
	                          e.g. $(PURPLE)spi/mux_spi.vhd$(NC)\n\
	  std=STANDARD            Which VHDL standard to use: 87, 93, 02, 08, 19\n\
	                          Defaults to 08.\n\
Note: \n\
If a parameter is not provided, it will recursively include all files.\n\
The options have the same name as parameters, but always precedes the parameter, e.g.:\n\
$(PURPLE)make src src=user_await_line.vhd$(NC) to elaborate only this file.\n"

NAME = $(notdir $(basename $@))
ELABORATING = Elaborating $(PURPLE)$(basename $@)$(NC) with $(std) standard...\n

BLUE=\033[0;34m
PURPLE=\033[0;35m
RED=\033[0;31m
NC=\033[0m

