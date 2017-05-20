.data

SEARCH_RESULT_RAW:
	.space 600
SEARCH_RESULT:
	.space	1000

FLAG_CASE_SENSITIVE:
	.word	1
FLAG_CASE_INSENSITIVE:
	.word	0
STRING_MAX_LENGTH:
	.word	128

ASK_FIRST_STRING:
	.asciiz	"First string?"
ASK_SECOND_STRING:
	.asciiz	"Second string?"
ASK_SEARCH_MODE:
	.asciiz	"Case sensitive searching?"

BUFFER_FIRST_STRING:
	.space 129
BUFFER_SECOND_STRING:
	.space 129
	
SEPARATOR:
	.ascii ","

SEARCH_NOT_FOUND:
	.asciiz	"String not found!!!"	
SEARCH_FOUND:
	.asciiz	"String found at offsets: "


.text
	
#################### main function ####################
main:
	li	$v0, 54				# Call input dialog
	la	$a0, ASK_FIRST_STRING		# 
	la	$a1, BUFFER_FIRST_STRING	# Read the first string
	lw	$a2, STRING_MAX_LENGTH		#
	syscall
	
	li	$v0, 54				# Call input dialog
	la	$a0, ASK_SECOND_STRING		# 
	la	$a1, BUFFER_SECOND_STRING	# Read the second string
	lw	$a2, STRING_MAX_LENGTH		#
	syscall
	
	li	$v0, 50				# Call confirm dialog
	la	$a0, ASK_SEARCH_MODE		# User will select mode of searching here
	syscall
	
	beq	$a0, 0, search_sensitive_mode	# User choose YES, set search function's mode param to FLAG_CASE_SENSITIVE
	j	search_insensitive_mode		# Otherwise, set search function's mode param to FLAG_CASE_INSENSITIVE
	
search_sensitive_mode:
	lw	$a2, FLAG_CASE_SENSITIVE	# Set the search mode
	j	call_search_function		# Then call search function
	
search_insensitive_mode:
	lw	$a2, FLAG_CASE_INSENSITIVE	# Set the search mode
	j 	call_search_function		# Then call search function

call_search_function:
	la	$a0, BUFFER_FIRST_STRING	# Call search function
	la	$a1, BUFFER_SECOND_STRING	# a0 = str1, a1 = str2, a2 = mode
	la	$a3, SEARCH_RESULT_RAW		
	jal	search				# search(a0, a1, a2, a3)
	beq	$v0, 0, search_not_found	# search(a0, a1, a2, a3)	

	la	$a0, SEARCH_RESULT_RAW		#
	addi	$a1, $v0, 0 			# Create a string that join all the result
	la	$a2, SEARCH_RESULT		# 
	lb	$a3, SEPARATOR			# 
	jal	joinint				#
	
	la	$a0, SEARCH_FOUND		#
	la	$a1, SEARCH_RESULT		# Call message dialog, print the joined result
	li	$v0, 59				#
	syscall 
	j	exit
	
search_not_found:
	la	$a0, SEARCH_NOT_FOUND		#
	li	$a1, 1				# Call message dialog, string not found
	li	$v0, 55				#
	syscall 
	j	exit
	
exit:
	li	$v0, 10
	syscall
	

#################### search function ####################
#
# 	prototype: search($a0, $a1, $a2, a3)
# 	$a0: string
# 	$a1: string
# 	$a2: mode ( 1 if case sensitive, otherwise, case insensitive)
# 	$a3: int array, store all the position $a1 appear in $a0
#	
#	Find string $a1 in string $a0
#
search:
	subi	$sp, $sp, 4
	sw	$ra, 4($sp)
	addi	$s0, $a0, 0			# $s0 = $a0
	addi	$s1, $a1, 0			# $s1 = $a1
	addi	$s3, $a3, 0			# $s3 = $a3 = result array
	li	$s4, 0				# $s4 = len($s3)
	
	addi	$a0, $s0, 0			#
	jal	strlen				# $s2 = strlen($a0)
	addi	$s2, $v0, 0			#
	
	addi	$a0, $s1, 0			#
	jal	strlen				# $s2 = strlen($a0) - strlen($a1)
	sub	$s2, $s2, $v0			#
	
	li	$s5, 0				# $s5 = current position in $s0

