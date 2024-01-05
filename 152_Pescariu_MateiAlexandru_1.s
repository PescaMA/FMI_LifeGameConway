.data
	n: .space 4 # nr. of lines
	m: .space 4 # nr. of columns
	p: .space 4 # nr. of live cells
	k: .space 4 # nr. of evolutions
	query: .space 4 # 0 for encrypt, 1 for decrypt
	maxM: .long 20 # needed for matrix traversal
	matrix: .space 404 # bordered matrix contining game state, 1 byte per state
	matrixCopy: .space 404 # intermediary matrix required for storing previous game state on evolutions
	neighbours: .long -21,-20,-19,-1,1,19,20,21 # distance from neighbours (on a 20x20 matrix)
	password: .space 12
	hexPassword: .space 28
	passLen : .space 4
	
	cinStr10: .asciz "%10s"
	cinStr22: .asciz "%22s"  
	cin: .asciz "%ld" # format for scanf with a long
	cout: .asciz "%ld " # format for printf with a long
	coutHex: .asciz "%02X" # format for hex. always outputs 2 digits.
	HexStart: .asciz "0x"  # the beginning of a hex string
	nl: .asciz "\n"   # format for new line
	
.text

	readLong: # param: address to long
		push 4(%esp)
		push $cin
		call scanf
		addl $8, %esp
		ret
		
	strlen1: # just in case. strlen didn't work for me without the -no-pie flag.
		xor %edx, %edx # just like strlen, edx register will hold the result.
		loopStrlen1:
			xor %eax,%eax
			xor %ecx, %ecx
			movl 4(%esp), %ecx
			movb (%ecx,%edx), %al
			cmp $0, %al
			je strLen1_exit
			inc %edx
			jmp loopStrlen1
		
		strLen1_exit:
		ret
		
	readString: # param: string address, string length
		push 4(%esp)
		push $cinStr10
		call scanf
		popl %eax
		call strlen1 # edx now has length
		popl %eax
		mov 8(%esp), %eax
		mov %edx, (%eax)
		ret
		
	
		
	readHex: # param: string, length.
		 # function reads hex and puts it in string
		 
		push $hexPassword
		push $cinStr22
		call scanf
		popl %eax
		call strlen1 # edx now has length
		popl %eax
		sar $1, %edx
		mov 8(%esp), %eax
		movl %edx, (%eax)
		decl (%eax)
		# reading a string (which is actually the hex) and saving the length.
		
		lea hexPassword, %esi
		movl 4(%esp), %edi
		mov $1, %ecx # skip first pair of bytes (it being "0x")
		
		readHex_loop:
			cmp %edx, %ecx
			jge readHex_exit
			
			sal $1, %ecx # 2 hex values will translate to 1 byte. so we travers with a multiple of two index the hex string.
			
			xor %eax, %eax
			movb 0(%esi,%ecx), %al
			subl $48, %eax
			cmp $10,%eax  # A-F from hex are further in the ascii table then the 10 digits.
			jl readHex_loop_1
			subl $7, %eax 
			# transforming first hex character of a pair to the top half of the byte in eax. 48 is ascii for '0' and 48 + 7 is the ascii before 'A'. We transform in binary.
			
		readHex_loop_1:
			sal $4, %eax
			
			subl $48, 1(%esi,%ecx) # not substracting eax because I need to compare with only this part.
			addb 1(%esi,%ecx), %al
			cmpb $10, 1(%esi,%ecx)
			jl readHex_loop_2
			subl $7, %eax 
			# transforming second hex character to the bottom half of the byte. 
			
		readHex_loop_2:
			sar $1, %ecx
			movb %al, -1(%edi,%ecx) # -1 because we don't save the "0x" of hex.
			
			inc %ecx
			jmp readHex_loop
		
		readHex_exit:
		ret
		
		
	printString: # param: string, length
		mov $4, %eax
		mov $1, %ebx
		mov 4(%esp), %ecx
		mov 8(%esp), %edx
		int $0x80 
		ret
		
	printHexStr: # param: just the string
		# function will print with %X which transforms in hex.
		mov $4, %eax
		mov $1, %ebx
		mov $HexStart, %ecx
		mov $2, %edx
		int $0x80 
		# outputed "0x" with syscall
	
		mov 4(%esp), %esi
		xor %ecx, %ecx
		loopPrintHex:
			cmpb $0, (%esi,%ecx,1) # finish on "\0" character
			je printHexStr_exit
			
			xor %eax, %eax
			movb (%esi,%ecx,1), %al
			push %ecx # saving caller-saved variable
			
			push %eax
			push $coutHex
			call printf
			pop %ecx
			pop %ecx
			
			pop %ecx # restoring
			
			inc %ecx
			jmp loopPrintHex
			
	printHexStr_exit:
		push $0
		call fflush
		popl %ecx
		ret

	printLong:
		push 4(%esp)
		push $cout
		call printf
		pushl $0
		call fflush
		add $12,%esp
		ret
		
	printNewLine: # with syscall
		mov $4, %eax # write
		mov $1, %ebx # to console
		mov $nl, %ecx # string to write
		mov $2, %edx  # length of string
		int $0x80 # syscall
		ret
		
	copyMatrix: # copies the max matrix of 20x20 (for simplicity)
		lea matrix, %esi
		lea matrixCopy, %edi
		xor %ecx, %ecx
		
		copyMatrixLoop:
			movl (%esi), %eax
			movl %eax, 0(%edi) # copying 4 bytes (4 states) at a time for less traversing
			addl $4, %esi
			addl $4, %edi
			addl $4, %ecx
			cmp $400, %ecx
			jle copyMatrixLoop
		ret

	printMatrix:
		pushl %ebp
		mov %esp, %ebp
		
		lea matrix, %esi
		push $1 # lineIndex in -4(%ebp)
		push $1 # columnIndex in -8(%ebp)
		 
		printMatrix__Line:
			movl -4(%ebp), %eax
			cmp n, %eax
			jg printMatrix__Exit
			
			movl $1, -8(%ebp)
			printMatrix__Column: 
				movl -8(%ebp), %eax
				cmp m,%eax
				jg printMatrix__Line_1
			
				movl -4(%ebp), %eax
				mull maxM
				addl -8(%ebp), %eax
				
				xor %edx, %edx
				movb (%esi, %eax), %dl
				push %edx
				call printLong
				addl $4, %esp
				
				incl -8(%ebp)
				jmp printMatrix__Column
				
		printMatrix__Line_1: # logical continuation of printMatrix__Line
			call printNewLine 
			
			incl -4(%ebp)
			jmp printMatrix__Line
		
		printMatrix__Exit:
			addl $8,%esp
			popl %ebp
			ret

	evolve:
		push %ebp
		movl %esp, %ebp
		
		push $1 # lineIndex in -4(%ebp)
		push $1 # columnIndex in -8(%ebp)
		push $0 # nr. of live neighbours in -12(%ebp)
		push $0 # -16(%ebp) is distance from matrix start. Necessary only for printing in testing (eax gets deleted)
		
		call copyMatrix
		lea matrixCopy, %esi
		lea matrix, %edi
		
		evolve__Line:
			movl -4(%ebp), %eax
			cmp n, %eax
			jg evolve__Exit
		
			movl $1, -8(%ebp)
			evolve__Column:
				
				movl -8(%ebp), %eax
				cmp m,%eax
				jg evolve__Line_1
			
				movl -4(%ebp), %eax
				mull maxM
				addl -8(%ebp), %eax
				
				movl %eax, -16(%ebp)
				
				incl -8(%ebp)
				
				movl $0, -12(%ebp)
				xor %ecx, %ecx
				loopNeighbour:
					
					cmp $8,%ecx
					jge evolve__Column_1
					
					lea neighbours, %edx
					movl (%edx,%ecx,4), %ebx
					addl %esi, %ebx # adding address of (%esi,%eax) in steps
					
					inc %ecx
					cmpb $1, (%ebx,%eax)
					
					jne loopNeighbour
					incl -12(%ebp)
					jmp loopNeighbour
					
					
			evolve__Column_1:
			
				/*push -12(%ebp) # used for testing nr of neighbours
				call printLong
				popl %ebx
				movl -16(%ebp), %eax*/
			
				movl -12(%ebp), %ebx
				movb $0, (%edi,%eax) # assume cell will die
				
				cmp $2, %ebx
				jl evolve__Column # underPopulation
				cmp $3, %ebx
				jg evolve__Column # overPopulation
				
				movb $1, (%edi,%eax) # assume cell will live (simpler to code)
				cmp $3, %ebx
				je evolve__Column # both live and dead cells become alive with 3 neighbours					
				cmpb $1, (%esi,%eax) # alive cell survives with 2 neigbours
				je evolve__Column
				
				movb $0, (%edi,%eax)  # dead cell isn't born with only 2 neighbours
				jmp evolve__Column
					
		evolve__Line_1:
			incl -4(%ebp)
			jmp evolve__Line
		
		evolve__Exit:
			addl $16,%esp
			pop %ebp
			ret
	
	xorEncrypt:
		pushl %ebp
		mov %esp, %ebp
		
		lea matrix, %esi
		lea password, %edi
		push $0 # lineIndex in -4(%ebp)
		push $0 # columnIndex in -8(%ebp)
		push $0 # next 8 matrix bits in -12(%ebp)
		push $0 # counter for nr bits added in -16(%ebp)
		xor %ecx, %ecx # nr of characters XOR-ed
		 
		incl n # to include the border
		incl m # to include the border
		 
		# the stopping condition of the following for loops will be reaching the end of password (and not the end of the matrix)
		xorEncrypt__Line:
			
			movl $0, -8(%ebp)
			xorEncrypt__Column: 
				movl -8(%ebp), %eax
				cmp m,%eax
				jg xorEncrypt__Line_1
				# break condition if finished line
			
				movl -4(%ebp), %eax
				mull maxM
				addl -8(%ebp), %eax
				incl -8(%ebp)
				# eax = distance from matrix start to current element. Also, increasing column index
				
				xor %edx,%edx
				movb (%esi,%eax), %dl
				sall $1, -12(%ebp)
				addl %edx, -12(%ebp)
				# adding current element to the formation of a byte
				
				incl -16(%ebp)
				cmpl $8, -16(%ebp)
				jb xorEncrypt__Column
				# continue (skip current index) condition if haven't finished the byte
				
				movl -12(%ebp), %eax
				movl $0, -12(%ebp)
				movl $0, -16(%ebp)
				# resetting byte and byte index (after copying the byte to eax)
				
				xorb %al, (%edi, %ecx)
				# the encryption
				
				incl %ecx
				cmp passLen, %ecx
				je xorEncrypt__Exit
				# exit condition for finishing all characters in message
				
				jmp xorEncrypt__Column
				#continue column loop
				
		xorEncrypt__Line_1: # logical continuation of xorEncrypt__Line
			
			incl -4(%ebp)
			movl -4(%ebp), %eax
			cmp n, %eax
			jle xorEncrypt__Line
			movl $0, -4(%ebp) 
			# when reaching the end of the matrix, we start again from beginning
			
			jmp xorEncrypt__Line
		
		xorEncrypt__Exit:
			decl n
			decl m	
			addl $16,%esp
			popl %ebp
			ret
			
	encrypt:
		push $passLen
		push $password
		call readString
		addl $8, %esp
		
		call xorEncrypt
	
		push $password
		call printHexStr
		addl $4, %esp
		
		ret
		
	decrypt:
		push $passLen
		push $password
		call readHex # transform hex to string.
		addl $8, %esp
		
		call xorEncrypt
		
		push passLen
		push $password
		call printString
		addl $8, %esp
		ret

