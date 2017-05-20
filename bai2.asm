######################################################################
# 			     Circle 	                             #
######################################################################
#           						             #
######################################################################
#	This program requires the Keyboard and Display MMIO          #
#       and the Bitmap Display to be connected to MIPS.              #
#								     #
#       Bitmap Display Settings:                                     #
#	Unit Width: 1						     #
#	Unit Height: 1						     #
#	Display Width: 512					     #
#	Display Height: 512					     #
#	Base Address for Display: 0x10040000(heap)		     #
######################################################################


#Author: Hoang Duc Quan

#Create date: 27/04/2017

#Hanoi university of science and technology.
.eqv KEY_CODE 0xFFFF0004  # ASCII code to show, 1 byte 
.eqv KEY_READY 0xFFFF0000        # =1 if has a new keycode ?                                  
				# Auto clear after lw 
.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte 
.eqv DISPLAY_READY 0xFFFF0008  # =1 if the display has already to do                                  
				# Auto clear after sw 

.data
L :	.asciiz "a"
R : 	.asciiz "d"
U: 	.asciiz "w"
D: 	.asciiz "s"
points:
	.word 	200, 10
	.word 	170, 40
	.word	240, 60
	.word 	240, 30
.text	
	li $k0, KEY_CODE 	# chua ký tu nhap vao     
	li $k1, KEY_READY	# kiem tra da nhap phim nao chua  
	li $s2, DISPLAY_CODE	# hien thi ky tu  
	li $s1, DISPLAY_READY	# kiem tra xem man hinh da san sang hien thi chua
	
	addi	$s7, $0, 512			#store the width in s7
	#addi 	$s0, $0, 0x00FF0000		#pass the colour through to s0 - for every param the colour is s0, a0-3 are the xy + size params
	#circle:
	addi	$a0, $0, 256		#x = 256
	addi	$a1, $0, 256		#y = 256	
	addi	$a2, $0, 20		#r = 20
	addi 	$s0, $0, 0x00FFFF66
	jal 	DrawCircle	
	nop
moving:
	
	beq $t0,97,left
	beq $t0,100,right
	beq $t0,43,zoomin #change the radius bigger than default
	beq $t0,45,zoomout #change the radius smaller than dèault
	beq $t0,115,down
	beq $t0,119,up
	j Input
	zoomin:
		addi $s0,$0,0x00000000
		jal DrawCircle
		add $a2,$a2,1
		addi $s0,$0,0x00FFFF66
		jal DrawCircle
		j Input
	zoomout:
		beq $a2,1,Input
		addi $s0,$0,0x00000000
		jal DrawCircle
		add $a2,$a2,-1
		addi $s0,$0,0x00FFFF66
		jal DrawCircle
		j Input
	left:
		addi $s0,$0,0x00000000
		jal DrawCircle
		addi $a0,$a0,-1
		add $a1,$a1, $0
		addi $s0,$0,0x00FFFF66
		jal DrawCircle
		jal Pause
		bltu $a0,20,reboundRight
		j Input
	right: 
		addi $s0,$0,0x00000000
		jal DrawCircle
		addi $a0,$a0,1
		add $a1,$a1, $0
		addi $s0,$0,0x00FFFF66
		jal DrawCircle
		jal Pause
		bgtu $a0,492,reboundLeft
		j Input
	up: 
		addi $s0,$0,0x00000000
		jal DrawCircle
		addi $a1,$a1,-1
		add $a0,$a0,$0
		addi $s0,$0,0x00FFFF66
		jal DrawCircle
		jal Pause
		bltu $a1,20,reboundDown	
		j Input
	down: 
		addi $s0,$0,0x00000000
		jal DrawCircle
		addi $a1,$a1,1
		add $a0,$a0,$0
		addi $s0,$0,0x00FFFF66
		jal DrawCircle
		jal Pause
		bgtu $a1,492,reboundUp	
		j Input
	reboundLeft:
		li $t3 97
		sw $t3,0($k0)
		j Input
	reboundRight:
		li $t3 100
		sw $t3,0($k0)
		j Input
	reboundDown:
		li $t3 115
		sw $t3,0($k0)
		j Input
	reboundUp:
		li $t3 119
		sw $t3,0($k0)
		j Input
endMoving:...
Input:
	ReadKey: lw $t0, 0($k0) # $t0 = [$k0] = KEY_CODE
	j moving
	
	
Pause:
	addiu $sp,$sp,-4
	sw $a0, ($sp)
	la $a0,0		# speed =20ms
	li $v0, 32	 #syscall value for sleep
	syscall
	lw $a0,($sp)
	addiu $sp,$sp,4
	jr $ra