search_loop:
	bgt	$s5, $s2, search_return		#
	add	$a0, $s0, $s5			#
	addi	$a1, $s1, 0			# call startwith($a0+i, $a1, mode=$s2)
	jal	startswith			# 
	beq	$v0, 0, search_prepare_new_loop	# Not matched :(( 
	
	mul	$t1, $s4, 4 			# We found a match here 
	add	$t0, $s3, $t1			# Add current offset to the
	sw	$s5, ($t0)			# 	integer array $s3
	addi	$s4, $s4, 1			# and also increase $s4, we will return it later.
	
search_prepare_new_loop:
	addi	$s5, $s5, 1			# increase $s5
	j	search_loop			# and start the new loop
	
search_return:
	addi	$v0, $s4, 0			# return $s4, which is length of integer array $a3, which store matched offsets
	lw	$ra, 4($sp)			# restore return address
	addi	$sp, $sp, 4			# 	and the stack
	jr	$ra
	
	
#################### compare function ####################
#
# 	prototype: compare($a0, $a1, $a2)
# 	$a0: char
# 	$a1: char
# 	$a2: mode ( 1 if case sensitive, otherwise, case insensitive)
#
#	return 1 if a0 = a1, otherwise, return 0
#
compare:
	beq	$a2, 1, compare_return			# Case sensitive, jump to compare_return
	beq	$a0, $a1, compare_return		# $a0 = $a1 :))))
	bge	$a0, 0x61, compare_ge_a
	bge	$a0, 0x41, compare_ge_A
	
compare_ge_a:
	bgt	$a0, 0x7A, compare_return		# if 'a' <= $a0 <= 'z', then change $a0 to uppercase
	subi	$a0, $a0, 32				# otherwise, $a0 remain lowercase
	j	compare_return				#
	
compare_ge_A:
	bgt	$a0, 0x5A, compare_return		# if 'A' <= $a0 <= 'Z', then change $a0 to lowercase
	addi	$a0, $a0, 32				# otherwise, $a0 remain uppercase
	j	compare_return				#
	
compare_return:						# Compare a0 and a1 after modifying
	seq	$v0, $a0, $a1 	 			#
	jr	$ra					# set $pc to $ra


#################### strlen function ####################
#
# 	prototype: strlen($a0)
# 	$a0: string
#
#	return: $a0's length
#
strlen:
	li	$v0, 0
strlen_loop:
	add	$t0, $a0, $v0				#
	lb	$t1, ($t0)				# Very simple
	beq	$t1, 0, strlen_return			# No comment :)))
	beq	$t1, 0x0A, strlen_return		#
	addi	$v0, $v0, 1				#
	j 	strlen_loop				#
strlen_return:
	jr	$ra
	
	
#################### startswith function ####################
#
# 	prototype: startswith($a0, $a1, $a2)
# 	$a0: string
#	$a1: string
#	$a2: mode ( 1 if case sensitive, otherwise, case insensitive)
#
#	return: 1 if $a0 is started with $a1
#

startswith:
	subi	$sp, $sp, 12				#
	sw	$ra, 12($sp)				# Save return address
	sw	$s0, 8($sp)				# We also save $s0, $s1 to stack here 
	sw	$s1, 4($sp)				# because $s1, $s2 will store $a1 and $a2, respectively
	addi	$s0, $a0, 0				#
	addi	$s1, $a1, 0				#
	
startswith_loop:
	lb	$a0, ($s0)				# load the first character of $s0, $s1
	lb	$a1, ($s1)				# to $a0, $a1, respectively
	beq	$a1, 0, startswith_return		# 
	beq	$a1, 0x0a, startswith_return		# 
	jal 	compare					# Then pass it to compare function
	beq	$v0, 0, startswith_return		# 
	addi	$s0, $s0, 1				# increse offset of $s0, $s1
	addi	$s1, $s1, 1				#
	j	startswith_loop				#
	