.global main
	main:
	
	push $n
	call readLong
	pop %eax

	pushl $m
	call readLong
	popl %eax
	
	pushl $p
	call readLong
	popl %eax
	
	push %ebp
	mov %esp, %ebp
	
	push $0 # lineIndex will be -4(%ebp)
	push $0 # columnIndex will be -8(%ebp)
	xor %ecx,%ecx

	loopReadLive:
		cmp p, %ecx
		jge main_1
		push %ecx # saving the caller-saved
		
		lea -4(%ebp), %ebx
		push %ebx
		call readLong
		pop %ebx
		incl -4(%ebp) # add space for border of 0s
		
		lea -8(%ebp), %ebx
		push %ebx
		call readLong
		pop %ebx
		incl -8(%ebp) # add space for border of 0s
		
		lea matrix, %edi
		movl -4(%ebp), %eax
		mull maxM
		addl -8(%ebp), %eax
		movb $1, (%edi, %eax)
		
		pop %ecx
		incl %ecx
		jmp loopReadLive
		
main_1: #continuation of main
	addl $8, %esp
	pop %ebp
	
	pushl $k
	call readLong
	popl %eax
	
	# calculating evolutions before finishing reading
	
	xor %ecx, %ecx
	loopKvolution:
		cmp k, %ecx
		jge main_2
		push %ecx # saving it, not a parameter
		
		call evolve	
		pop %ecx
		inc %ecx
		jmp loopKvolution
		
main_2:
	pushl $query
	call readLong
	popl %eax
	
	cmpl $1, query
	je main_3
	
	cmpl $0, query
	jne exit
	call encrypt
	jmp exit
	
main_3: # accessed only in decrypt
	call decrypt
	jmp exit

	exit:
		call printNewLine
		
		push $0
		call fflush
		addl $4, %esp
		
		mov $1, %eax
		xor %ebx, %ebx
		int $0x80
