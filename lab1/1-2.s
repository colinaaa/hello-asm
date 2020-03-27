.text
.globl main

main:
	movl $BUF1, %esi
	movl $BUF2, %edi
	movl $BUF3, %ebx
	movl $BUF4, %ebp
	mov  $10, %cx

LOPA:
	movb  (%esi), %al
	movb  %al, (%edi)
	inc   %al
	movb  %al, (%ebx)
	add   $3, %al
	movb  %al, (%ebp)
	inc   %si
	inc   %di
	inc   %bp
	inc   %bx
	dec   %cx
	jnz   LOPA
	pushl %ebp
	movl  %esp, %ebp
	pushl $done
	call  printf
	leave # movl %ebp, %esp; popl %ebp
	ret

.data

BUF1:
	.byte 0,1,2,3,4,5,6,7,8,9

BUF2:
	.zero 10

BUF3:
	.zero 10

BUF4:
	.zero 10

done:
	.ascii "done\n"
