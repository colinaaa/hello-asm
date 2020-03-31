.text
.globl _start

_start:
	mov $0, %ecx

LOPA:
	movb BUF1(%ecx), %al
	movb %al, BUF2(%ecx)
	inc  %al
	movb %al, BUF3(%ecx)
	add  $3, %al
	movb %al, BUF4(%ecx)
	inc  %ecx
	cmpl $10, %ecx
	jnz  LOPA
	mov  $1, %eax
	mov  $0, %ebx
	int  $0x80
	ret

.data

BUF1:
	.byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

BUF2:
	.zero 10

BUF3:
	.zero 10

BUF4:
	.zero 10
