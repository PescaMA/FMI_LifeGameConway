.data
	n: .space 4 # nr. of lines
	m: .space 4 # nr. of columns
	p: .space 4 # nr. of live cells
	k: .space 4 # nr. of evolutions
	maxM: .long 20 # needed for matrix traversal
	matrix: .space 404 # bordered matrix contining game state, 1 byte per state
	matrixCopy: .space 404 # intermediary matrix required for storing previous game state on evolutions
	neighbours: .long -21,-20,-19,-1,1,19,20,21 # distance from neighbours (on a 20x20 matrix)
	
	cin: .asciz "%ld" # format for scanf
	cout: .asciz "%ld " # format for printf
	nl: .asciz "\n"   # format for syscall with new line
	
.text

	readLong:
		push 4(%esp)
		push $cin
		call scanf
		addl $8, %esp
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
	
	# finished reading all input. Now calculating evolutions
	
	xor %ecx, %ecx
	loopKvolution:
		cmp k, %ecx
		jge exit
		push %ecx # saving it, not a parameter
		
		call evolve	
		pop %ecx
		inc %ecx
		jmp loopKvolution

	exit:
		call printMatrix
		
		mov $1, %eax
		xor %ebx, %ebx
		int $0x80
