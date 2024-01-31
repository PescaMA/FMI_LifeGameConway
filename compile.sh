runProgram="${1:-1}" # the program you want to run. Can be read as a first parameter but it has a default of pb 1.
gcc -g -m32 -no-pie Pb_"$runProgram".s -o ./Exec/$runProgram # command to compile binray Parameters mean this:
# -g for debugging information. -m32 for a 32-bit version. -no-pie is somewhat unsafe, where memory si always aligned in the same order, but otherwise a waring appears
sh ./run.sh $runProgram $2 # after compiling we also run the executable.
