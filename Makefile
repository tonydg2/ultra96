build: scripts/run.tcl scripts/build.tcl scripts/load_git_hash.tcl
	cd scripts; \
		tclsh run.tcl -clean

all: scripts/run.tcl scripts/build.tcl scripts/load_git_hash.tcl
	rm -rf DEFAULT_PROJECT PRJ0
	cd scripts; \
		tclsh run.tcl -clean -proj -name PRJ0; \
		tclsh run.tcl -clean

project: scripts/run.tcl scripts/build.tcl scripts/load_git_hash.tcl
	rm -rf DEFAULT_PROJECT PRJ0
	cd scripts; \
		tclsh run.tcl -clean -proj -name PRJ0

clean:
	rm -rf DEFAULT_PROJECT PRJ0 output_products output_products_previous
