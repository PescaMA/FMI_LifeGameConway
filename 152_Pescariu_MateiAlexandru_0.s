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
		lea matrix, %esi
		lea matrixCopy, %edi
		
		evolve__Line:
			movl $1, -8(%ebp)	
			evolve__Column:
				movl -4(%ebp), %eax
				mull maxN
				addl -8(%ebp), %eax
				lea (%esi, %eax), %edx
				
				movl $0, -12(%ebp)
				xor %ecx, %ecx
				loopNeighbour:
					
					cmp $8,%ecx
					jge evolve__Line_1
					
					lea neighbours, %eax
					movl (%eax,%ecx,4), %ebx
					
					inc %ecx
					cmpb $1, (%edx,%ebx)
					
					jne loopNeighbour
					test:
					incl -12(%ebp)
					jmp loopNeighbour
					
					
				evolve__Line_1:
				
					push -12(%ebp)
					call printLong
					popl %eax
				
				
					incl -8(%ebp)
					movl -8(%ebp), %eax
					cmp m,%eax
					jle evolve__Column
			
			call printNewLine
			incl -4(%ebp)
			movl -4(%ebp), %eax
			cmp n, %eax
			jle evolve__Line
		addl $12,%esp
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
		push %ecx
		
		call evolve	
		call printNewLine
		
		pop %ecx
		inc %ecx
		jmp loopKvolution

	exit:
	call printMatrix
	
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
