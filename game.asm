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

# Store the offsets from the ship position. First 2 are pod, second 4 are service module, last 2 are legs. 8 pixels total
S: .word 4 8 516 520 1028 1032 1536 1548
bSpawn: .word 0
# Store the screen behind the ship
BH: .word 0:8
# Store the screen behind the plume
BHP: .word 0:8
PLMPOS: .word 0		# psoition of the plume
EPLM: .word 0		# should erase the plume?

DESTROYED: .word 0	# keeps track of if the enemy is destoryed



.eqv BASE_ADDRESS 0x10008000
.text

main:
	li $s0, BASE_ADDRESS # $s0 stores the base address for display
	
	addi $s1, $s0, 28188	# initial spawn location
				# s1 is set later, ship position (including base address)
	li $s2, 0		# s2 is the sub pixel y position, mod4
	li $s3, 0		# s3 is the x velocity
	li $s4, 0		# s4 is the current level
	li $s5, 0		# s5 stores subpixel y velocity
	li $s6, 0x80		# initial fuel = 8*16 / 16*16 - 1
	jal cBH			# clear behind the ship
	
	jal lev0

mainlo:	# Main Game loop
	# Read if input was sent
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	beq $t1, 1, inp		# Apply input
main1:	# Apply gravity to velocity if not landed
	addi $s5, $s5, 1	# Add gravity to vertical velocity
	jal land
	beqz $v0, main2		# if not landed: skip
	blez $s5, main2		# if ascending: skip
	li $s3, 0
	li $s5, 0
	bgtz $s6, main2		# if fuel remains: skip
	li $a0, 2
	j dsc			# yer done - no fuel
	
main2:	
	
	# Sleep, 25ms, 40Hz
	li $a0, 25
	li $v0, 32
	syscall
	
	# Erase plume if instructed
	la $t0 EPLM
	lw $t1 0($t0)
	beqz $t1 main3
	li $t1 0		# Reset instruction
	sw $t1, 0($t0)
	
	
	# Redraw the bakcground
	lw $t1, PLMPOS
	lw $t0 BHP		# Layer 1
	sw $t0 1540($t1)
	lw $t0 BHP+4
	sw $t0 1544($t1)
	addi $t2, $s0, 31220
	bgt $t1, $t2, main3
	
	lw $t0 BHP+8		# Layer 2
	sw $t0 2052($t1)	
	lw $t0 BHP+12
	sw $t0 2056($t1)
	addi $t2, $t2, -512
	bgt $t1, $t2, main3
	
	lw $t0 BHP+16		# Layer 3
	sw $t0 2564($t1)	
	lw $t0 BHP+20
	sw $t0 2568($t1)
	addi $t2, $t2, -512
	bgt $t1, $t2, main3
	
	lw $t0 BHP+24		# Layer 4
	sw $t0 3076($t1)	
	lw $t0 BHP+28
	sw $t0 3080($t1)
	
	# Check if turret is destroyed
	li $t9, 0xa4a4a4 	# t9 stores light grey for detecting turret
	li $t0 0
	
maindl:	lw $t1 BHP($t0)
	beq $t1 $t9 turd
	addi $t0 $t0 4
	bne $t0 32 maindl
	

	j main3
turd: 	# "Turret detected"
	li $t0 1
	sw $t0 DESTROYED
	addi $a0 $s0 21400
	beq $s4 0 ktur
	addi $a0 $s0 14276
	beq $s4 1 ktur
	addi $a0 $s0 19204
	beq $s4 2 ktur
	j main3			# this line should never be reached
	


main3:	# Draw changes
	jal dbul
	jal mship
	
	j mainlo

winp:	# Wait for input restart or quit
	li $a0 1
	li $v0 1
	syscall
	li $a0, 100
	li $v0, 32
	syscall
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	beqz $t1, winp		# Apply input	
	li $a0 2
	li $v0 1
	syscall
	lw $t0, 4($t0)		# t0 = Ascii 
	beq $t0, 114, winpr
	beq $t0, 113, winpq
	j winp

