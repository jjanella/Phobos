# 1010412215 janellaj
#####################################################################
#
# CSCB58 Winter 2025 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Jeremy Janella, 1010412215, janellaj, jeremy.janella@mail.utoronto.ca
# # Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 1024
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
# # Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
# # Are you OK with us sharing the video with people outside course staff? # - yes / no / yes, and please share this project github link as well!
# # Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################








.data
 newline: .asciiz "\n"
 resetting: .asciiz "Starting Main\n"

# Store the offsets from the ship position. First 2 are pod, second 4 are service module, last 2 are legs. 8 pixels total
S: .word 4 8 516 520 1028 1032 1536 1548
# Store the screen behind the ship
BH: .word 0:8




.eqv BASE_ADDRESS 0x10008000
.text

main:
	la $a0, resetting
	li $v0, 4
	syscall
	li $s0, BASE_ADDRESS # $s0 stores the base address for display
				# s1 is set later, ship position (including base address)
	li $s2, 0		# s2 is the sub pixel y position, mod4
	li $s3, 0		# s3 is the x velocity
	li $s5, 0		# s5 stores subpixel y velocity
	jal cBH			# clear behind
	jal lev0


mainlo:	# Main Game loop
	# Read if input was sent
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	beq $t1, 1, inp		# Apply input
main1:	# Apply gravity to velocity if not landed
	li $t9, 0xff0000
	addi $s5, $s5, 1	# Add gravity to vertical velocity
	jal land
	beqz $v0, main2		# if not landed: skip
	blez $s5, main2		# if ascending: skip
	li $s3, 0
	li $s5, 0
	
main2:	# Draw changes
	jal mship
	
	# Sleep, 25ms, 40Hz
	li $a0, 25
	li $v0, 32
	syscall
	
	j mainlo




inp:	# Handle input
	lw $t0, 4($t0)		# t0 = ascii code of input
	beq $t0, 114, inpr
	beq $t0, 113, inpq
	beq $t0, 97, inpa
	beq $t0, 119, inpw
	beq $t0, 100, inpd
	
	j main1			# return to main loop

inpa:	# accelerate left is pushed
	addi $s3, $s3, -4
	j main1

inpw:	# increase thrust is pushed
	addi $s5, $s5, -32
	j main1

inpd:	# accelerate right is pushed
	addi $s3, $s3, 4
	j main1

inpr:# reset if r if pressed
	j main
	
inpq:# Exit if q if pressed
	li $v0, 10 # terminate the program gracefully
	syscall

lev0:	# Prepare level 0
	
	addi $sp, $sp -4	# Save the address to return to main
	sw $ra, 0($sp)
	
	la $a0, ($s0)
	jal ss			# Clear the screen
	addi $a0, $s0, 27900	# Draw the large platform
	jal dlp
	addi $a0, $s0, 27088	# Draw a landing pad on the large platform
	jal dland
	addi $a0, $s0, 16512	# Draw small platform 1
	jal dsp
	addi $a0, $s0, 13964	# Draw a fuel barell on small platform 1
	jal dfuel
	addi $a0, $s0, 22940	# Draw small platform 2
	jal dsp
	addi $a0, $s0, 21400	# Draw an enemy on small platform 2
	jal dtur
	addi $a0, $s0, 30220	# Draw medium platform
	jal dmp

	
	addi $s1, $s0, 28188
	jal dship
	
	lw $t0, 0($sp)
	addi $sp, $sp, 4	# Return to main from the stack
	jr $t0

cBH:	# Clean behind ship buffer
	la $t0, BH		# &B[i]
	li $t1, 0		# Counter
	li $t9, 0		# Draw black into the behind ship buffer
cBH1:	sw $t9, 0($t0)		# B[i] = black
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	bne $t1, 8, cBH1
cBH2:	jr $ra


ss:	# Set the screen
	li $t9, 0x0	# t9 holds the background color
	li $t0, 0
ssl:	add $t1, $t0, $a0
	sw ,$t9, ($t1)
	addi $t0, $t0, 4
	beq $t0, 32768, ss0
	j ssl
