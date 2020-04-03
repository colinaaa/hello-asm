.text
.globl _start

_start:
	pushl %ebp
	movl  %esp, %ebp

.main_loop:
	call print_usage
	subl $8, %esp # allocate buf on stack
	leal 4(%esp), %edi
	movl $2, %esi
	call read_n # read_n(&buf, 2)
	movl $0, %eax
	movb 4(%esp), %al # now input is in 4(%esp)
	subb $0x31, %al # since '1' == 0x31
	cmpb $8, %al # compare choice:8 (good value [0, 8])
	ja   .exit # this is little tricky, both minus and above 8 will jump(from CS:APP)
	jmp  *jump_table(, %eax, 4)

.L1:
# login
	call cmp_name
	test %eax, %eax
	jz   .login_error
	call cmp_pass
	test %eax, %eax
	jz   .login_error
	movl $1, auth
	jmp  .main_loop

.L2:
# lookup goods
	call lookup_good
	movl good, %eax
	call display_good
	jmp  .main_loop

.L3:
# addto_cart
movl good, %edi
test %edi, %edi # if good == 0, means no good was selected
jz   .not_found_error
call addto_cart

# continue to compute recommendation

.L4:
# compute_recommendation
call get_time
movl $0, %ebx

.L4_loop:
	leal ga1(, %ebx, 8), %edi
	call compute_rec
	addl $3, %ebx
	cmp  $((N-1) * 3), %ebx
	jnz  .L4_loop
	call print_time
	jmp  .main_loop

.L5:
.L6:
.L7:
	jmp .main_loop

.L8:
	movl $.text, %edi
	call print_int32x
	jmp  .main_loop

.L9:
.exit:
	addl $0x8, %esp
	leave
	mov  $1, %eax # .exit
	mov  $0, %ebx
	int  $0x80 # exit(0)

.login_error:
	movl $err_login, %edi
	movl $err_login_len, %esi
	call write_n
	jmp  .main_loop

.not_found_error:
	movl $err_not_found, %edi
	movl $err_not_found_len, %esi
	call write_n
	jmp  .main_loop

# void compute_rec(void* good)
# compute the recommendation of good
compute_rec:
	movzbl 10(%edi), %ecx # discount
	imulw  13(%edi), %cx # sell_price * discount (!!improved a lot)
	movswl 11(%edi), %eax # in price
	leal   (%eax, %eax, 4), %eax # ax = 5*ax
	shll   $8, %eax
	cltd
	idivl  %ecx # div res in %eax
	movl   %eax, %ecx
	movswl 15(%edi), %esi # in number
	movswl 17(%edi), %eax # out number
	shll   $6, %eax
	cltd
	idiv   %esi # div res in %eax
	addl   %ecx, %eax
	movw   %ax, 19(%edi)
	ret

# void addto_cart(void* good)
addto_cart:
	movw 17(%edi), %ax # out_number
	cmp  15(%edi), %ax
	jl   .addto_cart_add # if out is less than in
	movl $err_good_empty, %edi
	movl $err_good_empty_len, %esi
	call write_n
	ret

.addto_cart_add:
	inc  %ax
	movw %ax, 17(%edi)
	ret

# void display_good(char* buf)
display_good:
	ret

# int lookup_good()
lookup_good:
	subl $0x20, %esp
	leal 10(%esp), %edi
	movl $10, %esi
	call read_n
	movl $-3, %edx # loop index i

.lookup_loop:
	add  $3, %edx
	cmpl $7, %edx  # valid value 0, 3, 6
	ja   .notfound
	leal 10(%esp), %edi
	leal ga1(, %edx, 8), %esi
	call str_cmp
	test %eax, %eax
	jz   .lookup_loop
	leal ga1(, %edx, 8), %eax
	movl %eax, good
	jmp  .lookup_ret

.notfound:
	movl $err_not_found, %edi
	movl $err_not_found_len, %esi
	call write_n

.lookup_ret:
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

.str_cmp_loop:
	movb (%eax, %edi), %cl
	cmpb %cl, (%eax, %esi)
	jnz  .cmp_res_nequal
	inc  %eax
	cmpl %edx, %eax
	jnz  .str_cmp_loop
	jmp  .cmp_res_equal

.cmp_res_nequal:
	movl $0, %eax