startswith_return:
	lw	$s0, 8($sp)				#
	lw	$s1, 4($sp)				# restore old $s0, $s1
	lw	$ra, 12($sp)				# and $ra as well
	addi	$sp, $sp, 12				#
	jr	$ra


#################### atoi function ####################
#
# 	prototype: atoi($a0, $a1)
# 	$a0: int	
#	$a1: space to store the result
#
#	return: length of $a1
#
atoi:
	li	$v0, 1
	li	$t0, 1					# Clone $a0 to $t1 and $t2
	addi	$t1, $a0, 0				# We use $t1 to get length of the number
	addi	$t2, $a0, 0				# and $t2 to save each digit to array $a1
	li	$t5, 10
atoi_loop1:
	div 	$t1, $t1, 10				# Get length of the number
	beq	$t1, 0, atoi_loop2_prepare		# by deviding until it's zero
	addi	$v0, $v0, 1				# Store the length in $v0 
	j	atoi_loop1				# 
	
atoi_loop2_prepare:
	add	$t3, $a1, $v0				#
	sb	$0, ($t3)				# 
atoi_loop2:
	div	$t2, $t5				# For each deviding of $t2
	mfhi	$t4					# Get the remainder, transform it to ascii
	addi	$t4, $t4, 0x30				#
	mflo	$t2					# Get the quotient,
	subi	$t3, $t3, 1				# 
	sb	$t4, ($t3)				#
	beq	$t2, 0, atoi_return			# continue the loop if current number is greater than 0
	j	atoi_loop2				# 
atoi_return:
	jr	$ra
	

#################### joinint function ####################
#
# 	prototype: jointint($a0, $a1, $a2, $a3)
# 	$a0: array of integer
#	$a1: length($a0) 
#	$a2: space, which will store joining result
#	$a3: char, the separator
#
#	return: length of $a1 after joining
#
joinint:
	subi	$sp, $sp, 28				# So many thing to save
	sw	$ra, 28($sp)				# We save $ra, and the $s registers
	sw	$s0, 24($sp)				# 	because in later, we 'll call a sub function (atoi)
	sw	$s1, 20($sp)				#
	sw	$s2, 16($sp)				#
	sw	$s3, 12($sp)				#
	sw	$s4, 8($sp)				#
	sw	$s5, 4($sp)				#
	addi	$s0, $a0, 0				# clone $a registers to $s registers
	addi	$s1, $a1, 0				# ...
	addi	$s2, $a2, 0				# ...
	addi	$s3, $a3, 0				# ...
	li	$s4, 0					# $s4 = length of the result string
	li	$s5, 0					# $s5 = current offset of number in array $a2
	
joinint_loop:
	bge	$s5, $s1, joinint_return		#
	lw	$a0, ($s0)				# 
	addi	$a1, $s2, 0				#
	jal	atoi					#
	add	$s4, $v0, $s4				# Transform number to string, then add to $s2
	add	$s2, $s2, $v0				# 
	sb	$s3, ($s2)				# Add a separator character as well 
	add	$s2, $s2, 1				# Increase the length
	add	$s4, $s4, 1				# 
							#
	addi	$s0, $s0, 4				#
	addi	$s5, $s5, 1				# Increase the current offset
	j	joinint_loop				# Continue the loop

joinint_return:
	sb	$0, -1($s2)				# Add the NULL character to the end of joined string
	lw	$ra, 28($sp)				# And  finally, restore all saved register
	lw	$s0, 24($sp)				# $s registers and $ra register
	lw	$s1, 20($sp)				# ...
	lw	$s2, 16($sp)				# ...
	lw	$s3, 12($sp)				# ...
	lw	$s4, 8($sp)				# ...
	lw	$s5, 4($sp)				# ...
	add	$sp, $sp, 28				# restore the stack
	addi	$v0, $s4, 0				# return $s4
	jr	$ra