ss0:	jr $ra


dsp:	# Draw small platform. Topleft address is stored in $a0. $a0 is not modified
	li $t8, 0xa4b0c8	# t8 stores blue-grey
	li $t9, 0x7e848f	# t9 stores grey
	
	sw $t9, 0($a0)		# Layer 1
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	sw $t9, 36($a0)
	sw $t9, 516($a0)	# Layer 2
	sw $t9,	520($a0)
	sw $t8,	524($a0)
	sw $t8,	528($a0)
	sw $t8,	532($a0)
	sw $t8,	536($a0)
	sw $t9,	540($a0)
	sw $t9,	544($a0)
	sw $t9,	1036($a0)	# Layer 3
	sw $t9,	1040($a0)
	sw $t9,	1044($a0)
	sw $t9,	1048($a0)
	
	jr $ra

dmp:	# Draw medium platform. Topleft address is stored in $a0. $a0 is not modified
	li $t8, 0xa4b0c8	# t8 stores blue-grey
	li $t9, 0x7e848f	# t9 stores grey
	
	sw $t9, 0($a0)		# Layer 1
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t8, 12($a0)
	sw $t8, 16($a0)
	sw $t8, 20($a0)
	sw $t8, 24($a0)
	sw $t8, 28($a0)
	sw $t8, 32($a0)
	sw $t8, 36($a0)
	sw $t8, 40($a0)
	sw $t8, 44($a0)
	sw $t8, 48($a0)
	sw $t8, 52($a0)
	sw $t8, 56($a0)
	sw $t9, 60($a0)
	sw $t9, 516($a0)	# Layer 2
	sw $t9, 520($a0)
	sw $t9, 524($a0)
	sw $t9, 528($a0)
	sw $t9, 532($a0)
	sw $t9, 536($a0)
	sw $t9, 540($a0)
	sw $t8, 544($a0)
	sw $t8, 548($a0)
	sw $t8, 552($a0)
	sw $t8, 556($a0)
	sw $t8, 560($a0)
	sw $t8, 564($a0)
	sw $t8, 568($a0)
	sw $t9, 572($a0)
	sw $t9, 1056($a0)	# Layer 3
	sw $t9, 1060($a0)
	sw $t9, 1064($a0)
	sw $t9, 1068($a0)
	sw $t9, 1072($a0)
	sw $t9, 1076($a0)
	sw $t9, 1080($a0)
	
	jr $ra
	
	
dlp:	# Display large platform. Topleft address is stored in $a0. $a0 is not modified
	li $t8, 0xa4b0c8	# t8 stores blue-grey
	li $t9, 0x7e848f	# t9 stores grey
	
	sw $t9, 0($a0)		# Draw the left three levels
	sw $t8, 4($a0)
	sw $t8, 8($a0)
	sw $t9, 516($a0)
	sw $t8, 520($a0)
	sw $t9, 1032($a0)
	
	la $t0, ($a0)
	addi $t0, $t0, 12
	li $t1 0
dlp0:	sw $t8 0($t0)		# Draw 61 more horizontal levels
	sw $t8 512($t0)
	sw $t8 1024($t0)
	sw $t9 1536($t0)
	beq $t1, 61, dlp1
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	j dlp0
dlp1:	jr $ra


	
dship:	# Draw ship. Topleft address is stored in $s1. $s1 is not modified
	li $t7, 0x828282	# t7 stores dark grey
	li $t8, 0xa4a4a4 	# t8 stores light grey
	li $t9, 0xdf9213	# t9 stores gold-bronze
	
	# Draw the ship using values from the ship list
	li $t3, 0		# counter i
	la $t0, S		# t0 = &S
	# Draw the first 8
dship1:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &write_to
	sw $t8, 0($t2)		# write the pixel
	addi $t0, $t0, 4
	addi $t3, $t3, 1
	bne $t3, 2, dship1
