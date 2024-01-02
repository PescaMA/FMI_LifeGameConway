defaultProgram="0"
gcc -g -m32 -no-pie 152_Pescariu_MateiAlexandru_"${1:-$defaultProgram}".s -o ${1:-0}
if [ "$2" = "" ]; then
    ./${1:-$defaultProgram} < ${1:-$defaultProgram}_in.txt 
    else
    ./${1:-$defaultProgram}
fi
