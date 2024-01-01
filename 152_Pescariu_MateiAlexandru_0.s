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
		
		
		push $1 # lineIndex
		push $1 # columnIndex
		lea matrix, %esi # lea neighbours, %esi
		
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
				jl printMatrix__Column
				
			call printNewLine
			
			incl -4(%ebp)
			movl -4(%ebp), %eax
			cmp n, %eax
			jge printMatrix__Exit
			jmp printMatrix__Line
		
		printMatrix__Exit:
			addl $8,%esp
			popl %ebp
			ret





.global main
	main:
	
	push $n
	call readLong
	pop %eax

	pushl $m
	call readLong
	popl %eax
	
	incl n # making space for the border.
	incl m # making space for the border.
	
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
	
	call copyMatrix
	
	
	
	
	call printMatrix

	exit:
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
