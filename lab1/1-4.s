.text
.globl main

main:
	pushl %ebp
	movl  %esp, %ebp

main_loop:
	call print_usage
	subl $8, %esp # allocate buf on stack
	leal 4(%esp), %edi
	movl $2, %esi
	call read_n # read_n(&buf, 2)
	movl $0, %eax
	movb 4(%esp), %al # now input is in 4(%esp)
	subb $0x31, %al # since '1' == 0x31
	cmpb $8, %al # compare choice:8 (good value [0, 8])
	ja   error # this is little tricky, both minus and above 8 will jump(from CS:APP)
	jmp  *jump_table(, %eax, 4)

.L1:
# login
	call cmp_name
	test %eax, %eax
	jz   error
	call cmp_pass
	test %eax, %eax
	jz   error
	movl $1, auth
	jmp  main_loop

.L2:
# lookup goods
	call lookup_good
	movl good, %eax
	call display_good
	jmp  main_loop

.L3:
	movl good, %eax
	test %eax, %eax
	jz   error

.L4:
.L5:
.L6:
.L7:
.L8:
.L9:

error:
	addl $0x8, %esp
	leave
	ret

# void display_good(char* buf)
display_good:
	ret

# void lookup_good()
lookup_good:
	subl $0x20, %esp
	leal 10(%esp), %edi
	movl $10, %esi
	call read_n
	movl $-3, %edx # loop index i

lookup_loop:
	add  $3, %edx
	cmpl $7, %edx  # valid value 0, 3, 6
	ja   notfound
	leal 10(%esp), %edi
	leal ga1(, %edx, 8), %esi
	call str_cmp
	test %eax, %eax
	jz   lookup_loop
	leal ga1(, %edx, 8), %eax
	movl %eax, good

notfound:
	addl $0x20, %esp
	ret

# int cmp_pass()
cmp_pass:
	subl $0x20, %esp
	movl $pass_len, %esi
	leal (%esp, %esi), %edi # pass_len(%esp)
	call read_n
	movl $pass_len, %edx
	leal (%esp, %edx), %edi
	movl $boss_pass, %esi
	call str_cmp
	addl $0x20, %esp
	ret

# int cmp_name()
cmp_name:
	subl $0x20, %esp
	movl $name_len, %esi
	leal (%esp, %esi), %edi # name_len(%esp)
	call read_n
	movl $name_len, %edx
	leal (%esp, %edx), %edi
	movl $boss_name, %esi
	call str_cmp
	addl $0x20, %esp
	ret

# int str_cmp(char* lhs, char* rhs, int length)
# lhs at %edi, %rhs at %esi, length at %edx
# return 0 for not equal, length(non-zero) for equal
str_cmp:
	pushl %ebx
	movl  $0, %eax

str_cmp_loop:
	movb (%eax, %edi), %cl
	cmpb %cl, (%eax, %esi)
	jnz  res_nequal
	inc  %eax
	cmpl %edx, %eax
	jnz  str_cmp_loop
	jmp  res_equal

res_nequal:
	movl $0, %eax

res_equal:
	popl %ebx
	ret

# int read_n(char* buf, int n)
# read n bytes from stdin and change \n to \0
# buf at %edi, n at %esi
# return numbers of bytes read at %eax(include '\0')
read_n:
	pushl %ebp
	movl  %esp, %ebp
	pushl %ebx
	movl  $3, %eax # read is syscall No.3
	movl  $0, %ebx #stdin
	movl  %edi, %ecx # addr of local variable on stack(choice)
	movl  %esi, %edx # length(n)
	int   $0x80 # syscall: read(stdin, buf, n)
	movl  $0, -1(%edi, %eax) # change '\n' to '\0'
	popl  %ebx
	leave
	ret

# void print_usage()
print_usage:
	pushl %ebp
	movl  %esp, %ebp
	pushl %ebx # callee reserved

# see CS:APP 2e
# write(stdout, &usage, length)
	movl $4, %eax # write is syscall No.4
	movl $1, %ebx # stdout
	movl $usage, %ecx
	movl $usage_len, %edx # length
	int  $0x80
	popl %ebx
	leave
	ret

# read only section
.section .rodata

# jump table for switch
jump_table:
	.long .L1
	.long .L2
	.long .L3
	.long .L4
	.long .L5
	.long .L6
	.long .L7
	.long .L8
	.long .L9

boss_name:
	.asciz "Wang Qing Yu" # asciz puts a 0 byte at the end
	.equ   name_len, . - boss_name

boss_pass:
	.asciz "test"
	.equ   pass_len, . - boss_pass

shop_name:
	.asciz "shop"

usage:
	.ascii "请输入数字1-9选择功能\n"
	.ascii "1. 登录/重新登录\n"
	.ascii "2. 查找指定商品并显示信息\n"
	.ascii "3. 下订单\n"
	.ascii "4. 计算商品推荐度\n"
	.ascii "5. 排名\n"
	.ascii "6. 修改商品信息\n"
	.ascii "7. 迁移商品运行环境\n"
	.ascii "8. 显前代码段首址\n"
	.asciz "9. 退出\n"

	.equ usage_len, . - usage

# data section
.data

auth:
	.byte  0
	.align 4

# number of goods
.equ N, 30

# addr of current good
good:
	.long 0

# padding of good is 24 bytes
ga1:
	.asciz "PEN"
	.zero  6
	.byte  10
	.word  35, 56, 70, 25, 0
	.align 4

ga2:
	.asciz "BOOK"
	.zero  5
	.byte  9
	.word  12, 30, 25, 5, 0
	.align 4

gan:
	.rept  N-2
	.asciz "TempValue"
	.byte  8
	.word  15, 20, 30, 2, 0
	.align 4
	.endr
