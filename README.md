Todo:
	
	add type checking to actions for already existing types

compilation flags:
	
	-D output_file
	Writes to the output.txt file inside the root directory instead of to standard out.
	
	-D debugging_heuristic
	Runs the planner on the basic state and dumps the full heuristic run into output.txt if '-D output_file' enabled, otherwise standard output.
	
	-D assert_debugging
	Runs the planner with asserts (currently very limited)
	
	-D assert_soft_warnings
	When on with '-D assert_debug', it throws the errors into the output instead of throwing the error.