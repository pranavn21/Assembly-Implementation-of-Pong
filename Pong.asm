# Pranav Nair
# April 25, 2021
# Parts of code are from Professor Mazidi's examples 
#
# Instructions on how to run: 
#	
#	  1) Click Tools -> Bitmap display
#         2) set pixel dim to 4x4
#         3) set display dim to 256x256
#	  4) Set base address for display to 0x10008000 ($gp)
# 	  5) Connect to MIPS
#
#	  6) Click Tools -> Keyboard and Display MMIO Simulator
#	  7) Connect to MIPS
#	  8) Run the program

# set up some constants
# width of screen in pixels
# 256 / 4 = 64
.eqv WIDTH 64
# height of screen in pixels
.eqv HEIGHT 64
# memory address of pixel (0, 0)
.eqv MEM 0x10010000 

# colors
.eqv	RED 	0x00FF0000
.eqv	GREEN 	0x0000FF00
.eqv	BLUE	0x000000FF
.eqv	WHITE 	0x00FFFFFF
.eqv	YELLOW 	0x00FFFF00
.eqv	CYAN	0x0000FFFF
.eqv	MAGENTA	0x00FF00FF
.eqv	BROWN	0X00663300

.data
colors:	.word	RED, GREEN, BLUE, WHITE, YELLOW, CYAN, MAGENTA, BROWN
PDLCLR:	.word	0x000000FF	# Paddle inside color
PDLCLR2:	.word	0x00FF0000	# Paddle outside color
BALLCLR:	.word 	0x00FF0000	#Ball color
msg_start:		.asciiz "\nWelcome! Press WASD to start! Space to quit game (doesn't show score so don't quit!)! \nUpdated score on MARS console. \n\nNote: There may dialog boxes at the end of the game."
msg_end:		.asciiz "\nGame Over! Your score was:\t"
msg_restart:		.asciiz "\nWould you like to restart?"
msg_scoreupd:		.asciiz "\nNew score: "

.macro	play_beep (%p, %t, %i, %v) # This does not wait till completition of the sound
li 	$v0, 31				# Set to 31 to play sound
addi	$t0, $a0, 0
addi	$t1, $a1, 0
addi	$t2, $a2, 0
addi	$t3, $a3, 0
add 	$a0, $0, %p				# a0 = pitch
add 	$a1, $0, %t				# a1 = duration
add 	$a2, $0, %i				# a2 = instrument
add 	$a3, $0, %v				# a3 = volume
syscall
addi	$a0, $t0, 0
addi	$a1, $t1, 0
addi	$a2, $t2, 0
addi	$a3, $t3, 0
.end_macro

.macro	play_sound (%p, %t, %i, %v)	# This does wait till completition of the sound
li 	$v0, 33			# Set to 33 to play sound
addi	$t0, $a0, 0
addi	$t1, $a1, 0
addi	$t2, $a2, 0
addi	$t3, $a3, 0
add 	$a0, $0, %p				# a0 = pitch
add 	$a1, $0, %t				# a1 = duration
add 	$a2, $0, %i				# a2 = instrument
add 	$a3, $0, %v				# a3 = volume
syscall
addi	$a0, $t0, 0
addi	$a1, $t1, 0
addi	$a2, $t2, 0
addi	$a3, $t3, 0
.end_macro

.text
main:
	jal blackoutScreen		# Blackout the screen
	jal startingScreen		# Show the starting screen
	
	la	$a0, msg_start		#Display message for the message start
	li	$v0, 4			# For printing a string
	syscall
	
		
startSong: 				# Play the intro theme (intel)
	play_beep(49, 1000, 48, 64)
	play_beep(61, 1000, 48, 64)
	play_sound(73, 1000, 48, 64)
	
	play_sound(49, 100, 48, 64)
	play_sound(54, 100, 48, 64)
	play_sound(49, 100, 48, 64)
	play_sound(56, 100, 48, 64)
	
startingLoop:					
	# check for input
	lw $t0, 0xffff0000 			#t1 holds if input available
    	beq $t0, 0, startingLoop   			#If no input, keep displaying
	
	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit			# input space
	beq	$s1, 119, mainCont 			# input w
	beq	$s1, 115, mainCont 			# input s
	beq	$s1, 97, mainCont  			# input a
	beq	$s1, 100, mainCont			# input d
	# invalid input, ignore
	j	startingLoop
	
	
