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





.eqv BASE_ADDRESS 0x10008000
.text

.global main
main:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	li $a0, BASE_ADDRESS
	
	jal ss
	
	jal dship
	addi $a0, $a0, 1024
	jal dplm
	addi $a0, $a0, -1024
	
	addi $a0, $a0, 40
	jal dsp
	
	addi $a0, $a0, 64
	jal dmp
	
	addi $a0, $a0, 80
	jal dlp
	
	addi $a0, $zero, BASE_ADDRESS
	addi $a0, $a0, 8192
	jal dtur
	
	addi $a0, $a0, 80
	jal dbul
	
	
	li $v0, 10 # terminate the program gracefully
	syscall



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


	
dship:	# Draw ship. Topleft address is stored in $a0. $a0 is not modified
	li $t7, 0x828282	# t7 stores dark grey
	li $t8, 0xa4a4a4 	# t8 stores light grey
	li $t9, 0xdf9213	# t9 stores gold-bronze
	
	sw $t8, 8($a0)		# Layer 1
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
	
	
	
	
	
	
	
	
	
