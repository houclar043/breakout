
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    512
# - Display height in pixels:   512
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################
    
    paddle_pos: .word 104
    ball_pos: .word 15488
    dir: .word 1
    counter: .word 0
    lives: .word 3
    brick_count: .word 30
    bricks: .word 0:4096
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game
    
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t1, $t0, 0
    addi $t2, $t1, 16380
    li $t3, 0
paint_black:
    beq $t1, $t2, end_paint_black
    sw $t3, 0($t1)
    addi $t1, $t1, 4
    j paint_black
end_paint_black:
    
    # fade in/out title
    li $a0, 0x330019  # very dark pink
    jal breakout
    li $a0, 0x99004c  # dark pink
    jal o
    li $v0, 32
    li $a0, 500
    syscall
    
    li $a0, 0x99004c  # dark pink
    jal breakout
    li $a0, 0xff3399  # pink
    jal o
    li $v0, 32
    li $a0, 500
    syscall
    
    li $a0, 0xff3399  # pink
    jal breakout
    li $a0, 0xffb3c6  # light pink
    jal o
    li $v0, 32
    li $a0, 500
    syscall
    
    li $a0, 0x99004c  # dark pink
    jal breakout
    li $a0, 0xff3399  # pink
    jal o
    li $v0, 32
    li $a0, 500
    syscall
    
    li $a0, 0x330019  # very dark pink
    jal breakout
    li $a0, 0x99004c  # dark pink
    jal o
    li $v0, 32
    li $a0, 500
    syscall
    
    li $a0, 0x000000  # black
    jal breakout
    jal o
    li $v0, 32
    li $a0, 500
    syscall
   
    
    li $t1, 0xc0c0c0        # $t1 = grey
    
    
    addi $t4, $t0, 0        # $t4 base adress for drawing top walls
    addi $t5, $t0, 512      # $t5 controls when to stop the loop
    addi $t2, $t0, 0        # $t2 has the base adress for drawing side walls
    la $t7, bricks
    li $t8, 2
loop_bricks:
    beq $t4, $t5, loop_bricks_end 
    li $t6, 0x00ff80   #$t6 has green color
    sw $t6, 4608($t4)  #draws the top row of bricks
    sw $t8, 4608($t7) #draws bricks in memory
    li $t6 0x0080ff   #$t6 has blue color
    sw $t6, 5120($t4)  #draws the middle row of bricks
    sw $t8, 5120($t7) #draws bricks in memory
    li $t6 0xb266ff   #$t6 has purple
    sw $t6 5632($t4)  #draws the bottom row of bricks
    sw $t8, 5632($t7) #draws bricks in memory
    addi $t4, $t4, 4 #moves to the next address for drawing
    addi $t7, $t7, 4 #increments where to store in memory
    j loop_bricks

loop_bricks_end:
    addi $t4, $t0, 0
    la $t3, bricks
    la $t8, bricks
    li $t9, 1
loop_walls:
    beq $t4, $t5, loop_walls_end    # stops the loop at the end of the second row
    sw $t1, 2048($t4)          # paint the top wall
    sw $t9, 2048($t3)
    addi $t4, $t4, 4           # moves the current address left one pixel
    addi $t3, $t3, 4
    sw $t1, 0($t2)             #paints the left wall
    sw $t1, 4($t2)
    sw $t9, 0($t8)
    sw $t9, 4($t8)
    sw $t1, 252($t2)	       #paints the right wall
    sw $t1, 248($t2)
    sw $t9, 252($t8)
    sw $t9, 248($t8)
    addi $t2, $t2, 256         #moves the current adress down one pixel
    addi $t8, $t8, 256
    j loop_walls

loop_walls_end:
    
    addi $t4, $t0, 15872  # $t4 has base address for drawing the paddle
    addi $t5, $t4, 48  # $t5 has the stopping point for drawing the paddle
    li $t1 0xff3399  #$t1 has the color for the paddle
    
    la $t6, bricks
    addi $t6, $t6, 15872
    li $t7, 3
    
