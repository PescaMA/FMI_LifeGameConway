runProgram="${1:-1}" # the program you want to run. Can be read as a first parameter but it has a default of pb 1.
if [ ${runProgram} = "2" ]; then # problem 2 works with specific filenames so it's treated separately
	if [ -f "$2" ]; then
		cp $2 Exec/Examples/in.txt
	else
		cp Exec/Examples/0_in.txt Exec/Examples/in.txt
	fi
	cd Exec/Examples # we need to run from here since here is the input/output
    ../$runProgram
    echo "The created file contains:"
    cat out.txt
elif [ -f "$2" ]; then # checks if 2nd parameter is a valid file path. And that we're not running problem 2 (which uses files).
	./Exec/$runProgram < $2
elif [ "$2" != "" ]; then #
	./Exec/$runProgram
else
    ./Exec/$runProgram < ./Exec/Examples/${runProgram}_in.txt 
fi
