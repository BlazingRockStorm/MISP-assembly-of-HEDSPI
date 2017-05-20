.eqv SEVENSEG_LEFT    0xFFFF0011 # Dia chi cua den led 7 doan trai	
					#Bit 0 = doan a         
					#Bit 1 = doan b	
					#Bit 7 = dau . 
.eqv SEVENSEG_RIGHT   0xFFFF0010 # Dia chi cua den led 7 doan phai 
.eqv IN_ADRESS_HEXA_KEYBOARD       0xFFFF0012  
.eqv OUT_ADRESS_HEXA_KEYBOARD      0xFFFF0014	
.eqv KEY_CODE   0xFFFF0004         # ASCII code from keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        	# =1 if has a new keycode ?                                  
				        # Auto clear after lw  
.eqv DISPLAY_CODE   0xFFFF000C   	# ASCII code to show, 1 byte 
.eqv DISPLAY_READY  0xFFFF0008   	# =1 if the display has already to do  
	                                # Auto clear after sw  
.eqv MASK_CAUSE_KEYBOARD   0x0000034     # Keyboard Cause    
  
.data 
bytehex     : .byte 63,6,91,79,102,109,125,7,127,111 
storestring : .space 1000			#khoang trong de luu cac ky tu nhap tu ban phim.
stringsource : .asciiz "Bo mon ky thuat may tinh" 
Message: .asciiz "\n So ky tu trong 1s :  "
numkeyright: .asciiz  "\n So ky tu nhap dung la: "  
notification: .asciiz "\n ban co muon quay lai chuong trinh? "
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# MAIN Procsciiz ciiz edure 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.text
	li   $k0,  KEY_CODE              
	li   $k1,  KEY_READY                    
	li   $s0, DISPLAY_CODE              
	li   $s1, DISPLAY_READY  	
MAIN:         
	li $s4,0 			#dung de dem toan bo so ky tu nhap vao
  	li $s3,0				#dung de dem so vong lap 
 	li $t4,10				
  	li $t5,200			#luu gia tri so vong lap. 
	li $t6,0				#bien dem so ky tu nhap duoc trong 1s
	li $t9,0
LOOP:          
WAIT_FOR_KEY:  
 	lw   $t1, 0($k1)                  # $t1 = [$k1] = KEY_READY              
	beq  $t1, $zero,XXX               # if $t1 == 0 then Polling             
MAKE_INTER:
	addi $t6,$t6,1    		#tang bien dem ky tu nhap duoc trong 1s len 1
	teqi $t1, 1                       # if $t0 = 1 then raise an Interrupt    
#---------------------------------------------------------         
# Loop an print sequence numbers         
#---------------------------------------------------------
XXX:          
	#neu da lap dk 200 vong( 1s) se nhay den xu ly so ky tu nhap trong 1s.
	addi    $s3, $s3, 1      	# dem so ky tu nhap vao tu ban phim.
	div $s3,$t5			#lay so vong lap chia cho 200 de xac dinh da duoc 1s hay chua
	mfhi $t7				#luu phan du cua phep chia tren
	bne $t7,0,SLEEP		#neu chua duoc 1s nhay den label sleep
					#neu da duoc 1s thi nhay den nhan SETCOUNT de thuc hien in ra man hinh
SETCOUNT:
	li $s3,0				#tai lap gia tri cua $t3 ve 0 de dem lai so vong lap cho cac lan tiep theo
	li $v0,4				#bat dau chuoi lenh in ra console so ky tu nhap duoc trong 1s
	la $a0,Message
	syscall	
	li    $v0,1            		#in ra so ky tu trong 1s
	add   $a0,$t6,$zero    		
	syscall
DISPLAY_DIGITAL: 
	div $t6,$t4			#lay so ky tu nhap duoc trong 1s chia cho 10
	mflo $t7				#luu gia tri phan nguyen, gia tri nay se duoc luu o den LED ben trai
	la $s2,bytehex			#lay dia chi cua danh sach luu gia tri cua tung chu so den LED
	add $s2,$s2,$t7			#xac dinh dia chi cua gia tri 
	lb $a0,0($s2)                 	#lay noi dung cho vao $a0           
	jal   SHOW_7SEG_LEFT       	# ngay den label den LED trai
#------------------------------------------------------------------------
	mfhi $t7				#luu gia tri phan du cua phep chia, gia tri nay se duoc in ra trong den LED ben phai
	la $s2,bytehex			
	add $s2,$s2,$t7
	lb $a0,0($s2)                	# set value for segments           
	jal  SHOW_7SEG_RIGHT      # show    
#------------------------------------------------------------------------                                            
	li    $t6,0			#sau khi da hoan thanh dua bien dem so ky tu nhap duoc trong 1s ve 0 de bat dau cho chu ky moi
	beq $t9,1,ASK_LOOP