DrawCircle:
	#a0 = cx
	#a1 = cy
	#a2 = radius
	#s0 = colour
	
	addiu	$sp, $sp, -32
	sw 	$ra, 28($sp)
	sw	$a0, 24($sp)
	sw	$a1, 20($sp)
	sw	$a2, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s2, 4($sp)
	sw	$s0, ($sp)
	
	#code goes here
	sub	$s2, $0, $a2			#error =  -radius
	add	$s3, $0, $a2			#x = radius
	add	$s4, $0, $0			#y = 0 (s4)
	
	DrawCircleLoop:
	bgt 	$s4, $s3, exitDrawCircle	#if y is greater than x, break the loop (while loop x >= y)
	nop
	
	#plots 4 points along the right of the circle, then swaps the x and y and plots the opposite 4 points
	jal	plot8points
	nop
	
	add	$s2, $s2, $s4			#error += y
	addi	$s4, $s4, 1			#++y
	add	$s2, $s2, $s4			#error += y
	
	blt	$s2, 0, DrawCircleLoop		#if error >= 0, start loop again
	nop
	
	sub	$s3, $s3, 1			#--x
	sub	$s2, $s2, $s3			#error -= x
	sub	$s2, $s2, $s3			#error -= x
	
	j	DrawCircleLoop
	nop	
	
	exitDrawCircle:
	
	lw	$s0, ($sp)
	lw	$s2, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$a2, 16($sp)
	lw	$a1, 20($sp)
	lw	$a0, 24($sp)
	lw	$ra, 28($sp)
	
	addiu	$sp, $sp, 32
	
	jr 	$ra
	nop
	
plot8points:
	addiu	$sp, $sp -4
	sw	$ra, ($sp)
	
	jal	plot4points
	nop
	
	beq 	$s4, $s3, skipSecondplot
	nop
	
	#swap y and x, and do it again
	add	$t2, $0, $s4			#puts y into t2
	add	$s4, $0, $s3			#puts x in to y
	add	$s3, $0, $t2			#puts y in to x
	
	jal	plot4points
	nop
	
	#swap them back
	add	$t2, $0, $s4			#puts y into t2
	add	$s4, $0, $s3			#puts x in to y
	add	$s3, $0, $t2			#puts y in to x
		
	skipSecondplot:
		
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4
	
	jr	$ra
	nop
	
plot4points:
	#plots 4 points along the right side of the circle, then swaps the cd and cy values to do the opposite side
	#if statements are for optimisation, they work if the branches are removed
	addiu	$sp, $sp -4
	sw	$ra, ($sp)
	
	#$a0 = a0 + s3, $a2 = a1 + s4
	add	$t0, $0, $a0			#store a0 (cx in t0)
	add	$t1, $0, $a1			#store a2 (cy in t1)
	
	add	$a0, $t0, $s3			#set a0 (x for the setpixel, to cx + x)
	add	$a2, $t1, $s4			#set a2 (y for setPixel to cy + y)
	
	jal	SetPixel			#draw the first pixel
	nop
	
	sub	$a0, $t0, $s3			#cx - x
	#add	$a2, $t1, $s4			#cy + y
	
	beq	$s3, $0, skipXnotequal0 	#if s3 (x) equals 0, skip
	nop
	
	jal 	SetPixel			#if x!=0 (cx - x, cy + y)
	nop	

	skipXnotequal0:	
	sub	$a2, $t1, $s4			#cy - y (a0 already equals cx - x
	jal 	SetPixel			#no if	 (cx - x, cy - y)
	nop
	
	add	$a0, $t0, $s3
	
	beq	$s4, $0, skipYnotequal0 	#if s4 (y) equals 0, skip
	nop
	
	jal	SetPixel			#if y!=0 (cx + x, cy - y)
	nop
	
	skipYnotequal0:
	
	add	$a0, $0, $t0			
	add	$a2, $0, $t1			
	
	lw	$ra, ($sp)
	addiu	$sp, $sp, 4
	
	jr	$ra
	nop
SetPixel:
	#a0 x
	#a1 y
	#s0 colour
	addiu	$sp, $sp, -20			# Save return address on stack
	sw	$ra, 16($sp)
	sw	$s1, 12($sp)
	sw	$s0, 8($sp)			# Save original values of a0, s0, a2
	sw	$a0, 4($sp)
	sw	$a2, ($sp)

	lui	$s1, 0x1004			#starting address of the screen	
	sll	$a0, $a0, 2 			#multiply 4
	add	$s1, $s1, $a0			#x co-ord addded to pixel position
	mul  	$a2, $a2, $s7			#multiply by width (s7 declared at top of program, never saved and loaded and it should never be changed)
	mul	$a2, $a2, 4			#myltiply by the size of the pixels (4)
	add	$s1, $s1, $a2			#add y co-ord to pixel position

	sw	$s0, ($s1)			#stores the value of colour into the pixels memory address
	
	lw	$a2, ($sp)			#retrieve original values and return address
	lw	$a0, 4($sp)
	lw	$s0, 8($sp)
	lw	$s1, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20	
	
	jr	$ra
	nop
	
