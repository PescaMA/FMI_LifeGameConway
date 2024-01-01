.data
	n: .space 4 # nr. of lines
	m: .space 4 # nr. of columns
	p: .space 4 # nr. of live cells
	k: .space 4 # nr. of evolutions
	maxN: .long 20
	# tmp: .space 4 # temporary variable
	matrix: .space 404 # bordered matrix contining game state
	matrixCopy: .space 404 # intermediary matrix for previous game state
	neighbours: .long -21,-20,-19,-1,1,19,20,21 # distance from neighbours

	cin: .asciz "%ld"
	cout: .asciz "%ld "
	nl: .asciz "\n"
	
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
		
	printNewLine:
		
		push $nl
		call printf
		pushl $0
		call fflush
		add $8,%esp
		ret
		
	copyMatrix: # copies max matrix (for simplicity)
		push $0
		
		lea matrix, %esi
		lea matrixCopy, %edi
		xor %ecx, %ecx
		
		copyMatrixLoop:
			movl (%esi), %eax
			movl %eax, 0(%edi)
			addl $4, %esi
			addl $4, %edi
			
			addl $4, %ecx
			cmp $400, %ecx
			jle copyMatrixLoop
			
		popl %ecx
		ret

	printMatrix:
		pushl %ebp
		mov %esp, %ebp
		
		lea matrix, %esi
		push $1 # lineIndex
		push $1 # columnIndex
		
		printMatrix__Line:
		
		
			movl $1, -8(%ebp)
			printMatrix__Column:
				movl -4(%ebp), %eax
				mull maxN
				addl -8(%ebp), %eax
				
				xor %edx, %edx
				movb (%esi, %eax), %dl
				push %edx
				call printLong
				addl $4, %esp
				
				incl -8(%ebp)
				movl -8(%ebp), %eax
				cmp m,%eax
				jle printMatrix__Column
				
			call printNewLine
			
			incl -4(%ebp)
			movl -4(%ebp), %eax
			cmp n, %eax
			jle printMatrix__Line
		
		printMatrix__Exit:
			addl $8,%esp
			popl %ebp
			ret

	evolve:
		
		push %ebp
		movl %esp, %ebp
		call copyMatrix
		
		push $1 # lineIndex
		push $1 # columnIndex
		push $0 # nr. of live neighbours
		push $0 # distance from matrix start. Necessary only for printing in testing (eax gets deleted)
		lea matrixCopy, %esi
		lea matrix, %edi
		
		evolve__Line:
			movl $1, -8(%ebp)	
			evolve__Column:
				
				movl -8(%ebp), %eax
				cmp m,%eax
				jg evolve__Line_1
			
				movl -4(%ebp), %eax
				mull maxN
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
				
					/*push -12(%ebp)
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
			# call printNewLine
			incl -4(%ebp)
			movl -4(%ebp), %eax
			cmp n, %eax
			jle evolve__Line
			
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
		push %ecx
		
		lea -4(%ebp), %ebx
		push %ebx
		call readLong
		pop %ebx
		incl -4(%ebp)
		
		lea -8(%ebp), %ebx
		push %ebx
		call readLong
		pop %ebx
		incl -8(%ebp)
		
		lea matrix, %edi
		movl -4(%ebp), %eax
		mull maxN
		addl -8(%ebp), %eax
		movb $1, (%edi, %eax)
		
		pop %ecx
		incl %ecx
		cmp p, %ecx
		jl loopReadLive
		
	addl $8, %esp
	pop %ebp
	
	pushl $k
	call readLong
	popl %eax
	
	# finished reading all input.
	
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
