# Conway's game of life Simulator

This project **simulates** Conway's game of life (problems 0 and 2 only do this; problem 2 does it using files). It can also **encrypt** (or decrypt) data using a symmetric encoding based on such a simulation (problem 1).

These programs were part of a faculty project, at the The Faculty of Mathematics and Computer Science of the University of Bucharest, at Computer Science section, year I, semester I.

The main gimmick of this project is the programming language it's made in: **Assembly**. Mainly *x86 architecture for 32-bit in AT&T syntax Assembly, with Linux instructions*. I studied this programming language at the above-mentioned faculty, at ASC = Computing Systems Architecture.

The only scope of the project is to pass the requirements given: matrix of maximum 18*18 for the simulation, encrypted message of maximum length of 10 characters. The matrix is considered to be bordered by 0-s in all directions, which cannot become live cells.I got full marks on this project, whcih was tested auromatically with the inputs found in [/Exec/ExtraInputs/](/Exec/ExtraInputs/).

## Installation

As the assembly instructions are native to Linux, that kernel must be used.
Here is a list of commands for installing in Ubuntu (with a terminal):

1. Clone the repository (`git clone https://github.com/PescaMA/FMI_LifeGameConway.git`).
2. Dependencies that should already be installed: gcc, bash. If not: `sudo apt install build-essential` will have gcc, and `sudo apt install bash` for bash.
3. Dependencies that probably need to be installed: multilib for 32-bit option: `sudo apt install gcc-multilib`.

## Usage

I made a bash script for an easier time. Without it, you can compile with `gcc -g -m32 -no-pie Pb_0.s -o EXE_0`, and execute normally: `./EXE_0`. 

In my script, compile.sh also re-compiles before running run.sh.

Examples for using my script:

> bash run.sh **p1** **p2**

where **p1** = the problem you want to execute. Default is problem 1 (that encrypts).

and **p2** = either path to file which would use that file for input __or__
invalid path for reading from console. Not providing the parameter, uses the example in [/Exec/Examples](/Exec/Examples).

> Examples of usage:

**`sh run.sh`** -> will output "Secret", the decoded message in example for problem 1.

**`sh run.sh 0`** -> will output the matrix resulting from problem 0 with the example.

**`sh run.sh 2 ./Exec/ExtraInputs/test0_1.in`** -> will run program 2 with the input at that valid location. You can use some more provided examples that are in [/Exec/ExtraInputs/](/Exec/ExtraInputs/)

**`sh run.sh 0 a`** -> since "a" is not a valid location, it will read the input from the terminal.

Warning: for problem 2 it is not possible to read from terminal. It will read the example instead.

## Creating an input

> Problems 0 and 2 (2 in the in.txt folder) expect the following input:
> 
> 1. n - the nr. of line of the matrix (max 18)
> 2. m - the nr. of columns of the matrix (max 18)
> 3. v - the nr. of live cells inside the matrix
> 4. x y - v pairs of coordinates of the matrix where live cells are found. The matrix is indexed starting with 0.
> 5. k - the nr. of evolutions to be simulated.

The output will be the resulting matrix.

> Problem 1 expects the same inputs as problem 0, with the following additions:
> 
> 6. decrypt - will be 0 if you want to encrypt and 1 if you want to decrypt.
> 7. message - will have 2 formats:
> - for encrypting it will be a string of maximum 10 characters.
> - for decrypting it will be a **hexadecimal** value of the format  0xV1V2V3V4, where Vi are hex values (0-F), and the total amount of Vi's is even and at max 10 such values.

The output will be the encrypted/decrypted value in the opposing format given in input.


## Contributing

I won't be accepting contributions, as this is more a piece of history than a collaborative project.

## Credits

- Original author: Pescariu Matei-Alexandru (https://github.com/PescaMA).
- The full original requirements are present in the folder [Requirements](/Requirements/), yet are in Romanian. An english translation was made via https://www.onlinedoctranslator.com/en/translate-romanian-to-english_ro_en was also made, yet it isn't perfect.
- Project requirements were made by Cristian Rusu, Bogdan Macovei, Ruxandra Bălucea, Silviu Stăncioiu, teachers at Arhitectura Sistemelor de Operare, FMI.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
