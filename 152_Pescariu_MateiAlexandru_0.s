.data
	n: .space 4
	m: .space 4
	matrix: .space 404

	cout: .asciz "%hu\n"
	
.text

	readLong:
		mov 4(%esp), %eax
		movl $4, (%eax)
		ret

	printLong:
		push 4(%esp)
		push $cout
		call printf
		add $8,%esp
		ret

	printMatrix:
		pushl %ebp
		mov %esp, %ebp
		push 
		
		
		popl %ebp
		ret



.global main
	main:

	push $n
	call readLong
	pop %eax

	push n
	call printLong
	pop %eax

	pushl $m
	call read
	popl %eax

	call printMatrix




	exit:
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
