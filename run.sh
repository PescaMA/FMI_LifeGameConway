defaultProgram="${1:-2}"
gcc -g -m32 -no-pie 152_Pescariu_MateiAlexandru_"$defaultProgram".s -o $defaultProgram
if [ "$2" = "" ] && [ ${defaultProgram} != "2" ]; then
    ./$defaultProgram < ${defaultProgram}_in.txt 
    else
    ./${defaultProgram}
fi