loop_paddle:
    sw $t7, 104($t6)
    addi $t6, $t6, 4
    beq $t4, $t5, loop_end #stops the loop after the paddle has been drawn
    sw $t1, 104($t4)   #draws the paddle pixel
    addi $t4, $t4, 4  #increments the position of where to draw
    j loop_paddle
    
loop_end:
    sw $t1, 15488($t0) # ball
    li $t1, 0x000000
    sw $t1, 15872($t0) #erases the walls at the bottom
    sw $t1, 16124($t0)
    sw $t1, 16128($t0)
    sw $t1, 16380($t0)
    sw $t1, 15876($t0) 
    sw $t1, 16120($t0)
    sw $t1, 16132($t0)
    sw $t1, 16376($t0)
   
   li $a0, 0xffb3c6   # light pink
   jal first_heart
   jal second_heart
   jal third_heart
   
   
    j game_loop

game_loop:
	# 1a. Check if key has been pressed
    lw $t6, ADDR_KBRD
    lw $t7, 0($t6)
    bne  $t7, 1, moving #if first word is 1, a key has been pressed. 
    
    
    
    lw $t7, 4($t6)
    li $t8, 0x000000
    beq $t7, 0x61, respond_to_a   
    beq $t7, 0x64, respond_to_d
    beq $t7, 0x71, respond_to_q
    beq $t7, 0x70, respond_to_p
    beq $t7, 0x6c, respond_to_l
    j moving

respond_to_l:
    la $t1, brick_count
    li $t2, 30
    sw $t2, 0($t1)
    li $a1, 0x000000
    li $a2, 0
    li $s0, 240
    li $s1, 0
loop_bricks_erase:
    beq $s1, $s0, game_loop
    addi $a0, $s1, 4616
    jal erase_rectangle
    addi $a0, $s1, 5128
    jal erase_rectangle
    addi $a0, $s1, 5640
    jal erase_rectangle
    addi $s1, $s1, 24
    j loop_bricks_erase
    
    
respond_to_p:
    lw $t6, ADDR_KBRD
    lw $t7, 4($t6)
    li $t1, 0x72
    beq $t7, $t1, game_loop
    j respond_to_p

respond_to_a:
    
    la $t1, paddle_pos #$t1 has address of paddle position
    lw $t2, 0($t1) # $t2 has value of paddle position
    beq $t2, 8, moving #don't move the paddle if it is already on the left edge
    subi $t2, $t2, 4 #decrease the paddle position
    sw $t2, 0($t1) #store the new value of paddle position
    li $t3 0xff3399 # $t3 has the color of the paddle
    li $t4, 0x000000 # $t4 has black
    addi $t5, $t2, 15920
    add $t5, $t5, $t0 # $t5 has the address for erasing the right edge of the paddle
    sw $t4, 0($t5) # erases the right edge of the paddle
    subi $t5, $t5, 48 # $t5 has address for drawing the left edge of paddle
    sw $t3, 0($t5) # left edge of paddle is drawn
    la $t6, bricks
    addi $t6, $t6, 15920
    add $t6, $t6, $t2
    sw $zero, 0($t6)
    subi $t6, $t6, 48
    li $t7, 3
    sw $t7, 0($t6)
    j moving
    
respond_to_d:
    
    la $t1, paddle_pos  #$t1 has address of paddle position
    lw $t2, 0($t1)  # $t2 has value of paddle position
    beq $t2, 200, moving #don't move the paddle if it is already on the right edge
    addi $t2, $t2, 4 #increase the paddle position
    sw $t2, 0($t1) #store the new value of paddle position
    li $t3 0xff3399 # $t3 has the color of the paddle
    li $t4, 0x000000 # $t4 has black
    addi $t5, $t2, 15916 
    add $t5, $t5, $t0 # $t5 has the address for drawing the right edge of the paddle
    sw $t3, 0($t5) # draws the right edge of the paddle
    subi $t5, $t5, 48 # $t5 has address for erasing left edge of paddle
    sw $t4, 0($t5) # left edge of paddle is erased
    la $t6, bricks
    addi $t6, $t6, 15916
    add $t6, $t6, $t2
    li $t7, 3
    sw $t7, 0($t6)
    subi $t6, $t6, 48
    sw $zero, 0($t6)
    j moving
   
    
moving:
    la $t7, counter 
    lw $t8, 0($t7)
    addi $t8, $t8, 1
    beq $t8, 150000, reset
    sw $t8, 0($t7)
    j end_moving

move:
    la $t3, ball_pos
    lw $t4, 0($t3)
    la $t5, bricks
    add $t5, $t5, $t4
    addi $t5, $t5, 256
    lw $t6, 0($t5)
    beq $t6, 3, paddle_col
    la $t1, dir
    lw $t2, 0($t1)
    beq $t2, 1, up_right_col
    beq $t2, 2, up_left_col
    beq $t2, 3, down_left_col
    beq $t2, 4, down_right_col
    beq $t2, 5, up_col
    beq $t2, 6, down_col
moves:
    la $t1, dir
    lw $t2, 0($t1) #t2 is ball direction
    la $t1, ball_pos #t1 is memory of ball_pos
    lw $t3, 0($t1) #t3 is ball position
    li $t4, 0x000000 #t4 is black
    li $t5, 0xff3399 #t5 is pink
    add $t6, $t0, $t3  # t6 memory address of the ball
    beq $t2, 1, up_right
    beq $t2, 2, up_left
    beq $t2, 3, down_left
    beq $t2, 4, down_right
    beq $t2, 5, up
    beq $t2, 6, down
    
reset: 
    li $t8, 0
    sw $t8, 0($t7)
    j move
paddle_col:
    jal paddle_collisions
    j moves
up_right_col:
    jal up_right_collisions
    j moves
up_left_col:
    jal up_left_collisions
    j moves
down_left_col:
    jal down_left_collisions
    j moves
down_right_col:
    jal down_right_collisions
    j moves
up_col:
    jal up_collisions
    j moves
down_col:
    jal down_collisions
    j moves
  
  
up_right:
    sw $t4, 0($t6)  #draw the ball
    subi $t3, $t3, 252
    add $t6, $t0, $t3
    sw $t5, 0($t6)
    sw $t3, 0($t1)
    j end_moving

up_left:
    sw $t4, 0($t6) #draw the ball
    subi $t3, $t3, 260
    add $t6, $t0, $t3
    sw $t5, 0($t6)
    sw $t3, 0($t1)
    j end_moving

down_left:
    sw $t4, 0($t6) #draw the ball
    addi $t3, $t3, 252
    add $t6, $t0, $t3
    sw $t5, 0($t6)
    sw $t3, 0($t1)
    bge $t3, 16384, lose_life
    j end_moving

down_right:
    sw $t4, 0($t6) #draw the ball
    addi $t3, $t3, 260
    add $t6, $t0, $t3
    sw $t5, 0($t6)
    sw $t3, 0($t1)
    bge $t3, 16384, lose_life
    j end_moving

up:
    sw $t4, 0($t6)
    subi $t3, $t3, 256
    add $t6, $t0, $t3
    sw $t5, 0($t6)
    sw $t3, 0($t1)
    j end_moving

down:
    sw $t4, 0($t6)
    addi $t3, $t3, 256
    add $t6, $t0, $t3
    sw $t5, 0($t6)
    sw $t3, 0($t1)
    bge $t3, 16384, lose_life
    j end_moving
   
   


end_moving:
    

	
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop
    
    
    
change_dir_up_right:
   la $t1, dir
   li $t2, 1
   sw $t2, 0($t1)
   jr $ra

change_dir_up_left:
   la $t1, dir
   li $t2, 2
   sw $t2, 0($t1)
   jr $ra
   
change_dir_down_left:
   la $t1, dir
   li $t2, 3
   sw $t2, 0($t1)
   jr $ra
   
change_dir_down_right:
   la $t1, dir
   li $t2, 4
   sw $t2, 0($t1)
   jr $ra
   
change_dir_up:
   la $t1, dir
   li $t2, 5
   sw $t2, 0($t1)
   jr $ra
   
change_dir_down:
   la $t1, dir
   li $t2, 6
   sw $t2, 0($t1)
   jr $ra
    
respond_to_q:
    j lose_screen
quit:
    li $v0, 10
    syscall
    
    
lose_screen:
    li $t1, -4
outer_loop:
   beq $t1, 256, quit
   addi $t1,$t1, 4
   li $t2, -4
inner_loop: 
   beq $t2, 256, outer_loop
   addi $t2, $t2, 4
   li $t3, 64
   mult $t1, $t3
   mflo $t4
   add $t4, $t4, $t2
   add $t4, $t4, $t0
   li $t7, 0x000000
   li $t6, 0xff0000
   beq $t1, $t2, draw_red
   li $t8, 252
   sub $t9, $t8, $t2
   beq $t1, $t9, draw_red
   sw $t7, 0($t4)
   j inner_loop
draw_red:
   sw $t6, 0($t4)
   j inner_loop
   
   
   
first_heart:
    addi $t2, $a0, 0
    sw $t2, 272($t0)  # first heart
    sw $t2, 276($t0)
    sw $t2, 284($t0)
    sw $t2, 288($t0)
    sw $t2, 524($t0)
    sw $t2, 536($t0)
    sw $t2, 548($t0)
    sw $t2, 780($t0)
    sw $t2, 804($t0)
    sw $t2, 1040($t0)
    sw $t2, 1056($t0)
    sw $t2, 1300($t0)
    sw $t2, 1308($t0)
    sw $t2, 1560($t0)
    jr $ra


second_heart:
    addi $t2, $a0, 0
    sw $t2, 304($t0)  # second heart
    sw $t2, 308($t0)
    sw $t2, 316($t0)
    sw $t2, 320($t0)
    sw $t2, 556($t0)
    sw $t2, 568($t0)
    sw $t2, 580($t0)
    sw $t2, 812($t0)
    sw $t2, 836($t0)
    sw $t2, 1072($t0)
    sw $t2, 1088($t0)
    sw $t2, 1332($t0)
    sw $t2, 1340($t0)
    sw $t2, 1592($t0)
    jr $ra

third_heart:
    addi $t2, $a0, 0
    sw $t2, 336($t0)  # third heart
    sw $t2, 340($t0)
    sw $t2, 348($t0)
    sw $t2, 352($t0)
    sw $t2, 588($t0)
    sw $t2, 600($t0)
    sw $t2, 612($t0)
    sw $t2, 844($t0)
    sw $t2, 868($t0)
    sw $t2, 1104($t0)
    sw $t2, 1120($t0)
    sw $t2, 1364($t0)
    sw $t2, 1372($t0)
    sw $t2, 1624($t0)
    jr $ra

# title 
breakout:
    addi $t2, $a0, 0
    sw $t2, 7224($t0)  #b
    sw $t2, 7480($t0)
    sw $t2, 7736($t0)
    sw $t2, 7992($t0)
    sw $t2, 8248($t0)
    sw $t2, 8504($t0)
    sw $t2, 7740($t0)
    sw $t2, 7744($t0)
    sw $t2, 8000($t0)
    sw $t2, 8256($t0)
    sw $t2, 8508($t0)
    sw $t2, 8512($t0)
    
    sw $t2, 7752($t0)  #r
    sw $t2, 7760($t0)
    sw $t2, 8008($t0)
    sw $t2, 8012($t0)
    sw $t2, 8264($t0)
    sw $t2, 8520($t0)
    
    sw $t2, 7516($t0)  #e
    sw $t2, 7768($t0)
    sw $t2, 7776($t0)
    sw $t2, 8024($t0)
    sw $t2, 8028($t0)
    sw $t2, 8032($t0)
    sw $t2, 8280($t0)
    sw $t2, 8540($t0)
    sw $t2, 8544($t0)
    
    sw $t2, 7528($t0)  #a
    sw $t2, 7532($t0)
    sw $t2, 7536($t0)
    sw $t2, 7792($t0)
    sw $t2, 8040($t0)
    sw $t2, 8044($t0)
    sw $t2, 8048($t0)
    sw $t2, 8296($t0)
    sw $t2, 8304($t0)
    sw $t2, 8552($t0)
    sw $t2, 8556($t0)
    sw $t2, 8560($t0)
    
    sw $t2, 7288($t0)  #k
    sw $t2, 7544($t0)
    sw $t2, 7552($t0)
    sw $t2, 7800($t0)
    sw $t2, 7808($t0)
    sw $t2, 8056($t0)
    sw $t2, 8060($t0)
    sw $t2, 8312($t0)
    sw $t2, 8320($t0)
    sw $t2, 8568($t0)
    sw $t2, 8576($t0)
    
    sw $t2, 7848($t0)  #u
    sw $t2, 8104($t0)
    sw $t2, 8112($t0)
    sw $t2, 7856($t0)
    sw $t2, 8360($t0)
    sw $t2, 8368($t0)
    sw $t2, 8620($t0)
    
    sw $t2, 8636($t0)  #t
    sw $t2, 8380($t0)
    sw $t2, 8124($t0)
    sw $t2, 7868($t0)
    sw $t2, 7612($t0)
    sw $t2, 7356($t0)
    sw $t2, 7864($t0)
    sw $t2, 7872($t0)
    jr $ra

# title o    
o:
    addi $t2, $a0, 0
    sw $t2, 7308($t0)  #o
    sw $t2, 7560($t0)
    sw $t2, 7816($t0)
    sw $t2, 7312($t0)
    sw $t2, 7320($t0)
    sw $t2, 7324($t0)
    sw $t2, 7572($t0)
    sw $t2, 7584($t0)
    sw $t2, 7840($t0)
    sw $t2, 8092($t0)
    sw $t2, 8344($t0)
    sw $t2, 8596($t0)
    sw $t2, 8336($t0)
    sw $t2, 8076($t0)
    sw $t2, 7816($t0) 
    jr $ra 
   
lose_life: 
    la $t1, lives
    lw $t2, 0($t1)
    li $a0, 0x000000
    subi $t2, $t2, 1
    sw $t2, 0($t1)
    beq $t2, 0, lose_screen
    beq $t2, 1, one_life
    beq $t2, 2, two_lives
    
one_life:
    jal second_heart
    la $t1, dir
    li $t2, 1
    sw $t2, 0($t1)
    la $t1, ball_pos
    li $t2, 15488
    sw $t2, 0($t1)
    j game_loop
    
two_lives:
    jal third_heart
    la $t1, dir
    li $t2, 1
    sw $t2, 0($t1)
    la $t1, ball_pos
    li $t2, 15488
    sw $t2, 0($t1)
    j game_loop

paddle_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t1, ball_pos
    lw $t2, 0($t1)
    la $t1, bricks
    addi $t5, $t2, 272 #t5 is 16 pixels right and one pixel down of ball
    add $t4, $t1, $t5
    lw $t6, 0($t4)
    bne $t6, 3, paddle_up_right
    addi $t4, $t4, 16
    lw $t6, 0($t4)
    bne $t6, 3, paddle_up
    j paddle_up_left
paddle_up_right:
    add $t3, $t1, $t2
    addi $t3, $t3, 4
    lw $t4, 0($t3)
    beq $t4, 1, paddle_up_left
    jal change_dir_up_right
    j end_paddle_collisions
paddle_up:
    jal change_dir_up
    j end_paddle_collisions
paddle_up_left:
    jal change_dir_up_left
    j end_paddle_collisions
end_paddle_collisions:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
up_right_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t1, ball_pos
    lw $t2, 0($t1)   #position of the ball
    la $t1, bricks  #base memory address of bricks
    add $t3, $t2, $t1 #memory address in bricks array of the ball
    lw $t5, 4($t3)
    bge $t5, 1, UR_on_right
    lw $t5, -256($t3)
    bge $t5, 1, UR_on_top_only
    lw $t5, -252($t3)
    bge $t5, 1, UR_diagonal_only
    j end_up_right_collisions
    
UR_diagonal_only:
    jal change_dir_down_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -252
    jal top_left
    j end_up_right_collisions
    
    
UR_on_top_only:
    jal change_dir_down_right
    j end_up_right_collisions 
    
UR_on_right:
    lw $t5, -256($t3)
    bge $t5, 1, UR_on_right_and_above
    jal change_dir_up_left
    j end_up_right_collisions
    
UR_on_right_and_above:
    lw $t5, -252($t3)
    bge $t5, 1, UR_on_right_and_above_and_diagonal
    jal change_dir_down_left
    j end_up_right_collisions
    
UR_on_right_and_above_and_diagonal:
    jal change_dir_down_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -252
    jal top_left
    j end_up_right_collisions
    
end_up_right_collisions:
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 4
    jal top_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -256
    jal top_left
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
up_left_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t1, ball_pos
    lw $t2, 0($t1)   #position of the ball
    la $t1, bricks  #base memory address of bricks
    add $t3, $t2, $t1 #memory address in bricks array of the ball
    lw $t5, -4($t3)
    bge $t5, 1, UL_on_left
    lw $t5, -256($t3)
    bge $t5, 1, UL_on_top_only
    lw $t5, -260($t3)
    bge $t5, 1, UL_diagonal_only
    j end_up_left_collisions
    
UL_diagonal_only:
    jal change_dir_down_right
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -260
    jal top_left
    j end_up_left_collisions
    
     
UL_on_top_only:
    jal change_dir_down_left
    j end_up_left_collisions 
    
UL_on_left:
    lw $t5, -256($t3)
    bge $t5, 1, UL_on_left_and_above
    jal change_dir_up_right
    j end_up_left_collisions
    
UL_on_left_and_above:
    lw $t5, -260($t3)
    bge $t5, 1, UL_on_left_and_above_and_diagonal
    jal change_dir_down_right
    j end_up_left_collisions
    
UL_on_left_and_above_and_diagonal:
    jal change_dir_down_right
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -260
    jal top_left
    j end_up_left_collisions
    
end_up_left_collisions:
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -4
    jal top_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -256
    jal top_left
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
down_left_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t1, ball_pos
    lw $t2, 0($t1)   #position of the ball
    la $t1, bricks  #base memory address of bricks
    add $t3, $t2, $t1 #memory address in bricks array of the ball
    lw $t5, -4($t3)
    bge $t5, 1, DL_on_left
    lw $t5, 256($t3)
    bge $t5, 1, DL_below_only
    lw $t5, 252($t3)
    bge $t5, 1, DL_diagonal_only
    j end_down_left_collisions

    
DL_diagonal_only:
    jal change_dir_up_right
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 252
    jal top_left
    j end_down_left_collisions
    
    
DL_below_only:
    jal change_dir_up_left
    j end_down_left_collisions 
    
DL_on_left:
    lw $t5, 256($t3)
    bge $t5, 1, DL_on_left_and_below
    jal change_dir_down_right
    j end_down_left_collisions
    
DL_on_left_and_below:
    lw $t5, 252($t3)
    bge $t5, 1, DL_on_left_and_below_and_diagonal
    jal change_dir_up_right
    j end_down_left_collisions
    
DL_on_left_and_below_and_diagonal:
    jal change_dir_up_right
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 252
    jal top_left
    j end_down_left_collisions
    
end_down_left_collisions:
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -4
    jal top_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 256
    jal top_left
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    
down_right_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t1, ball_pos
    lw $t2, 0($t1)   #position of the ball
    la $t1, bricks  #base memory address of bricks
    add $t3, $t2, $t1 #memory address in bricks array of the ball
    lw $t5, 4($t3)
    bge $t5, 1, DR_on_right
    lw $t5, 256($t3)
    bge $t5, 1, DR_below_only
    lw $t5, 260($t3)
    bge $t5, 1, DR_diagonal_only
    j end_down_right_collisions
    
DR_diagonal_only:
    jal change_dir_up_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 260
    jal top_left
    j end_down_right_collisions
    
    
DR_below_only:
    jal change_dir_up_right
    j end_down_right_collisions 
    
DR_on_right:
    lw $t5, 256($t3)
    bge $t5, 1, DR_on_right_and_below
    jal change_dir_down_left
    j end_down_right_collisions
    
DR_on_right_and_below:
    lw $t5, 260($t3)
    bge $t5, 1, DR_on_right_and_below_and_diagonal
    jal change_dir_up_left
    j end_down_right_collisions
    
DR_on_right_and_below_and_diagonal:
    jal change_dir_up_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 260
    jal top_left
    j end_down_right_collisions
    
end_down_right_collisions:
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 4
    jal top_left
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 256
    jal top_left
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
up_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t1, ball_pos
    lw $t2, 0($t1)   #position of the ball
    la $t1, bricks  #base memory address of bricks
    add $t3, $t2, $t1 #memory address in bricks array of the ball
    lw $t5, -256($t3)
    bge $t5, 1, up_on_above
    j end_up_collisions
    
up_on_above:
    jal change_dir_down
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, -256
    jal top_left
    j end_up_collisions
    
    
end_up_collisions:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
down_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    la $t1, ball_pos
    lw $t2, 0($t1)   #position of the ball
    la $t1, bricks  #base memory address of bricks
    add $t3, $t2, $t1 #memory address in bricks array of the ball
    lw $t5, 256($t3)
    bge $t5, 1, down_on_below
    j end_down_collisions
    
down_on_below:
    jal change_dir_up
    la $t1, ball_pos
    lw $t2, 0($t1)
    addi $a0, $t2, 256
    jal top_left
    j end_down_collisions
    
    
end_down_collisions:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    
#erases brick with top left corner at position $a0, draws with color $a1, and writes in memeory with value $a2
erase_rectangle:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    add $t1, $a0, $zero
    la $t2, bricks
    add $t2, $t2, $t1
    add $t1, $t1, $t0
    addi $t3, $t1, 24
erase_rectangle_loop:
    beq $t1, $t3, end_erase_rectangle
    sw $a1, 0($t1)
    sw $a1, 256($t1)
    sw $a2, 0($t2)
    sw $a2, 256($t2)
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    j erase_rectangle_loop
end_erase_rectangle:
    la $t1, brick_count
    lw $t2, 0($t1)
    addi $t2, $t2, -1
    sw $t2, 0($t1)
    beq $t2, 0, draw_new_scene_call
return_erase_rectangle:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
draw_new_scene_call:
    jal draw_new_scene
    j return_erase_rectangle
    
    
    
#finds the top left corner of the brick with given pixel in $a0
top_left:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    add $t1, $a0, $zero #t1 has current position
    la $t2, bricks
    add $t2, $t2, $t1
    lw $t3, 0($t2)
    bne $t3, 2, top_left_end
    li $t2, 512
    div $t1, $t2
    mflo $t3
    mult $t3, $t2
    mflo $t3
    li $t2, 256
    div $t1, $t2
    mfhi $t2
    subi $t2, $t2, 8
    li $t4, 24
    div $t2, $t4
    mflo $t2
    mult $t2, $t4
    mflo $t2                                                                                      
    add $t2, $t2, $t3
    addi $t2, $t2, 8
    add $a0, $t2, $zero
    li $a1, 0
    li $a2, 0
    jal erase_rectangle

top_left_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
draw_new_scene:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
#Resets direction and position of the ball 
    la $t1, dir
    li $t2, 1
    sw $t2, 0($t1)
    la $t1, ball_pos
    lw $t2, 0($t1)
    add $t2, $t2, $t0
    li $t3, 0
    sw $t3, 0($t2)
    li $t2, 15488
    sw $t2, 0($t1) 
    
    li $a0, 5672
    li $a1, 0xffb3c6
    jal draw_heart
    li $a0, 4440
    jal draw_heart
    li $a0, 5768
    jal draw_heart
    li $a0, 4536
    jal draw_heart
    
    li $a1, 0x663e72
    li $a2, 2
    
    li $a0, 4104
    jal erase_rectangle
    li $a0, 4320
    jal erase_rectangle
    li $a0, 4128
    jal erase_rectangle
    li $a0, 4152
    jal erase_rectangle
    li $a0, 4248
    jal erase_rectangle
    li $a0, 4224
    jal erase_rectangle
    
    li $a1, 0xdd517f
    li $a0, 5344
    jal erase_rectangle
    li $a0, 5128
    jal erase_rectangle
    
    li $a1, 0xe68e36
    li $a0, 6152
    jal erase_rectangle   
    li $a0, 6368
    jal erase_rectangle  
    
    li $a1, 0x455db8
    li $a0, 7176
    jal erase_rectangle 
    li $a0, 7392
    jal erase_rectangle
    li $a0, 7368
    jal erase_rectangle
    li $a0, 7344
    jal erase_rectangle
    li $a0, 7272
    jal erase_rectangle
    li $a0, 7248
    jal erase_rectangle
    
    li $a1, 0x7998ee
    li $a0, 8200
    jal erase_rectangle
    li $a0, 8224
    jal erase_rectangle
    li $a0, 8248
    jal erase_rectangle
    li $a0, 8272
    jal erase_rectangle
    li $a0, 8296
    jal erase_rectangle
    li $a0, 8320
    jal erase_rectangle
    li $a0, 8344
    jal erase_rectangle
    li $a0, 8368
    jal erase_rectangle
    li $a0, 8392
    jal erase_rectangle
    li $a0, 8416
    jal erase_rectangle
    
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
#a0 base position, $a1 color
draw_heart:
   la $t1, bricks
   add $t1, $t1, $a0 #$t1 base address in memory
   add $t2, $t0, $a0 #$t2 base address for display
   li $t3, 1
   sw $a1, 4($t2)
   sw $a1, 8($t2)
   sw $a1, 16($t2)
   sw $a1, 20($t2)
   sw $a1, 256($t2)
   sw $a1, 268($t2) 
   sw $a1, 280($t2) 
   sw $a1, 512($t2) 
   sw $a1, 536($t2) 
   sw $a1, 772($t2) 
   sw $a1, 788($t2) 
   sw $a1, 1032($t2) 
   sw $a1, 1040($t2) 
   sw $a1, 1292($t2) 
   sw $t3, 4($t1)
   sw $t3, 8($t1)
   sw $t3, 16($t1)
   sw $t3, 20($t1)
   sw $t3, 256($t1)
   sw $t3, 268($t1) 
   sw $t3, 280($t1) 
   sw $t3, 512($t1) 
   sw $t3, 536($t1) 
   sw $t3, 772($t1) 
   sw $t3, 788($t1) 
   sw $t3, 1032($t1) 
   sw $t3, 1040($t1) 
   sw $t3, 1292($t1)
   jr $ra 