dship2:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &write_to
	sw $t9, 0($t2)		# write the pixel
	addi $t0, $t0, 4
	addi $t3, $t3, 1
	bne $t3, 6, dship2
dship3:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &write_to
	sw $t7, 0($t2)		# write the pixel
	addi $t0, $t0, 4
	addi $t3, $t3, 1
	bne $t3, 8, dship3
	jr $ra


dplm:	# Draw the ships thrust plume. Topleft is address of ships drawn address. $a0 is not modified
	li $t7 0xfd2f2e		# t7 stores red
	li $t8 0xff8800		# t8 stores orange
	li $t9 0xffe100		# t9 stores yellow

	sw $t7,	2564($a0)	# Layer 1
	sw $t8,	2568($a0)
	sw $t8,	2572($a0)
	sw $t7,	2576($a0)
	sw $t7,	3076($a0)	# Layer 2
	sw $t8,	3080($a0)
	sw $t8,	3084($a0)
	sw $t7,	3088($a0)
	sw $t9,	3592($a0)	# Layer 3
	sw $t9,	3596($a0)
	sw $t9,	4104($a0)	# Layer 4
	sw $t9,	4108($a0)
	
	jr $ra

dtur:	# Draw a turret. Topleft address is stored in $a0. $a0 is not modified
	li $t8, 0x828282	# t8 stores dark grey
	li $t9, 0xa4a4a4 	# t9 stores light grey
	
	sw $t8,	20($a0)		# Layer 1
	sw $t8,	24($a0)
	sw $t8,	28($a0)
	sw $t8,	512($a0)	# Layer 2
	sw $t8,	516($a0)
	sw $t8,	520($a0)
	sw $t8,	524($a0)
	sw $t8,	528($a0)
	sw $t9,	532($a0)
	sw $t9,	536($a0)
	sw $t9,	540($a0)
	sw $t8,	544($a0)
	sw $t8,	1036($a0)	# Layer 3
	sw $t9,	1040($a0)
	sw $t9,	1044($a0)
	sw $t9,	1048($a0)
	sw $t9,	1052($a0)
	sw $t9,	1056($a0)
	sw $t8,	1060($a0)
	
	jr $ra
	
dbul:	# Draw a bullet. Topleft address is stored in $a0. $a0 is not modified
	li $t8 0xfd2f2e		# t8 stores red
	li $t9 0xffe100		# t9 stores yellow
	
	sw $t8, 0($a0)
	sw $t9, 4($a0)
	sw $t9, 8($a0)
	
	jr $ra

dfuel:	# Draw a fuel barrel. Topleft address is stored in $a0. $a0 is not modified
	li $t8 0xfd2f2e		# t8 stores red
	li $t9 0xff8800		# t9 stores orange
	
	sw $t8 0($a0)		# Level 1
	sw $t8 4($a0)
	sw $t8 8($a0)
	sw $t8 12($a0)
	sw $t8 512($a0)		# Level 2
	sw $t8 516($a0)
	sw $t8 520($a0)
	sw $t8 524($a0)
	sw $t9 1024($a0)	# Level 3
	sw $t9 1028($a0)
	sw $t9 1032($a0)
	sw $t9 1036($a0)
	sw $t9 1536($a0)	# Level 4
	sw $t9 1540($a0)
	sw $t9 1544($a0)
	sw $t9 1548($a0)
	sw $t8 2048($a0)	# Level 5
	sw $t8 2052($a0)
	sw $t8 2056($a0)
	sw $t8 2060($a0)
	
	jr $ra

dland:	# Draw a landing pad. Topleft address is stored in $a0. $a0 is not modified
	li $t9, 0xdf9213 	# t9 stores light grey
	
	sw $t9, 0($a0)		# Draw the 6 edge pixels
	sw $t9, 4($a0)
	sw $t9, 516($a0)
	sw $t9, 32($a0)
	sw $t9, 36($a0)
	sw $t9, 544($a0)
	
	addi $t0, $a0, 8
	li $t1 0