winpr:# reset if r if pressed
	j main
	
winpq:# Exit if q if pressed
	li $v0, 10 # terminate the program gracefully
	syscall


inp:	# Handle input
	lw $t0, 4($t0)		# t0 = ascii code of input
	beq $t0, 114, inpr
	beq $t0, 113, inpq
	blez $s6, main1		# no options if no fuel
	beq $t0, 97, inpa
	beq $t0, 119, inpw
	beq $t0, 100, inpd
	
	j main1			# return to main loop

inpa:	# accelerate left is pushed
	addi $s3, $s3, -4
	addi $s6, $s6, -4
	jal ubar
	j mainlo

inpw:	# increase thrust is pushed
	addi $s5, $s5, -32
	addi $s6, $s6, -8
	jal ubar
	blez $s6 mainlo	# skip plume if no fuel
	
	jal dplm	# notify mainloop to clear plume
	li $t0 1	
	sw $t0, EPLM
	sw $s1, PLMPOS
	
	j mainlo

inpd:	# accelerate right is pushed
	addi $s3, $s3, 4
	addi $s6, $s6, -4
	jal ubar
	j mainlo

inpr:# reset if r if pressed
	j main
	
inpq:# Exit if q if pressed
	li $v0, 10 # terminate the program gracefully
	syscall

lev0:	# Prepare level 0
	sw $zero DESTROYED
	la $a0, ($s0)
	jal ss			# Clear the screen
	
	addi $a0, $s0, 27900	# Draw the large platform
	jal dlp
	addi $a0, $s0, 27088	# Draw a landing pad on the large platform
	li $a1, 0xdf9213	# Success color
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
	addi $s7, $s0, 21908	# Set the bullets positon and spawn
	sw $s7, bSpawn
	j mainlo

lev1:	# Prepare level 1
	sw $zero DESTROYED
	
	la $a0, ($s0)
	jal ss			# Clear the screen
	addi $a0, $s0, 27900	# Draw the large platform
	jal dlp
	addi $a0, $s0, 27088	# Draw a landing pad on the large platform
	li $a1, 0x7e848f	# Start color
	jal dland
	
	addi $a0, $s0, 15400	# Draw small platform
	jal dsp
	addi $a0, $s0, 25620	# Draw small platform
	jal dsp
	addi $a0, $s0, 14276	# Draw turret
	jal dtur
	addi $s7, $s0, 14784	# Set the bullets positon and spawn
	sw $s7, bSpawn
	addi $a0, $s0, 15800	# Draw medium platform
	jal dmp
	addi $a0, $s0, 23072 	# Draw fuel
	jal dfuel
	addi $a0, $s0, 15400	# Draw a landing pad on the small platform
	li $a1, 0xdf9213	# Succes color
	jal dland
	j mainlo

lev2:	# Prepare level 2
	sw $zero DESTROYED
	
	la $a0, ($s0)
	jal ss			# Clear the screen
	addi $a0, $s0, 4860	# Draw the large platform
	jal dlp
	addi $a0, $s0, 15400	# Draw small platform
	jal dsp
	li $a1, 0x7e848f	# Start color
	addi $a0, $s0, 15400	# Draw a landing pad
	jal dland
	
	li $a1, 0xdf9213	# Succes color
	addi $a0, $s0, 11164	# Draw a landing pad
	jal dland
	
	addi $a0, $s0, 5600	# Draw small platform
	#jal dsp
	addi $a0, $s0, 20720	# Draw medium platform
	jal dmp
	addi $a0, $s0, 19204	# Draw turret
	jal dtur
	addi $s7, $s0, 19712	# Set the bullets positon and spawn
	sw $s7, bSpawn
	addi $a0, $s0, 2300 	# Draw fuel
	jal dfuel
	#jal dland
	j mainlo


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
	beq $t0, 32768, dbar	# draw bar ui
	j ssl

