.text
.globl main

main:
	mov $0, %ecx

LOPA:
	movb  BUF1(%ecx), %al
	movb  %al, BUF2(%ecx)
	inc   %al
	movb  %al, BUF3(%ecx)
	add   $3, %al
	movb  %al, BUF4(%ecx)
	inc   %ecx
	cmpl  $10, %ecx
	jnz   LOPA
	pushl %ebp
	movl  %esp, %ebp
	push  $done
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
	.asciz "done\n"
