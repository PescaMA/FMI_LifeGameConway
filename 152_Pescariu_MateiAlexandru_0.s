.data
	n: .space 4
	m: .space 4
	matrix: .space 404

	cout: .asciz "%hu "
	nl: .asciz "\n"
	
.text

	readLong:
		mov 4(%esp), %eax
		movl $4, (%eax)
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

	printMatrix:
		pushl %ebp
		mov %esp, %ebp
		push $1 # lineIndex
		push $1 # columnIndex
		lea matrix, %esi # (comment)
		
		printMatrix__Line:
			movl $1, -8(%ebp)
			
			printMatrix__Column:
				movl -4(%ebp), %eax
				mull n
				addl -8(%ebp), %eax
				
				push (%esi, %eax, 4)
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
			jg printMatrix__Exit
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

	call printMatrix




	exit:
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
