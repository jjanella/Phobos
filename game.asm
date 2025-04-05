# 1010412215 janellaj
#####################################################################
#
# CSCB58 Winter 2025 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID, official email
# # Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 1024 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
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

# Store the offsets from the ship position. First 8 are pod, second 8 are service module, last 4 are legs. 20 pixels total
S: .word 8 12 516 520 524 528 1032 1036 1540 1544 1548 1552 2052 2056 2060 2064 2048 2068 2560 2580
# Store the screen behind the ship
BH: .word 0:20

sw $t8, 8($a0)			# Layer 1
	sw $t8, 12($a0)
	sw $t8, 516($a0)	# Layer 2
	sw $t8, 520($a0)
	sw $t8, 524($a0)
	sw $t8, 528($a0)
	sw $t8, 1032($a0)	# Layer 3
	sw $t8, 1036($a0)
	sw $t9, 1540($a0)	# Layer 4
	sw $t9, 1544($a0)
	sw $t9, 1548($a0)
	sw $t9, 1552($a0)
	sw $t7, 2048($a0)	# Layer 5
	sw $t9, 2052($a0)
	sw $t9, 2056($a0)
	sw $t9, 2060($a0)
	sw $t9, 2064($a0)
	sw $t7, 2068($a0)
	sw $t7, 2560($a0)	# Layer 6
	sw $t7, 2580($a0)



.eqv BASE_ADDRESS 0x10008000
.text

.global main
main:
	li $s0, BASE_ADDRESS # $s0 stores the base address for display
	jal lev0
	
	li $s2, 0		# initial x velocity is 0
	li $s3, 0		# initial y velocity is 0 (-1 is upwards)

	li $s4,	0

mainl:	# Main Game loop
	# 
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	beq $t1, 1, inp
main1:	
	beq $s4, 10, gravity
main2:
	jal mship
	
	# Sleep, 5Hz
	li $a0, 200
	li $v0, 32
	syscall
	
	addi $s4, $s4, 1
	j mainl
	
gravity:# Apply gravity
	addi $s3, $s3, 1
	li $s4, 0
	j main2

inp:	# Handle input
	lw $t0, 4($t0)		# t0 = ascii code of input
	beq $t0, 114, inpr
	beq $t0, 113, inpq
	beq $t0, 97, inpa
	beq $t0, 119, inpw
	beq $t0, 100, inpd
	
	j main1			# return to main loop

inpa:	# accelerate left is pushed
	addi $s2, $s2, -1
	j main1

inpw:	# accelerate up is pushed
	addi $s3, $s3, -1
	j main1

inpd:	# accelerate right is pushed
	addi $s2, $s2, 1
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
	
	addi $s1, $s0, 27160	# s1 stores the players position. 27984 is spawn
	jal dship
	
	lw $t0, 0($sp)
	addi $sp, $sp, 4	# Return to main from the stack
	jr $t0


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
	bne $t3, 8, dship1
dship2:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &write_to
	sw $t9, 0($t2)		# write the pixel
	addi $t0, $t0, 4
	addi $t3, $t3, 1
	bne $t3, 16, dship2
dship3:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &write_to
	sw $t7, 0($t2)		# write the pixel
	addi $t0, $t0, 4
	addi $t3, $t3, 1
	bne $t3, 20, dship3
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
	li $t8, 0x828282	# t8 stores dark grey
	li $t9, 0xa4a4a4 	# t9 stores light grey
	
	sw $t8, 0($a0)		# Draw the 6 edge pixels
	sw $t9, 4($a0)
	sw $t8, 516($a0)
	sw $t9, 32($a0)
	sw $t8, 36($a0)
	sw $t8, 544($a0)
	
	addi $t0, $a0, 8
	li $t1 0
dland0:	sw $t9 0($t0)		# Draw 6 more horizontal levels
	sw $t9 512($t0)
	beq $t1, 6, dland1
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	j dland0
dland1:	jr $ra
	
	
land:	# Return 1 in v0 iff spaceship is landed. Checks $s1 for the ships position. Landed iff neither black or white under both feet
	addi $t0, $s1, 3056	# Load the pixel under left leg
	beqz $t0, land1		# Not landed if white star or black space under foot
	beq $t0, 0xffffff, land1
	j landtr
land1:	addi $t0, $s1, 3076	# Load the pixel under right leg
	beqz $t0, landfa	# Not landed if white star or black space under foot
	beq $t0, 0xffffff, landfa
	j landtr

landfa:	li $v0, 0
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
	bne $t3, 20, mship1
		
	# Calculate the new position
	sll $t0, $s2, 2
	add $s1, $s1, $t0
	sll $t0, $s3, 9
	add $s1, $s1, $t0
	
	# Reset if the player is out of screen
	blt $s1, $s0, main
	addi $t0, $s0, 29696
	bgt $s1, $t0, main
	
	# 2. save the pixels in the new position
	li $t3, 0		# counter i
	la $t0, S		# t0 = &S
	la $t4, BH		# t4 = $BH
mship2:	lw $t1, 0($t0)		# t1 = S[i]
	add $t2, $s1, $t1	# t2 = &(S[i] pixel)
	lw $t2, 0($t2)		# t2 = S[i] pixel
	sw $t2, 0($t4)		# BH[i] = t2
	addi $t0, $t0, 4
	addi $t4, $t4, 4
	addi $t3, $t3, 1
	bne $t3,20, mship2
	
	# 3. draw the ship in the new position
	jal dship
	
	addi $sp, $sp, 4
	lw $ra, -4($sp)
	jr $ra
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
