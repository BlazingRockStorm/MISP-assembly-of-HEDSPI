.data

	String1: .asciiz  "                                            ********************* \n"
	String2: .asciiz  "*******                                     **33333333333333333** \n"
	String3: .asciiz  "*22222*                                     **33333333333333333** \n"
	String4: .asciiz  "*22222*                                     ********33333******** \n"
	String5: .asciiz  "*22222*                                            *33333*        \n"
	String6: .asciiz  "*22222*               ****************             *33333*        \n"
	String7: .asciiz  "*22222*               *1111111111111111*           *33333*        \n"
	String8: .asciiz  "*22222*               *11111*******11111**         *33333*        \n"
	String9: .asciiz  "*22222*               *11111*     **11111**        *33333*        \n"
	String10: .asciiz "*22222*               *11111*      **11111*        *33333*        \n"
	String11: .asciiz "*22222*               *11111*    **11111**         *33333*        \n"
	String12: .asciiz "*22222*************** *11111*  **11111**           *33333*        \n"
	String13: .asciiz "*2222222222222222222* *11111***11111**             *******        \n"
	String14: .asciiz "********************* *11111********                              \n"
	String15: .asciiz "       ^^^            *11111*                                     \n"
	String16: .asciiz "     ( o o )          *11111*                                     \n"
	String17: .asciiz "      (  >)           *11111*                    dce.hust.edu.vn  \n"
	String18: .asciiz "                      *******                                     \n"
	Message0: 	.asciiz "------------IN CHU-----------\n"
	Phan1:		.asciiz"1. In ra chu\n"
	Phan2:		.asciiz"2. In ra chu rong\n"
	Phan3:		.asciiz"3. Thay doi vi tri\n"
	Phan4:		.asciiz"4. Doi mau cho chu\n"
	Thoat:		.asciiz"5. Thoat\n"
	Nhap:		.asciiz"Nhap gia tri: "
	ChuL:		.asciiz"Nhap màu cho chu L(0->9): "
	ChuP:		.asciiz"Nhap màu cho chu P(0->9): "
	ChuT:		.asciiz"Nhap màu cho chu T(0->9): "
.text
#####################################
	li $t5 50 #t5 mau chu hien tai cua chu L
	li $t6 49 #t6 mau chu hien tai cua chu P
	li $t7 51 #t7 mau chu hien tai cua chu T
#####################################
main:
	la $a0, Message0	# nhap menu
	li $v0, 4
	syscall
	
	la $a0, Phan1	
	li $v0, 4
	syscall
	la $a0, Phan2	
	li $v0, 4
	syscall
	la $a0, Phan3	
	li $v0, 4
	syscall
	la $a0, Phan4	
	li $v0, 4
	syscall
	la $a0, Thoat	
	li $v0, 4
	syscall
	la $a0, Nhap	
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	Case1menu:
		addi $v1 $0 1
		bne $v0 $v1 Case2menu
		j Menu1
	Case2menu:
		addi $v1 $0 2
		bne $v0 $v1 Case3menu
		j Menu2
	Case3menu:
		addi $v1 $0 3
		bne $v0 $v1 Case4menu
		j Menu3
	Case4menu:
		addi $v1 $0 4
		bne $v0 $v1 Case5menu
		j Menu4
	Case5menu:
		addi $v1 $0 5
		bne $v0 $v1 defaultmenu
		j Exit
	defaultmenu:
		j main
#############in ra ####################	
Menu1:	
	addi $t0, $0, 0	#bien dem =0
	addi $t1, $0, 18	
	
	la $a0,String1
Loop:		beq $t1, $t0, main
		li $v0, 4
		syscall
		
		addi $a0, $a0, 68
		addi $t0, $t0, 1
		j Loop

############ bo het so o giua chi giu lai vien################
Menu2: 	addi $s0, $0, 0	#bien dem tung hàng =0
	addi $s1, $0, 18
	la $s2,String1	# $s2 la dia chi cua string1
		
Lap:	beq $s1, $s0, main
	addi $t0, $0, 0	# $t0 la bien dem tung kí tu cua 1 hàng =0
	addi $t1, $0, 68 # $t1 max 1 hàng là 68 kí tu
	
In1hang:
	beq $t1, $t0, End
	lb $t2, 0($s2)	# $t2 luu gia tri cua tung phan tu trong string1