ubar:	# update the fuel bar
	li $t7, 0x002e00	# partial square color
	li $t8, 0x0		# t8 = black
	li $t9, 0xff8800	# t9 = orange
	add $t0, $s0, 20476	# bottom of gauge
	li $t2, 0		# counter
	blt $s6, 0x10, ubarl1
	la $t1, ($s6)		# t1 = fuel
ubarlo:	sw $t9, 0($t0)		# Draw the orange
	addi $t0, $t0, -512
	addi $t1, $t1, -0x10
	addi $t2, $t2, 1
	bge $t1, 0x10, ubarlo
ubarl1:	blez $t1, ubarla	# Draw partial square
	addi $t1, $t1, -0x01
	addi $t7, $t7, 0x110600
	j ubarl1
	
ubarla: bge $t2, 16, ubare
	beq $t7, 0x113400, ubarl2
	sw $t7, 0($t0)		# Draw partial
	addi $t0, $t0, -512
	addi $t2, $t2, 1 
ubarl2:	bge $t2, 16, ubare
	sw $t8, 0($t0)
	addi $t0, $t0, -512
	addi $t2, $t2, 1
	blt $t2, 16, ubarl2
ubare:	jr $ra
	
dbar:	li $t7, 0x0		# t7 = black
	li $t8, 0x828282	# t8 = dark grey
	li $t9, 0xff8800	# t9 = orange
	addi $t0, $s0, 12280	# t0 = base address
	sw $t8, 0($t0)
	sw $t8, 4($t0)
	addi $t0, $t0, 512
	li $t1, 0		# t1 = counter
dbar1:	sw $t8, 0($t0)
	sw $t7, 4($t0)
	addi $t0, $t0, 512
	addi $t1, $t1, 1
	bne $t1, 16, dbar1
	sw $t8, 0($t0)
	sw $t8, 4($t0)
	sw $t9, -2048($t0)
	sw $t9, -4096($t0)
	sw $t9, -6144($t0)
	
	j ubar		# update the bar then enter the gameloop
	


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


dplm:	# Draw the ships thrust plume. Topleft is address of ships drawn address.
	li $t7 0xff0000		# t7 stores red
	li $t8 0xff8800		# t8 stores orange
	li $t9 0xffe100		# t9 stores yellow
	
	la $t6, BHP
	sw $s1 PLMPOS
	
	# Save whats possible
	# Draw whats possible
	# Overwrite later
	
	lw $t0, 1540($s1)	# Layer 1
	sw $t0, 0($t6)
	lw $t0, 1544($s1)
	sw $t0, 4($t6)
	
	addi $t1, $s0, 31220	# Layer 2
	bgt $s1, $t1, dplm1
	lw $t0 2052($s1)	
	sw $t0, 8($t6)
	lw $t0 2056($s1)
	sw $t0, 12($t6)

	addi $t1, $t1, -512	# Layer 3
	bgt $s1, $t1, dplm1
	lw $t0 2564($s1)	
	sw $t0, 16($t6)
	lw $t0 2568($s1)
	sw $t0, 20($t6)

	addi $t1, $t1, -512	# Layer 4
	bgt $s1, $t1, dplm1
	lw $t0 3076($s1)	
	sw $t0, 24($t6)
	lw $t0 3080($s1)
	sw $t0, 28($t6)
	
	
dplm1:
	sw $t7 1540($s1)	# Layer 1
	sw $t7 1544($s1)
	addi $t0, $s0, 31220
	bgt $s1, $t0, dplm5
	sw $t8 2052($s1)	# Layer 2
	sw $t8 2056($s1)
	addi $t0, $t0, -512
	bgt $s1, $t0, dplm5
	sw $t9 2564($s1)	# Layer 3
	sw $t9 2568($s1)
	addi $t0, $t0, -512
	bgt $s1, $t0, dplm5
	sw $t9 3076($s1)	# Layer 4
	sw $t9 3080($s1)