mainCont:				# Generate random initial velocity vector for ball; a1 = range; syscall 42; a0 returns int
	jal	blackoutScreen		# Blackout the screen to remove the starting screen
	addi	$a1, $0, 5
	addi	$v0, $0, 42
	syscall
	addi	$s6, $a0, -2	# [-3,3]
	
	
	bne	$s6, 0, main2	# If dX = 0, change it to nonzero by adding 1 or -1, depending on random value
	
	addi	$a1, $0, 2	# [0,1]
	addi	$v0, $0, 42
	syscall
	
	beq	$v0, 1, addOne		# This fixes if the vectors are nonzero, as that would cause an issue.
	addi	$s6, $s6, -2
addOne:
	addi	$s6, $s6, 1
	
main2:	addi	$a1, $0, 2
	addi	$v0, $0, 42
	syscall
	mul 	$s7, $a0, -1
	
	
	bne	$s7, 0, main3	# If dX = 0, change it to nonzero by adding 1 or -1, depending on random value
	
	addi	$a1, $0, 2	# [0,1]
	addi	$v0, $0, 42
	syscall
	
	beq	$v0, 1, addOnedY
	addi	$s7, $s7, -2
addOnedY:
	addi	$s7, $s7, 1
	
main3:	
	
	# Setup the width, height, and save red in the color register temporarily
	addi 	$a0, $0, WIDTH    		# a0 = X = WIDTH/2
	sra 	$a0, $a0, 1
	addi 	$a1, $0, HEIGHT   		# a1 = Y = HEIGHT
	addi 	$a1, $a1, -3 
	addi 	$a2, $0, RED  			# a2 = red (ox00RRGGBB)
	
	addi 	$s3, $0, WIDTH    		# $s3 = X = WIDTH/2
	sra 	$s3, $s3, 1
	addi 	$s4, $0, HEIGHT   		# $s4 = Y = HEIGHT/2
	sra 	$s4, $s4, 1
	addi 	$s4, $s4, -3 

	
	addi	$a3, $0, 0 			# i = 1
	addi	$a0, $a0, 1			# x++
	addi	$s0, $0, 0			# Counter for overall program (to update ball slowly)
	addi	$s2, $0, 0			# Scoreboard

#################################################
# This loop checks for input, and if there is, then it proceeds to update the box with the respective direction. If not, it loops back to itself.

loop:	# Draw a paddle
	addi	$s0, $s0, 1		# Counter++
	j	topR_loop
	
	# update position of ball; $s3 = x,  $s4 = y, s6 = dX, s7 = dY
	
updBall:
	addi	$t0, $0, 100
	div	$t1, $s0, $t0
	mfhi	$t2
	bne	$t2, 0, loop2 # If counter%50 != 50 then skip updating b
	
	addi	$a2, $0, 0
	jal     draw_pixelBALL
	jal	pause
	la	$t0, colors
	lw	$t1, 0($t0)
	jal	colorChooser
	addi	$a2, $t1, 0
	
	add	$s3, $s3, $s6
	add	$s4, $s4, $s7
	
	jal 	draw_pixelBALL
	
	beq	$s4, 60, checkPaddleHit
		
	beq	$s3, 0, horizontalBorderHit
	beq	$s3, -1, horizontalBorderHit
	beq	$s3, 63, horizontalBorderHit
	beq	$s3, 64, horizontalBorderHit
	beq	$s4, 0, verticalBorderHit
	beq	$s4, 63, GameOver		# If it hits the bottom, game over
	
	
	
loop2:
	# check for input
	lw $t0, 0xffff0000 			#t1 holds if input available
    	beq $t0, 0, loop   			#If no input, keep displaying
	
	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit			# input space
	beq	$s1, 97, left  			# input a
	beq	$s1, 100, right			# input d
	# invalid input, ignore
	j	loop
	
	# process valid input
	
left:	
	ble	$a0,0, loop			# Ignore if on border	
	li	$a2, 0				# Set color temporarily to black
	jal	topR_loopBlack			# Make a black box (which removes the box)
	addi	$a0, $a0, -1	
	j	topR_loop
	
right:	
	addi	$t4, $a0, 11			# get coordinate of top rightmost corner of paddle		
	bge	$t4, 64, loop			# Ignore if on border	
	li	$a2, 0				# Set color temporarily to black
	jal	topR_loopBlack			# Make a black box (which removes the box)
	addi	$a0, $a0, 1	
	j	topR_loop
	
