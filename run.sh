defaultProgram="${1:-1}"
gcc -g -m32 152_Pescariu_MateiAlexandru_"$defaultProgram".s -o $defaultProgram
if [ "$2" = "" ] && [ ${defaultProgram} != "2" ]; then
    ./$defaultProgram < ${defaultProgram}_in.txt 
    else
    ./${defaultProgram}
fi