SLEEP:  
	addi    $v0,$zero,32                   
	li      $a0,5              	# sleep 5 ms         
	syscall         
	nop           	          	# WARNING: nop is mandatory here.          
	b       LOOP          	 # Loop 
END_MAIN: 
	li $v0,10
	syscall
	
SHOW_7SEG_LEFT:  
	li   $t0,  SEVENSEG_LEFT 	# assign port's address                   
	sb   $a0,  0($t0)        	# assign new value                    
	jr   $ra 
	
SHOW_7SEG_RIGHT: 
	li   $t0,  SEVENSEG_RIGHT 	# assign port's address                  
	sb   $a0,  0($t0)         	# assign new value                   
	jr   $ra 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PHAN PHUC VU NGAT
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.ktext    0x80000180         		#chuong trinh con chay sau khi interupt duoc goi.         
	mfc0  $t1, $13                  # cho biet nguyên nhân làm tham chieu dia chi bo nho khong hop
	li    $t2, MASK_CAUSE_KEYBOARD              
	and   $at, $t1,$t2              
	beq   $at,$t2, COUNTER_KETYBOARD              
	j    END_PROCESS  
	
COUNTER_KETYBOARD: 
READ_KEY:  lb   $t0, 0($k0)            	# $t0 = [$k0] = KEY_CODE 
WAIT_FOR_DIS: 
	     lw   $t2, 0($s1)            	# $t2 = [$s1] = DISPLAY_READY            
	     beq  $t2, $zero, WAIT_FOR_DIS	# if $t2 == 0 then Polling                             
SHOW_KEY: 
	     sb $t0, 0($s0)              	# hien thi ky tu vua nhap tu ban phim tren man hinh MMIO
             la  $t7,storestring			# lay $t7 lam dia chi co so cua chuoi nhap vao
             add $t7,$t7,$s4		
             sb $t0,0($t7)
             addi $s4,$s4,1
             beq $t0,10,END                          
END_PROCESS:                         
NEXT_PC:   mfc0    $at, $14	        # $at <= Coproc0.$14 = Coproc0.epc              
	    addi    $at, $at, 4	        # $at = $at + 4 (next instruction)              
            mtc0    $at, $14	       	# Coproc0.$14 = Coproc0.epc <= $at  
RETURN:   eret                       	# tro ve len ke tiep cua chuong trinh chinh
END:
	li $v0,11         
	li $a0,'\n'         		#in xuong dong
	syscall 
	li $t1,0 				#dem so ky tu da duoc xet
	li $t3,0                         	# dem so ky tu nhap dung
	li $t8,24				#luu $t8 la do dai xau da luu tru trong ma nguon.
	slt $t7,$s4,$t8			#so sanh xem do dai xau nhap tu ban phim va do dai cua xau co dinh trong ma nguon
					#xau nao nho hon thi duyet theo do dai cua xau do
	bne $t7,1, CHECK_STRING	
	add $t8,$0,$s4
	addi $t8,$t8,-1			#tru 1 vi ky tu cuoi cung la dau enter thi khong can xet.
CHECK_STRING:			
	la $t2,storestring
	add $t2,$t2,$t1
	li $v0,11			#in ra cac ky tu da nhap tu ban phim.
	lb $t5,0($t2)			#lay ky tu thu $t1 trong storestring luu vao $t5 de so sanh voi ky tu thu $t1 o stringsource
	move $a0,$t5
	syscall 
	la $t4,stringsource
	add $t4,$t4,$t1
	lb $t6,0($t4)			#lay ky tu thu $t1 trong stringsource luu vao $t6
	bne $t6,	$t5,CONTINUE		#neu 2 ky tu thu $t1 giong nhau thi tang bien dem so ky tu dung len 1
	addi $t3,$t3,1
CONTINUE: 
	addi $t1,$t1,1			#sau khi so sanh 1 ky tu, tang bien dem len 
	beq $t1,$t8,PRINT		#neu da duyet het so ky tu can xet thi in ra man hinh so ky tu nhap dung
	j CHECK_STRING		#con khong thi tiep tuc xet tiep cac ky tu 
PRINT:	li $v0,4
	la $a0,numkeyright
	syscall
	li $v0,1
	add $a0,$0,$t3
	syscall
	li $t9,1
	li $t6,0				#sau khi ket thuc chuong trinh, so ky tu dung duoc luu vao $t6 roi quay tro ve phan hien thi.
	li $t4,10				# thanh ghi $t4 gan tro lai gia tri 10 o lenh tren $t4 luu gia tri dia chi cua source code
	add $t6,$0,$t3
	b DISPLAY_DIGITAL 
ASK_LOOP: 
	li $v0, 50
	la $a0, notification
	syscall
	beq $a0,0,MAIN		
	b EXIT
EXIT: ...