exit:	li	$v0, 10
	syscall

#################################################
# subroutine to draw a pixel
# $a0 = X
# $a1 = Y
# $a2 = color
draw_pixel:
	# s1 = address = $gp + 4*(x + y*width)
	mul	$t9, $a1, WIDTH  		# y * WIDTH
	add	$t9, $t9, $a0	 		# add X
	mul	$t9, $t9, 4	  		# multiply by 4 to get word offset
	add	$t9, $t9, $gp	 		# add to base address
	sw	$a2, ($t9)	  		# store color at memory location
	jr 	$ra

draw_pixelBALL:
	# s1 = address = $gp + 4*(x + y*width); 
	mul	$t9, $s4, WIDTH  		# y * WIDTH
	add	$t9, $t9, $s3	 		# add X
	mul	$t9, $t9, 4	  		# multiply by 4 to get word offset
	add	$t9, $t9, $gp	 		# add to base address
	sw	$a2, ($t9)	  		# store color at memory location
	jr 	$ra
	
#################################################
# This creates the starting screen

startingScreen:	
	addi	$t6, $0, 0
	addi	$a0, $0, 10
	addi	$a1, $0, 40
startingScreenLoopP:
	bge	$t6, 2, startingScreenLoopP1end
	add 	$a2, $0, 0x0000FFFF 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, -1
	bgt	$a1, 20, startingScreenLoopP
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 11	# For increased thickness
	addi	$a1, $0, 40
	ble	$t6, 1, startingScreenLoopP
	
startingScreenLoopP1end:
	addi	$t6, $0, 0
	addi	$a0, $0, 12	
	addi	$a1, $0, 21	
startingScreenLoopP2:
	bge	$t6, 2, startingScreenLoopP2end
	add 	$a2, $0, 0x0000FFFF 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	
	jal 	draw_pixel
	
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, 1
	blt	$a0, 20, startingScreenLoopP2
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 12	# For increased thickness
	addi	$a1, $0, 22
	ble	$t6, 1, startingScreenLoopP2
	
startingScreenLoopP2end:
	addi	$t6, $0, 0
	addi	$a0, $0, 20	
	addi	$a1, $0, 22
startingScreenLoopP3:
	bge	$t6, 2, startingScreenLoopP3end
	add 	$a2, $0, 0x0000FFFF 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	
	jal 	draw_pixel
	
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, 1
	blt	$a1, 30, startingScreenLoopP3
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 19	# For increased thickness
	addi	$a1, $0, 22
	ble	$t6, 1, startingScreenLoopP3
startingScreenLoopP3end:
	addi	$t6, $0, 0
	addi	$a0, $0, 19	
	addi	$a1, $0, 31
startingScreenLoopP4:
	bge	$t6, 2, startingScreenLoopP4end
	add 	$a2, $0, 0x0000FFFF 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	
	jal 	draw_pixel
	
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, -1
	bgt	$a0, 11, startingScreenLoopP4
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 19	# For increased thickness
	addi	$a1, $0, 30
	ble	$t6, 1, startingScreenLoopP4
startingScreenLoopP4end:
	addi	$t6, $0, 0
	addi	$a0, $0, 23	
	addi	$a1, $0, 40
	
startingScreenLoopO1:
	bge	$t6, 2, startingScreenLoopO1end
	add 	$a2, $0, 0x00FF0000 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, -1
	bgt	$a1, 30, startingScreenLoopO1
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 24	# For increased thickness
	addi	$a1, $0, 40
	ble	$t6, 1, startingScreenLoopO1
	
startingScreenLoopO1end:
	addi	$t6, $0, 0
	addi	$a0, $0, 24	
	addi	$a1, $0, 30
	
startingScreenLoopO2:
	bge	$t6, 2, startingScreenLoopO2end
	add 	$a2, $0, 0x00FF0000 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, 1
	blt	$a0, 33, startingScreenLoopO2
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 24	# For increased thickness
	addi	$a1, $0, 31
	ble	$t6, 1, startingScreenLoopO2
	
startingScreenLoopO2end:
	addi	$t6, $0, 0
	addi	$a0, $0, 34	
	addi	$a1, $0, 31

