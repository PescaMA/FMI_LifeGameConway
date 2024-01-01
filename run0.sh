gcc -g -m32 -no-pie 152_Pescariu_MateiAlexandru_0.s -o 0
if [ "$1" = "" ]; then
	echo "$1"
    ./0 < 0_in.txt
    else
    ./0
fi