dplm5:	
	
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

ktur: # Draw a killed turret
	li $t7, 0x0		# t7 stores black
	li $t8, 0x828282	# t8 stores dark grey
	li $t9, 0xa4a4a4 	# t9 stores light grey
	
	sw $t8,	20($a0)		# Layer 1
	sw $t8,	24($a0)
	sw $t7,	28($a0)
	sw $t7,	512($a0)	# Layer 2
	sw $t7,	516($a0)
	sw $t7,	520($a0)
	sw $t7,	524($a0)
	sw $t8,	528($a0)
	sw $t8,	532($a0)
	sw $t9,	536($a0)
	sw $t8,	540($a0)
	sw $t8,	544($a0)
	sw $t8,	1032($a0)	# Layer 3
	sw $t8,	1036($a0)
	sw $t7,	1040($a0)
	sw $t8,	1044($a0)
	sw $t8,	1048($a0)
	sw $t9,	1052($a0)
	sw $t9,	1056($a0)
	sw $t8,	1060($a0)
	
	j main3


dbul:	# Draw a bullet. Topleft address is stored in $s7. $s7 is modified left. 
	
	li $t8 0xff0000		# t8 stores red
	li $t9 0x0		# t9 = black
	
	lw $t0, 0($s7)
	lw $t1, 4($s7)
	
	#bnez $t0, dbul1
	sw $t8, 0($s7)
dbul1:	bne $t1, $t8, dbul2
	sw $t9, 4($s7)
	
dbul2:	beqz $t0, dbul3
	
	li $a0, 1
	beq $t0, 0x828282, dsc	# dark grey
	beq $t0, 0xa4a4a4, dsc	# light grey
	beq $t0, 0xdf9213, dsc	# gold-bronze
	
dbul3:	sub $t0, $s7, $s0	# t0 = screen pos
	andi $t0, $t0, 511	# t0 = screen x pos
	bne $t0, 508, dbul4
	
	sw $t9 0($s7)
	
	lw $t5 DESTROYED
	beq $t5 1 dbul5
	lw $s7 bSpawn
	sw $t8 0($s7)
	
dbul4:	addi $s7, $s7, -4	
dbul5:	jr $ra

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
	la $t9, ($a1)	 	# t9 stores light grey
	
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


	
land:	# Return 1 in v0 iff spaceship is landed. Checks $s1 for the ships position. Landed iff neither black or white under both feet
	lw $t0, 2048($s1)	# Load the pixel under left leg
	lw $t1, 2060($s1)	# Load the pixel under right leg
	beq $t0, 0xdf9213, landw # Win land true if on bronze
	beq $t1, 0xdf9213, landw
	beq $t0, 0xa4b0c8, landtr# Can land on platform or bronze
	beq $t0, 0x7e848f, landtr
	beq $t1, 0xa4b0c8, landtr
	beq $t1, 0x7e848f, landtr
	li $v0, 0
	jr $ra
landtr: li $v0, 1
	jr $ra

landw:# Handle landing on the win platform
	bne $s4, 2, dsc4	# if level 2 dont bother with the menus
	li $a0, 0
	j dsc


dsc:	# Draw the final screen with fuel score in the background. a0=0-passed 1-kia 2-mia
	addi $t0, $s0, 11964	# t0 = base address
	li $t7, 0xffffff	# t7 = white
	
	
	la $a1, ($t0)
	la $a2, ($t7)
	jal dscrow
	
	
	addi $t0, $t0, 512
		
	li $t1, 0		# counter
dsc1:	la $a1, ($t0)		# pass address
	li $a2, 0x0		# default black
	bnez $a0, dsc2		# fancy if passed
	lw $a2, 320($t0)	# copy the color from the far right bar at the same height lol