startingScreenLoopO3:
	bge	$t6, 2, startingScreenLoopO3end
	add 	$a2, $0, 0x00FF0000 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, 1
	blt	$a1, 41, startingScreenLoopO3
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 33	# For increased thickness
	addi	$a1, $0, 30
	ble	$t6, 1, startingScreenLoopO3
startingScreenLoopO3end:
	addi	$t6, $0, 0
	addi	$a0, $0, 33
	addi	$a1, $0, 40
	
startingScreenLoopO4:
	bge	$t6, 2, startingScreenLoopO4end
	add 	$a2, $0, 0x00FF0000 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, -1
	bgt	$a0, 23, startingScreenLoopO4
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 33	# For increased thickness
	addi	$a1, $0, 41
	ble	$t6, 1, startingScreenLoopO4
startingScreenLoopO4end:
	addi	$t6, $0, 0
	addi	$a0, $0, 37	
	addi	$a1, $0, 41
	
startingScreenLoopN:
	bge	$t6, 2, startingScreenLoopN1end
	add 	$a2, $0, 0x00FFFF00 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, -1
	bgt	$a1, 29, startingScreenLoopN
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 38	# For increased thickness
	addi	$a1, $0, 41
	ble	$t6, 1, startingScreenLoopN
	
startingScreenLoopN1end:
	addi	$t6, $0, 0
	addi	$a0, $0, 39	
	addi	$a1, $0, 31	
	
startingScreenLoopN2:
	bge	$t6, 2, startingScreenLoopN2end
	add 	$a2, $0, 0x00FFFF00 		# a2 = "random" color (next color from array)
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, 1
	blt	$a0, 45, startingScreenLoopN2
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 39	# For increased thickness
	addi	$a1, $0, 32
	ble	$t6, 1, startingScreenLoopN2
	
startingScreenLoopN2end:
	addi	$t6, $0, 0
	addi	$a0, $0, 46	
	addi	$a1, $0, 32
	
startingScreenLoopN3:
	bge	$t6, 2, startingScreenLoopN3end
	add 	$a2, $0,  0x00FFFF00		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, 1
	blt	$a1, 42, startingScreenLoopN3
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 45	# For increased thickness
	addi	$a1, $0, 32
	ble	$t6, 1, startingScreenLoopN3
startingScreenLoopN3end:
	addi	$t6, $0, 0
	addi	$a0, $0, 49
	addi	$a1, $0, 40
	
startingScreenLoopG1:
	bge	$t6, 2, startingScreenLoopG1end
	add 	$a2, $0, 0x0000FF00 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, -1
	bgt	$a1, 30, startingScreenLoopG1
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 50	# For increased thickness
	addi	$a1, $0, 40
	ble	$t6, 1, startingScreenLoopG1
	
startingScreenLoopG1end:
	addi	$t6, $0, 0
	addi	$a0, $0, 50	
	addi	$a1, $0, 30
	
startingScreenLoopG2:
	bge	$t6, 2, startingScreenLoopG2end
	add 	$a2, $0, 0x0000FF00 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, 1
	blt	$a0, 60, startingScreenLoopG2
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 50	# For increased thickness
	addi	$a1, $0, 31
	ble	$t6, 1, startingScreenLoopG2
	
startingScreenLoopG2end:
	addi	$t6, $0, 0
	addi	$a0, $0, 60	
	addi	$a1, $0, 31
	
startingScreenLoopG3:
	bge	$t6, 2, startingScreenLoopG3end
	add 	$a2, $0, 0x0000FF00 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a1, $a1, 1
	blt	$a1, 51, startingScreenLoopG3
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 59	# For increased thickness
	addi	$a1, $0, 31
	ble	$t6, 1, startingScreenLoopG3
startingScreenLoopG3end:
	addi	$t6, $0, 0
	addi	$a0, $0, 60
	addi	$a1, $0, 51
	
startingScreenLoopG4:
	bge	$t6, 2, startingScreenLoopG4end
	add 	$a2, $0, 0x0000FF00 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, -1
	bgt	$a0, 47, startingScreenLoopG4
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 51	# For increased thickness
	addi	$a1, $0, 50
	ble	$t6, 1, startingScreenLoopG4
startingScreenLoopG4end:
	addi	$t6, $0, 0
	addi	$a0, $0, 59	
	addi	$a1, $0, 40

startingScreenLoopG5:
	bge	$t6, 2, startingScreenLoopG5end
	add 	$a2, $0, 0x0000FF00 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, -1
	bgt	$a0, 50, startingScreenLoopG5
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 50	# For increased thickness
	addi	$a1, $0, 38
	ble	$t6, 1, startingScreenLoopG5
startingScreenLoopG5end:
	addi	$t6, $0, 0
	addi	$a0, $0, 0	
	addi	$a1, $0, 10

startingScreenLoopLineUp:
	bge	$t6, 2, startingScreenLoopLineUpend
	add 	$a2, $0, 0x00FF00FF 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, 1
	blt	$a0, 64, startingScreenLoopLineUp
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 0	# For increased thickness
	addi	$a1, $0, 11
	ble	$t6, 1, startingScreenLoopLineUp
	
startingScreenLoopLineUpend:
	addi	$t6, $0, 0
	addi	$a0, $0, 0	
	addi	$a1, $0, 60

startingScreenLoopLineDown:
	bge	$t6, 2, startingScreenLoopLineDownend
	add 	$a2, $0, 0x00FFFFFF 		# a2 = "random" color (next color from array)

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, 1
	blt	$a0, 64, startingScreenLoopLineDown
	
	addi	$t6, $t6, 1	# i++
	addi	$a0, $0, 0	# For increased thickness
	addi	$a1, $0, 59
	ble	$t6, 1, startingScreenLoopLineDown
	
startingScreenLoopLineDownend:
	addi	$t6, $0, 0
	addi	$a0, $0, 0	
	addi	$a1, $0, 60
	
startingScreenLoopEnd:
	addi	$a0, $a0, 1	
	jr	$ra

#################################################
# This is for drawing a random-effect box (NOT for black box ["removing box"]).
# Loop naming (Side)(Direction of movement)_loop. Ex: topR_loop = top (going from L to R)
topR_loop:
	
	addi	$a3, $a3, 1			# i++

	lw	$t1, PDLCLR2
	
	add 	$a2, $0, $t1  			# a2 = "random" color (next color from array)
	jal 	draw_pixel
	
	addi	$a0, $a0, 1 			# add 1 to x
	blt	$a3, 10, topR_loop 		# if i < 10 then go back to loop

topR_loopEnd:
	jal 	draw_pixel
	addi	$a3, $0, 0

rightD_loop:	
	addi	$a3, $a3, 1			# i++
	
	lw	$t1, PDLCLR2
	
	add 	$a2, $0, $t1  			# a2 = "random" color (next color from array)
	jal 	draw_pixel
	
	addi	$a1, $a1, 1 			# add 1 to y
	blt	$a3, 2, rightD_loop 		# if i < 7 then go back to loop
	
rightD_loopEnd:
	addi	$a3, $0, 0

downL_loop:
	addi	$a3, $a3, 1			# i++
	
	lw	$t1, PDLCLR2
	
	add 	$a2, $0, $t1  			# a2 = red (ox00RRGGBB)
	jal 	draw_pixel
	
	subi 	$a0, $a0, 1 			# subtract 1 from x 
	blt	$a3, 10, downL_loop 		# if i < 7 then go back to loop
	
downL_loopEnd:
	addi	$a3, $0, 0

leftU_loop:
	addi	$a3, $a3, 1			# i++
	
	lw	$t1, PDLCLR2
	
	add 	$a2, $0, $t1  			# a2 = "random" color (next color from array)
	jal 	draw_pixel
	
	
	subi 	$a1, $a1, 1 			# subtract 1 from y
	blt	$a3, 2, leftU_loop 		# if i < 7 then go back to loop
	
leftU_loopEnd:
	addi	$a3, $0, 0
	
	addi	$a0, $a0, 1
	addi	$a1, $a1, 1
middle:
	
	addi	$a3, $a3, 1			# i++

	lw	$t1, PDLCLR
	
	add 	$a2, $0, $t1  			# a2 = "random" color (next color from array)
	jal 	draw_pixel
	
	addi	$t4, $a0, 0
	addi	$a0, $a1, 0				# Display uncompressed start message
	li	$v0, 1					# For printing a int
	addi	$a0, $t4, 0
	
	addi	$a0, $a0, 1 			# add 1 to x
	blt	$a3, 8, middle 		# if i < 10 then go back to loop

middleEnd:
	jal 	draw_pixel
	addi	$a3, $0, 0
	addi	$a1, $a1, -1
	addi	$a0, $a0, -9
	
	j	updBall

###########
# Border hits

horizontalBorderHit: #multiply dX by -1
	bne	$s7, 1, notCornerHit # Check if y is 1 or 63 for corner hit
	bne	$s7, 63, notCornerHit
	mul	$s7, $s7, -1		# Update velocities if there's a corner hit (4 corners)
notCornerHit:
	mul	$s6, $s6, -1		# Update velocity (dX = -dY)
	j	loop

verticalBorderHit:	
	mul	$s7, $s7, -1		# Update velocity (dY = -dY)
	j	loop

checkPaddleHit:
	blt	$s3, $a0, notPaddleHit		# Branch if there wasn't a paddle hit during a vertical border hit
	addi	$t5, $a0, 10
	bgt	$s3, $t5, notPaddleHit
	
	la	$t0, colors
	lw	$t1, 0($t0)
	jal	colorChooser		# Choose a random color
	sw	$t1, PDLCLR
	
	la	$t0, colors
	lw	$t1, 0($t0)
	jal	colorChooser		 # One more time so exterior color changes
	sw	$t1, PDLCLR2
	
	mul	$t9, $s4, WIDTH  		# y * WIDTH
	add	$t9, $t9, $s3	 		# add X
	mul	$t9, $t9, 4	  		# multiply by 4 to get word offset
	add	$t9, $t9, $gp	 		# add to base address
	lw	$t6, ($t9)	  		# take color at memory location of ball
	sw	$t6, PDLCLR2				
	
	addi	$s2, $s2, 1			# Score++
	play_beep(84, 100, 80, 64)
	
	bne	$s2, 5, checkPaddleHit2
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal	FiveCombo
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
checkPaddleHit2: 
	addi	$t5, $a0, 0			# store x before using the variable
	la	$a0, msg_scoreupd		#Display message for the score upd
	li	$v0, 4			# For printing a string
	syscall
	
	addi	$a0, $s2, 0				# Display uncompressed start message
	li	$v0, 1					# For printing a int
	syscall
	
	addi	$a0, $t5, 0
	j	verticalBorderHit
	
	
notPaddleHit:
	j 	loop
	# Five combo theme song only when you get 5 hits
FiveCombo:
	play_beep(38, 400, 0, 64)
	play_beep(50, 400, 0, 64)
	play_beep(62, 400, 0, 64)
	play_sound(74, 400, 0, 64)
	
	play_beep(61, 400, 0, 64)
	play_beep(73, 400, 0, 64)
	play_beep(85, 400, 0, 64)
	play_sound(97, 400, 0, 64)
	jr	$ra
	
GameOver:	
	la	$a0, msg_end		#Display message for the message end
	li	$v0, 4			# For printing a string
	syscall
	
	addi	$a0, $s2, 0		
	li	$v0, 1			# For printing a int
	syscall
	
	la	$a0, msg_end		#Display message for the message end
	addi	$a1, $s2, 0		
	li	$v0, 56			# For printing a int
	syscall
	
	la	$a0, msg_restart 
	li	$v0, 50
	syscall	
	
	blt	$s2, 5, GameOverBad
	# The Office theme end (5+ pts)
GameOverGood:
	play_sound(74, 200, 0, 64)
	play_sound(79, 200, 0, 64)
	play_sound(74, 200, 0, 64)
	play_sound(79, 200, 0, 64)
	play_sound(83, 200, 0, 64)
	play_sound(79, 200, 0, 64)
	play_sound(83, 350, 0, 64)
	play_sound(86, 350, 0, 64)
	play_sound(91, 350, 0, 64)
	j	exit
	# The losing theme song
GameOverBad:
	play_beep(38, 400, 0, 64)
	play_beep(50, 400, 0, 64)
	play_beep(62, 400, 0, 64)
	play_sound(74, 400, 0, 64)
	
	play_beep(37, 400, 0, 64)
	play_beep(49, 400, 0, 64)
	play_beep(61, 400, 0, 64)
	play_sound(73, 400, 0, 64)
	
	play_beep(36, 400, 0, 64)
	play_beep(48, 400, 0, 64)
	play_beep(60, 400, 0, 64)
	play_sound(72, 400, 0, 64)
	
	play_beep(35, 400, 0, 64)
	play_beep(47, 400, 0, 64)
	play_beep(59, 400, 0, 64)
	play_sound(71, 400, 0, 64)

beq	$a0, 0, main			# If user wants to restart, go to restart, else exit
	j exit
#################################################
# This swaps color values across the array so that the first array value is the previous color 
colorChooser:
	la	$s5, colors			#Load the array's address into $s5
	lw	$t8, 0($s5) 			# Save the first color into the last slot before it's replaced 
	lw	$t7, 0($s5)			# Save the color into a register, and repeat for every color.
	lw	$t6, 4($s5)
	lw	$t5, 8($s5)
	lw	$t4, 12($s5)
	lw	$t3, 16($s5)
	lw	$t2, 20($s5)
	lw	$t1, 24($s5)
	lw	$t0, 28($s5)
	
	sw	$t6, 0($s5)			# Load the color of the previous element of the array into the current element of the array (prev Color = new Color). Then, repeat for every color.
	sw	$t5, 4($s5)
	sw	$t4, 8($s5)
	sw 	$t3, 12($s5)
	sw	$t2, 16($s5)
	sw	$t1, 20($s5)
	sw	$t0, 24($s5)
	sw	$t8, 28($s5)	 		# Save the first color into the back of the array
	
	jr	$ra
	
#################################################
# This part is specifically for creating a short pause to slow down the random effect.
pause:	
	# save $ra
	addi	$sp, $sp, -8
	sw	$ra, ($sp)
	sw	$a0, 4($sp)
	
	li	$v0, 32 			#syscall
	li	$a0, 30
	syscall
	
	lw	$ra, ($sp)
	lw	$a0, 4($sp)
	addi	$sp, $sp, 8
	jr 	$ra
	
#################################################
# This part is specifically for creating a black box, as it has different returns.
# Loop naming (Side)(Direction of movement)_loop. Ex: topR_loop = top (going from L to R)

topR_loopBlack:
	
	addi	$a3, $a3, 1			# i++

	addi 	$a2, $0, 0  			# a2 = black
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	#jal	pause				# Pause before the pixel is drawn
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$a0, $a0, 1 			# add 1 to x
	blt	$a3, 10, topR_loopBlack 		# if i < 7 then go back to loop

topR_loopEndBlack:
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$a3, $0, 0

rightD_loopBlack:	
	addi	$a3, $a3, 1			# i++
	
	addi 	$a2, $0, 0 			# a2 = black
	
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$a1, $a1, 1 			# add 1 to y
	blt	$a3, 10, rightD_loopBlack	# if i < 7 then go back to loop
	
rightD_loopEndBlack:
	addi	$a3, $0, 0

downL_loopBlack:
	addi	$a3, $a3, 1			# i++
	addi 	$a2, $0, 0  			# a2 = black
	
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	subi 	$a0, $a0, 1 			# subtract 1 from x 
	blt	$a3, 10, downL_loopBlack 	# if i < 7 then go back to loop
	
downL_loopEndBlack:
	addi	$a3, $0, 0

leftU_loopBlack:
	addi	$a3, $a3, 1			# i++
	
	addi 	$a2, $0, 0  			# a2 = black


	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	subi 	$a1, $a1, 1 			# subtract 1 from y
	blt	$a3, 10, leftU_loopBlack 	# if i < 7 then go back to loop
		
leftU_loopEndBlack:
	addi	$a3, $0, 0
	
	jr	$ra

	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
## Blackout entire screen (for transition b/w intro and game)
blackoutScreen:
	addi	$a1, $0, 0	# y (columns)
	addi	$a2, $0, 0	# color black
blackoutLoop1P1:
	addi	$a0, $0, 0	 # x (rows)
blackoutLoop1:	
	addi	$sp, $sp, -4			#Saving the $ra by increasing $sp
	sw	$ra, ($sp)
	jal 	draw_pixel
	lw	$ra, ($sp)			# Saving $sp value back to $ra, and then changing $sp to the normal value by adding 4
	addi	$sp, $sp, 4
	
	addi	$a0, $a0, 1	# x++
	ble	$a0, 64, blackoutLoop1
	
blackoutLoop2:
	addi	$a1, $a1, 1	# y++
	ble	$a1, 64, blackoutLoop1P1
blackoutEnd:
	addi	$a0, $0, 0	 # x (rows)
	addi	$a1, $0, 0	# y (columns)
	jr 	$ra