dland0:	sw $t9 0($t0)		# Draw 6 more horizontal levels
	sw $t9 512($t0)
	beq $t1, 5, dland1
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	j dland0
dland1:	jr $ra
	
	beq $t2, 0xa4b0c8, mshipc # if color is platform, note it as a colision
	beq $t2, 0x7e848f, mshipc
	beq $t2, 0xdf9213, mshipc
land:	# Return 1 in v0 iff spaceship is landed. Checks $s1 for the ships position. Landed iff neither black or white under both feet
	lw $t0, 2048($s1)	# Load the pixel under left leg
	beq $t0, 0xa4b0c8, landtr# Can land on platform or bronze
	beq $t0, 0x7e848f, landtr
	beq $t0, 0xdf9213, landtr
	lw $t0, 2060($s1)	# Load the pixel under right leg
	beq $t0, 0xa4b0c8, landtr
	beq $t0, 0x7e848f, landtr
	beq $t0, 0xdf9213, landtr
	li $v0, 0
	jr $ra
landtr: li $v0, 1
	jr $ra
	
	
mship	: # move the ship (in $s1) by ($a0, $a1). 
		# 1. Write the saved pixel over the ship
		# 2. save the pixels in the new position
		# 3. draw the ship in the new position
		# if at any point a strong collision is detected, return 1
		# otherwise return 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# 1. Write the saved pixel over the ship
	la $t0, S		# t0 = &S
	la $t4, BH		# t4 = $BH
	li $t3, 0		# counter i
mship1:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &(S[i] pixel)
	lw $t5, 0($t4)		# t5 = BH[i]
	sw $t5, 0($t2)		# write t5 to S[i] pixel
	addi $t0, $t0, 4
	addi $t4, $t4, 4
	addi $t3, $t3, 1
	bne $t3, 8, mship1
		
	# X before move
	sub $t5, $s1, $s0
	andi $t5, $t5, 511
	bge $t5, 500, main
	
	
	# Calculate the new position, vert velocity is 1/32 as fast as whatever is stored to allow more granularity
	add $s1, $s1, $s3	# position accumulates x velocity
	
	add $s2, $s2, $s5	# y subpix pos += y subpix vel
	andi $t0, $s2, 0xffffffe0
	andi $s2, $s2, 0x0000001f 
	sll $t0, $t0, 4
	add $s1, $s1, $t0
	
	# X after move
	sub $t6, $s1, $s0
	andi $t6, $t6, 511
	bge $t6, 500, main
	
	# Difference should equal x velocity, otherwise hit an edge
	sub $t0, $t6, $t5
	bne $t0, $s3, main
	
	
	# Reset if the player is out of screen
	blt $s1, $s0, main
	addi $t0, $s0, 31220
	bgt $s1, $t0, main
	
	
	# 2. save the pixels in the new position
mships:	li $t3, 0		# counter i
	la $t0, S		# t0 = &S
	la $t4, BH		# t4 = $BH
	li $t5, 0		# t5 = 1 otherwise
mship2:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &(S[i] pixel)
	lw $t2, 0($t2)		# t2 = S[i] pixel
	sw $t2, 0($t4)		# BH[i] = t2
	beq $t2, 0xa4b0c8, mshipc # if color is platform, note it as a colision
	beq $t2, 0x7e848f, mshipc
	beq $t2, 0xdf9213, mshipc
	j mship3
mshipc:	addi $s1, $s1, -512	# if collision on feet is detected, raise ship by 1 and resave to draw
	bgt $t3, 5, mships	# skip move up if on the feet
	j main			# game-ending collision otherwise
mship3:	addi $t0, $t0, 4
	addi $t4, $t4, 4
	addi $t3, $t3, 1
	bne $t3,8, mship2
	
	# 3. draw the ship in the new position
	jal dship
	
	beqz $t5, mship4
	
	
	
	
mship4:	addi $sp, $sp, 4
	lw $ra, -4($sp)
	jr $ra
	
	
	
	
dbgd:	# Debug print an int
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	jr $ra
	
	
	
	
	
	
	
	