dsc2:	jal dscrow
	addi $t0, $t0, 512
	addi $t1, $t1, 1
	bne $t1, 16, dsc1
	
	la $a1, ($t0)
	la $a2, ($t7)
	jal dscrow
	
	
	beq $a0, 0, dscmp
	beq $a0, 1, dsck
	beq $a0, 2, dscm
	
	
dsc3:	beqz $a0, dsc4	
	j winp			# return back to reset if anything but a win
dsc4:	addi $s4, $s4, 1	# draw next level if passed
	beq $s4, 1 lev1
	beq $s4, 2 lev2
	j winp
	
	


dscrow:	# Draws a row at a1 on the win screen, filling with color a2
	sw $t7, 0($a1)
	li $t6, 0
	li $t6, 1		# counter
dscrow1:addi $a1, $a1, 4
	addi $t6, $t6, 1
	sw $a2, 0($a1)
	bne $t6, 33, dscrow1
	sw $t7, 4($a1)
	
	jr $ra

dscm:	# Draw MIA 
	addi $t1, $s0, 11964
	li $t0, 0xffffff	# Text color
	sw $t0, 3624($t1)	# Layer 1
	sw $t0, 3640($t1)
	sw $t0, 3648($t1)
	sw $t0, 3652($t1)
	sw $t0, 3656($t1)
	sw $t0, 3664($t1)
	sw $t0, 3668($t1)
	sw $t0, 3672($t1)
	
	sw $t0, 4136($t1)	# Layer 2
	sw $t0, 4140($t1)
	sw $t0, 4148($t1)
	sw $t0, 4152($t1)
	sw $t0, 4164($t1)
	sw $t0, 4176($t1)
	sw $t0, 4184($t1)
	
	sw $t0, 4648($t1)	# Layer 3
	sw $t0, 4656($t1)
	sw $t0, 4664($t1)
	sw $t0, 4676($t1)
	sw $t0, 4688($t1)
	sw $t0, 4692($t1)
	sw $t0, 4696($t1)
	
	sw $t0, 5160($t1)	# Layer 4
	sw $t0, 5176($t1)
	sw $t0, 5188($t1)
	sw $t0, 5200($t1)
	sw $t0, 5208($t1)
	
	sw $t0, 5672($t1)	# Layer 5
	sw $t0, 5688($t1)
	sw $t0, 5696($t1)
	sw $t0, 5700($t1)
	sw $t0, 5704($t1)
	sw $t0, 5712($t1)
	sw $t0, 5720($t1)
	
	j dsc3


dsck:	# Draw KIA 
	addi $t1, $s0, 11964
	li $t0, 0xffffff	# Text color
	sw $t0, 3628($t1)	# Layer 1
	sw $t0, 3640($t1)
	sw $t0, 3648($t1)
	sw $t0, 3652($t1)
	sw $t0, 3656($t1)
	sw $t0, 3664($t1)
	sw $t0, 3668($t1)
	sw $t0, 3672($t1)
	
	sw $t0, 4140($t1)	# Layer 2
	sw $t0, 4148($t1)
	sw $t0, 4164($t1)
	sw $t0, 4176($t1)
	sw $t0, 4184($t1)
	
	sw $t0, 4652($t1)	# Layer 3
	sw $t0, 4656($t1)
	sw $t0, 4676($t1)
	sw $t0, 4688($t1)
	sw $t0, 4692($t1)
	sw $t0, 4696($t1)
	
	sw $t0, 5164($t1)	# Layer 4
	sw $t0, 5172($t1)
	sw $t0, 5188($t1)
	sw $t0, 5200($t1)
	sw $t0, 5208($t1)
	
	sw $t0, 5676($t1)	# Layer 5
	sw $t0, 5688($t1)
	sw $t0, 5696($t1)
	sw $t0, 5700($t1)
	sw $t0, 5704($t1)
	sw $t0, 5712($t1)
	sw $t0, 5720($t1)
	
	j dsc3
	
	
dscmp:	# Draws mission passed onto the screen
	addi $t1, $s0, 11964
	li $t0, 0xffffff	# Text color
	sw $t0, 1544($t1)	# Layer 1
	sw $t0, 1560($t1)
	sw $t0, 1568($t1)
	sw $t0, 1572($t1)
	sw $t0, 1576($t1)
	sw $t0, 1584($t1)
	sw $t0, 1588($t1)
	sw $t0, 1592($t1)
	sw $t0, 1600($t1)
	sw $t0, 1604($t1)
	sw $t0, 1608($t1)
	sw $t0, 1616($t1)
	sw $t0, 1620($t1)
	sw $t0, 1624($t1)
	sw $t0, 1632($t1)
	sw $t0, 1636($t1)
	sw $t0, 1640($t1)
	sw $t0, 1648($t1)
	sw $t0, 1660($t1)
	
	sw $t0, 2056($t1)	# Layer 2
	sw $t0, 2060($t1)
	sw $t0, 2068($t1)
	sw $t0, 2072($t1)
	sw $t0, 2084($t1)
	sw $t0, 2096($t1)
	sw $t0, 2112($t1)
	sw $t0, 2132($t1)
	sw $t0, 2144($t1)
	sw $t0, 2152($t1)
	sw $t0, 2160($t1)
	sw $t0, 2164($t1)
	sw $t0, 2172($t1)
	
	sw $t0, 2568($t1)	# Layer 3
	sw $t0, 2576($t1)
	sw $t0, 2584($t1)
	sw $t0, 2596($t1)
	sw $t0, 2608($t1)
	sw $t0, 2612($t1)
	sw $t0, 2616($t1)
	sw $t0, 2624($t1)
	sw $t0, 2628($t1)
	sw $t0, 2632($t1)
	sw $t0, 2644($t1)
	sw $t0, 2656($t1)
	sw $t0, 2664($t1)
	sw $t0, 2672($t1)
	sw $t0, 2676($t1)
	sw $t0, 2680($t1)
	sw $t0, 2684($t1)
	
	sw $t0, 3080($t1)	# Layer 4
	sw $t0, 3096($t1)
	sw $t0, 3108($t1)
	sw $t0, 3128($t1)
	sw $t0, 3144($t1)
	sw $t0, 3156($t1)
	sw $t0, 3168($t1)
	sw $t0, 3176($t1)
	sw $t0, 3184($t1)
	sw $t0, 3192($t1)
	sw $t0, 3196($t1)

	sw $t0, 3592($t1)	# Layer 5
	sw $t0, 3608($t1)
	sw $t0, 3616($t1)
	sw $t0, 3620($t1)
	sw $t0, 3624($t1)
	sw $t0, 3632($t1)
	sw $t0, 3636($t1)
	sw $t0, 3640($t1)
	sw $t0, 3648($t1)
	sw $t0, 3652($t1)
	sw $t0, 3656($t1)
	sw $t0, 3664($t1)
	sw $t0, 3668($t1)
	sw $t0, 3672($t1)
	sw $t0, 3680($t1)
	sw $t0, 3684($t1)
	sw $t0, 3688($t1)
	sw $t0, 3696($t1)
	sw $t0, 3708($t1)

	sw $t0, 5144($t1)	# Layer 6
	sw $t0, 5148($t1)
	sw $t0, 5152($t1)
	sw $t0, 5160($t1)
	sw $t0, 5164($t1)
	sw $t0, 5168($t1)
	sw $t0, 5176($t1)
	sw $t0, 5180($t1)
	sw $t0, 5184($t1)
	sw $t0, 5192($t1)
	sw $t0, 5196($t1)
	sw $t0, 5200($t1)
	sw $t0, 5208($t1)
	sw $t0, 5212($t1)
	sw $t0, 5216($t1)
	sw $t0, 5224($t1)
	sw $t0, 5228($t1)
	
	sw $t0, 5656($t1)	# Layer 7
	sw $t0, 5664($t1)
	sw $t0, 5672($t1)
	sw $t0, 5680($t1)
	sw $t0, 5688($t1)
	sw $t0, 5704($t1)
	sw $t0, 5720($t1)
	sw $t0, 5736($t1)
	sw $t0, 5744($t1)
	
	sw $t0, 6168($t1)	# Layer 8
	sw $t0, 6172($t1)
	sw $t0, 6176($t1)
	sw $t0, 6184($t1)
	sw $t0, 6188($t1)
	sw $t0, 6192($t1)
	sw $t0, 6200($t1)
	sw $t0, 6204($t1)
	sw $t0, 6208($t1)
	sw $t0, 6216($t1)
	sw $t0, 6220($t1)
	sw $t0, 6224($t1)
	sw $t0, 6232($t1)
	sw $t0, 6236($t1)
	sw $t0, 6248($t1)
	sw $t0, 6256($t1)
	
	sw $t0, 6680($t1)	# Layer 9
	sw $t0, 6696($t1)
	sw $t0, 6704($t1)
	sw $t0, 6720($t1)
	sw $t0, 6736($t1)
	sw $t0, 6744($t1)
	sw $t0, 6760($t1)
	sw $t0, 6768($t1)

	sw $t0, 7192($t1)	# Layer 10
	sw $t0, 7208($t1)
	sw $t0, 7216($t1)
	sw $t0, 7224($t1)
	sw $t0, 7228($t1)
	sw $t0, 7232($t1)
	sw $t0, 7240($t1)
	sw $t0, 7244($t1)
	sw $t0, 7248($t1)
	sw $t0, 7256($t1)
	sw $t0, 7260($t1)
	sw $t0, 7264($t1)
	sw $t0, 7272($t1)
	sw $t0, 7276($t1)
	
	j dsc3
	
	
	

	
	
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
	li $a0, 2		# premeptive if out of screen
	sub $t6, $s1, $s0
	andi $t6, $t6, 511
	bge $t6, 500, dsc
	
	# Difference should equal x velocity, otherwise hit an edge
	sub $t0, $t6, $t5
	bne $t0, $s3, dsc	# MIA
	
	
	# Reset if the player is out of screen
	blt $s1, $s0, dsc
	addi $t0, $s0, 31220
	bgt $s1, $t0, dsc
	
	
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
	beq $t2, 0xfd2f2e, mshipf # if fuel tank, collect fuel
	j mship3
mshipc:	addi $s1, $s1, -512	# if collision on feet is detected, raise ship by 1 and resave to draw
	bgt $t3, 5, mships	# skip move up if on the feet
	addi $sp, $sp, 4
	li $a0, 1
	j dsc			# game-ending collision otherwise
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
	
mshipf: addi $s6, $s6, 0x80	# collect fuel
	ble $s6, 0xFF, mshipl
	li $s6, 0xFF		# cap fuel
mshipl:	addi $t0, $s0, 13964	# fuel location in l1
	beq $s4, 0, mshipf0	# level 0 fuel pos
	addi $t0, $s0, 23072
	beq $s4, 1, mshipf0	# level 1 fuel pos
	addi $t0, $s0, 2300
	beq $s4, 2, mshipf0	# level 2 fuel pos
mshipf0:li $t3, 0		# counter
	li $t4, 0x0
mshipf1:sw $t4, 0($t0)
	sw $t4, 4($t0)
	sw $t4, 8($t0)
	sw $t4, 12($t0)
	addi $t3, $t3, 1
	addi $t0, $t0, 512
	bne $t3, 5, mshipf1
	jal ubar
	j mships

	
	
dbgd:	# Debug print an int
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	jr $ra
	


	
	
	
	
	
	
	