.cmp_res_equal:
	popl %ebx
	ret

# int itoa(char* buf, int i, int radix)
# convert the unsigned int i to ascii by radix
# return the width of ascii string
itoa:
	pushl %ebx
	movl  %esi, %eax # i
	movl  %edx, %ecx # radix
	movl  $0, %esi # count
	addl  $0x1f, %edi # edi points to the last byte of buf

.itoa_loop:
	xorl %edx, %edx
	div  %ecx
	movl %edx, %ebx
	orl  %eax, %edx
	test %edx, %edx
	jz   .itoa_ret
	movb digit(%ebx), %dl
	movb %dl, (%edi, %esi)
	dec  %esi
	cmp  $-0x20, %esi
	jnz  .itoa_loop

.itoa_ret:
	movl %esi, %eax
	popl %ebx
	ret

# int write_n(char* buf, int n)
# write n bytes to stdout
# return the number of bytes writen
write_n:
	pushl %ebp
	movl  %esp, %ebp
	pushl %ebx
	movl  $4, %eax
	movl  $1, %ebx # stdout
	movl  %edi, %ecx # buf
	movl  %esi, %edx # n
	int   $0x80 # syscall
	popl  %ebx
	leave
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
	movl $usage, %edi
	movl $usage_len, %esi
	call write_n
	ret

# int64_t get_time()
# return ns since startup, first 32 bits in %edx, last 32 bits in %eax
get_time:
	rdtsc
	movl %eax, time
	ret

print_time:
	movl $msg_time, %edi
	movl $msg_time_len, %esi
	call write_n
	rdtsc
	movl %eax, %edi
	subl time, %edi
	call print_int32
	ret

# void print_int32(int32_t x)
# print a 32 bits int by radix 10 with \n
print_int32:
	subl $0x24, %esp
	movb $0x0a, 0x20(%esp) #  add '\n' to the end
	movl %edi, %esi
	movl %esp, %edi
	movl $10, %edx # radix
	call itoa
	leal 0x20(%esp, %eax), %edi
	xorl $-1, %eax # invert eax
	addl $2, %eax # a = -a + 1(\n)
	movl %eax, %esi
	call write_n
	addl $0x24, %esp
	ret

# void print_int32(int32_t x)
# print a 32 bits int by radix 16 with \n
print_int32x:
	pushl %edi
	movl  $hex_prefix, %edi
	movl  $2, %esi
	call  write_n
	popl  %esi
	subl  $0x24, %esp
	movb  $0x0a, 0x20(%esp) #  add '\n' to the end
	movl  %esp, %edi
	movl  $0x10, %edx # radix
	call  itoa
	leal  0x20(%esp, %eax), %edi
	xorl  $-1, %eax # invert eax
	addl  $2, %eax # a = -a + 1(\n)
	movl  %eax, %esi
	call  write_n
	addl  $0x24, %esp
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

msg_time:
	.ascii "消耗时间(ns)："
	.equ   msg_time_len, .-msg_time

hex_prefix:
	.ascii "0x"

boss_name:
	.asciz "Wang Qing Yu" # asciz puts a 0 byte at the end
	.equ   name_len, . - boss_name

boss_pass:
	.asciz "test"
	.equ   pass_len, . - boss_pass

shop_name:
	.asciz "shop"

err_not_found:
	.asciz "商品未找到\n\n"
	.equ   err_not_found_len, . - err_not_found

err_login:
	.asciz "用户名或密码错误\n\n"
	.equ   err_login_len, . - err_login

err_good_empty:
	.asciz "商品已售空\n\n"
	.equ   err_good_empty_len, . - err_good_empty

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
	.asciz "9. 退出\n\n> "

	.equ usage_len, . - usage

digit:
	.ascii "0123456789abcdef"
	.align 4

# data section
.data

auth:
	.byte  0
	.align 4

# number of goods
.equ N, 10000

# addr of current good
good:
	.long 0

	.align 8

# padding of good is 24 bytes
ga1:
	.asciz "PEN"
	.zero  6
	.byte  10 # discount (+10)
	.word  35 # in_price (+11)
	.word  56 # sell_price (+13)
	.word  70 # in_number (+15)
	.word  25 # out_number (+17)
	.word  0  # recommandation (+19)
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

	.align 4

time:
	.long 0