#	li $a1 47	#so -1 tuong duong vs gia tri 47
#	li $a2 57	#so 9 tuong duong vs gia tri 57
	
	bgt	$t2, 47, Lonhon0 #neu lon hon 0 thi nhay den Lonhon0
	j Tmp
	Lonhon0: 	bgt	$t2, 57, Tmp #neu lon hon 9 nua thi van ko doi
			addi $t2 $0 0x20 # thay doi $t2 thanh dau cach
			j Tmp	
Tmp: 	li $v0, 11 # in tung ki tu
	addi $a0 $t2 0
	syscall
	
	addi $s2 $s2 1 #sang chu tiep theo
	addi $t0, $t0, 1# bien dem chu
	j In1hang
End:	addi $s0 $s0 1 # tang bien dem hàng lên 1
	j Lap

#################doi vi tri chu ############
Menu3:	addi $s0, $0, 0	#bien dem tung hàng =0
	addi $s1, $0, 18
	la $s2,String1 #$s2 luu dia chi cua string1
Lap2:	beq $s1, $s0, main
	#tao thanh 3 string nho
	sb $0 21($s2)
	sb $0 43($s2)
	sb $0 65($s2)
	#doi vi tri
	li $v0, 4 
	la $a0 44($s2) #in chu T
	syscall
	
	li $v0, 4 
	la $a0 22($s2) # in chu P
	syscall
	
	li $v0, 4 
	la $a0 0($s2) # in chu L
	syscall
	
	li $v0, 4 
	la $a0 66($s2)
	syscall
	# ghep lai thanh string ban dau
	addi $t1 $0 0x20
	sb $t1 21($s2)
	sb $t1 43($s2)
	sb $t1 65($s2)
	
	addi $s0 $s0 1
	addi $s2 $s2 68
	j Lap2

############ doi mau cho chu ################
Menu4: 
NhapmauL:	li 	$v0, 4		
		la 	$a0, ChuL
		syscall
	
		li 	$v0, 5		# lay mau cua ki tu L
		syscall

		blt	$v0,0, NhapmauL
		bgt	$v0,9, NhapmauL
		
		addi	 $s3 $v0 48	#$s3 luu mau cua chu L
NhapmauP:	li 	$v0, 4		
		la 	$a0, ChuP
		syscall
	
		li 	$v0, 5		# lay mau cua ki tu P
		syscall

		blt	$v0, 0, NhapmauP
		bgt	$v0, 9, NhapmauP
				
		addi	 $s4  $v0 48	#$s4 luu mau cua chu P
NhapmauT:	li 	$v0, 4		
		la 	$a0, ChuT
		syscall
	
		li 	$v0, 5		# lay mau cua ki tu T
		syscall

		blt	$v0, 0, NhapmauT
		bgt	$v0, 9, NhapmauT
			
		addi	 $s5 $v0 48	#$s5 luu mau cua chu T
	
	addi $s0, $0, 0	#bien dem tung hàng =0
	addi $s1, $0, 18
	la $s2,String1	# $s2 la dia chi cua string1
	li $a1 48 #gia tri cua so 0
	li $a2 57 #gia tri cua so 9
#	li $t3 21 
#	li $t4 43 
Lapdoimau:	beq $s1, $s0, updatemau
		addi $t0, $0, 0	# $t0 la bien dem tung kí tu cua 1 hàng =0
		addi $t1, $0, 68 # $t1 max 1 hàng là 68 kí tu
	
In1hangdoimau:
	beq $t1, $t0, Enddoimau
	lb $t2, 0($s2)	# $t2 luu gia tri cua tung phan tu trong string1
	CheckL: bgt	$t0, 21, CheckP #kiem tra het chu L chua
		beq	$t2, $t5, fixL
		j Tmpdoimau
	CheckP: bgt	$t0, 43, CheckT #kiem tra het chu P chua
		beq	$t2, $t6, fixP
		j Tmpdoimau
	CheckT: beq	$t2, $t7, fixT
		j Tmpdoimau
		
fixL: 	sb $s3 0($s2)
	j Tmpdoimau
fixP: 	sb $s4 0($s2)
	j Tmpdoimau
fixT: 	sb $s5 0($s2)
	j Tmpdoimau
Tmpdoimau: 	addi $s2 $s2 1 #sang chu tiep theo
		addi $t0, $t0, 1# bien dem chu
		j In1hangdoimau
Enddoimau:		li $v0, 4  
		addi $a0 $s2 -68
		syscall
		addi $s0 $s0 1 # tang bien dem hàng lên 1
		j Lapdoimau
updatemau: move $t5 $s3
	move $t6 $s4
	move $t7 $s5
	j main	
Exit:
