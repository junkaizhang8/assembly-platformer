#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Jun Kai Zhang, 1008786253, zha12526, jkai.zhang@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# 1, 2, 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health/score
# 2. Fail condition
# 3. Win condition
# 4. Moving platforms
# 5. Shoot enemies
# 6. Double jump
#
# Link to video demonstration for final submission:
# https://play.library.utoronto.ca/watch/6803c98473990fc911c9ba14dada6f06
#
# Are you OK with us sharing the video with people outside course staff?
# yes
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
player_x_pos:		.word 0 # Current player x position
player_y_pos:		.word 0 # Current player y position
player_direction:	.word 1 # Player direction; 0 if facing left; 1 if facing right
in_air:			.word 0 # In air; 0 if on platform; 1 if not
jump_height:		.word 0 # Current jump height (0 <= jump_height <= MAX_JUMP_HEIGHT)
jumps:			.word 0 # Number of jumps performed (resets to 0 upon landing on a platform)
max_jumps:		.word 2 # Max number of jumps possible midair
game_start:		.word 0 # Game start; 0 if player has yet to jump; otherwise 1
spawn_bullet:		.word 0 # Spawn bullet; 0 if player has not pressed spacebar, 1 if player has
gained_point:		.word 0 # Gained point: 0 if player has not gained a point, otherwise 1
damaged:		.word 0 # Damaged: 0 if player is not damaged; otherwise 1
points:			.word 0 # Player points
health:			.word 100 # Player health
update_plat_pos_time:	.word 0 # Keep track of the time for updating platform positions
player_status_time:	.word 0 # Keep track of the time for displaying a player status (obtained point or damaged)


# Platform array
# Struct: {x_pos, y_pos, width} -> 12 bytes per platform
# Array max size: 120 bytes (10 objects)
platform_arr:		.space 120


# Point object array
# Struct: {x_pos, y_pos} -> 8 bytes per object
# Array max size: 24 (3 objects)
point_obj_arr:		.space 24


# Enemy array
# Struct: {x_pos, y_pos} -> 8 bytes per enemy
# Array max size: 32 (4 objects)
enemy_arr:		.space 32


# Bullet array
# Struct: {x_pos, y_pos, width, velocity, draw_bullet} -> 20 bytes per bullet
# Array max size: 200 (10 objects)
bullet_arr:		.space 200


.eqv U_WIDTH			8 # Define unit width
.eqv U_HEIGHT			8 # Define unit height
.eqv D_WIDTH_P			512 # Define display width in pixels
.eqv D_HEIGHT_P			512 # Define display height in pixels
.eqv D_WIDTH_U			64 # Define display width in units
.eqv D_HEIGHT_U			64 # Define display height in units
.eqv WINDOW_LEFT_BORDER		0 # Define left border of game window
.eqv WINDOW_RIGHT_BORDER	256 # Define right border of game window
.eqv WINDOW_TOP_BORDER		0 # Define top border of game window
.eqv WINDOW_BOTTOM_BORDER	224 # Define bottom border of game window
.eqv NEXT_ROW_INCREMENT		256 # Define the number of bytes to go to the unit directly below the current unit
.eqv BASE_ADDRESS		0x10008000 # Define base address for display
.eqv KEY_PRESS_ADDRESS      	0xffff0000 # Define the address for reading key presses
.eqv HEART_X                	4 # Define x position of heart
.eqv HEART_Y                	228 # Define y position of heart
.eqv PERCENT_SIGN_X         	136 # Define x position of percent sign
.eqv PERCENT_SIGN_Y         	232 # Define y position of percent sign
.eqv HEALTHBAR_X            	32 # Define x position of healthbar
.eqv HEALTHBAR_Y            	236 # Define y position of healthbar
.eqv PROG_BAR_X             	152 # Define x position of progress bar
.eqv PROG_BAR_Y             	236 # Define y position of progress bar
.eqv PLAYER_START_X         	120 # Define player's starting x position (has to be a multiple of PLAYER_WIDTH)
.eqv PLAYER_START_Y         	208 # Define player's starting y position (has to be a multiple of PLAYER_HEIGHT)
.eqv PLAYER_WIDTH           	16 # Define player width
.eqv PLAYER_HEIGHT          	16 # Define player height
.eqv ENEMY_WIDTH          	12 # Define enemy width
.eqv ENEMY_HEIGHT         	12 # Define enemy height
.eqv MAX_PLAT_WIDTH         	13 # Define max platform width used in generating randomly sized platforms
                               	   # (Actual max possible width is MAX_PLAT_WIDTH + MIN_PLAT_WIDTH - 1)
.eqv MIN_PLAT_WIDTH         	10 # Define min platform width used in generating randomly sized platforms
.eqv MAX_JUMP_HEIGHT        	48 # Define max jump height (i.e. max vertical distance travelled upward)
.eqv LEFT_RATE              	-8 # Define the rate the player moves left
.eqv RIGHT_RATE             	8 # Define the rate the player moves right
.eqv JUMP_RATE              	-4 # Define the rate the player moves up
.eqv FALL_RATE              	4 # Define the rate the player moves down
.eqv BULLET_LEFT_RATE       	-4 # Define the rate the bullet moves left
.eqv BULLET_RIGHT_RATE      	4 # Define the rate the bullet moves right
.eqv HEALTH_DECREASE_RATE   	-8 # Define the rate health decreases when hit by enemy
.eqv MAX_HEALTH             	100 # Define max health
.eqv POINT_INCREASE_RATE    	4 # Define the rate points increase by
.eqv WIN_CONDITION          	100 # Define the amount of points needed to win
.eqv PLAT_STRUCT_SIZE       	12 # Define the size of a platform struct in platform_arr
.eqv POINT_OBJ_STRUCT_SIZE  	8 # Define the size of a point object struct in point_obj_arr
.eqv ENEMY_STRUCT_SIZE    	8 # Define the size of a enemy struct in enemy_arr
.eqv BULLET_STRUCT_SIZE     	20 # Define the size of a bullet struct in bullet_arr
.eqv PLAT_ARR_SIZE          	120 # Define the size of plat_arr
.eqv POINT_OBJ_ARR_SIZE     	24 # Define the size of point_obj_arr
.eqv ENEMY_ARR_SIZE       	32 # Define the size of enemy_arr
.eqv BULLET_ARR_SIZE        	200 # define the size of bullet_arr
.eqv BACKGROUND_COLOUR      	0x00000000 # Define the background colour
.eqv HUD_COLOUR             	0x00888888 # Define the HUD colour
.eqv WIN_SCREEN_COLOUR      	0x00ff9200 # Define the win screen colour
.eqv DEATH_SCREEN_COLOUR    	0x00d60000 # Define the death screen colour
.eqv HEART_COLOUR           	0x00ff0000 # Define the heart colour
.eqv PERCENT_SIGN_COLOUR    	0x00ffff00 # Define the percent sign colour
.eqv HEALTHBAR_COLOUR       	0x00a00000 # Define the healthbar colour
.eqv PROG_BAR_COLOUR        	0x0000ff00 # Define the progress bar colour
.eqv DEFAULT_PLAYER_COLOUR  	0x000000ff # Define the player colour
.eqv PLAYER_POINT_COLOUR    	0x00ffff00 # Define the player colour when touched a point object
.eqv PLAYER_DAMAGED_COLOUR  	0x00d12637 # Define the player colour when damaged
.eqv PLAT_COLOUR      		0x00b87333 # Define the colour of platforms
.eqv POINT_OBJ_COLOUR       	0x00ffff9e # Define the colour of point objects
.eqv ENEMY_COLOUR         	0x00752428 # Define the colour of enemy
.eqv BULLET_COLOUR          	0x0000ff00 # Define the bullet colour
.eqv WHITE                  	0x00ffffff # Define white
.eqv RED                    	0x00ff0000 # Define red
.eqv LOWER_PLAT_TIME        	2 # Define number of game refreshes needed per decrease in platform height
.eqv DISPLAY_PLAYER_STATUS_TIME 3 # Define number of game refreshes to display player status effect colours
.eqv SLEEP_TIME             	30 # Define the amount of time the game sleeps per refresh


.text
init_variables:
    li $t0, PLAYER_START_X
    sw $t0, player_x_pos # Set initial player x position
    li $t0, PLAYER_START_Y
    sw $t0, player_y_pos # Set initial player y position
    li $t0, 1
    sw $t0, player_direction # Set initial player direction
    sw $zero, in_air
    sw $zero, jump_height
    sw $zero, jumps
    sw $zero, game_start
    sw $zero, spawn_bullet
    sw $zero, gained_point
    sw $zero, damaged
    sw $zero, points
    li $t0, MAX_HEALTH
    sw $t0, health
    sw $zero, update_plat_pos_time
    sw $zero, player_status_time
clear_screen:
    li $t0, D_WIDTH_U
    li $t1, WINDOW_BOTTOM_BORDER
    mult $t0, $t1
    mflo $t1
    addi $t1, $t1, BASE_ADDRESS
    li $t0, BASE_ADDRESS
    li $t2, BACKGROUND_COLOUR
clear_screen_loop:
    beq $t0, $t1, draw_hud # Branch to draw_hud if all units in game window screen has been cleared
    sw $t2, 0($t0)
    addi $t0, $t0, 4
    j clear_screen_loop
draw_hud:
    li $t1, D_WIDTH_U
    li $t2, D_HEIGHT_U
    mult $t1, $t2
    mflo $t1
    sll $t1, $t1, 2
    addi $t1, $t1, BASE_ADDRESS
    li $t2, HUD_COLOUR
draw_hud_loop:
    beq $t0, $t1, draw_heart # Branch to draw_heart if HUD background has been drawn
    sw $t2, 0($t0)
    addi $t0, $t0, 4
    j draw_hud_loop
draw_heart:
    li $t0, HEART_Y
    li $t1, D_WIDTH_U
    mult $t0, $t1
    mflo $t0
    addi $t0, $t0, HEART_X
    addi $t0, $t0, BASE_ADDRESS # t0 = base address of heart
    addi $t1, $t0, NEXT_ROW_INCREMENT
    addi $t2, $t1, NEXT_ROW_INCREMENT
    addi $t3, $t2, NEXT_ROW_INCREMENT
    addi $t4, $t3, NEXT_ROW_INCREMENT
    li $t5, HEART_COLOUR
    # Draw heart
    sw $t5, 4($t0)
    sw $t5, 8($t0)
    sw $t5, 16($t0)
    sw $t5, 20($t0)
    sw $t5, 0($t1)
    sw $t5, 4($t1)
    sw $t5, 8($t1)
    sw $t5, 12($t1)
    sw $t5, 16($t1)
    sw $t5, 20($t1)
    sw $t5, 24($t1)
    sw $t5, 4($t2)
    sw $t5, 8($t2)
    sw $t5, 12($t2)
    sw $t5, 16($t2)
    sw $t5, 20($t2)
    sw $t5, 8($t3)
    sw $t5, 12($t3)
    sw $t5, 16($t3)
    sw $t5, 12($t4)
draw_healthbar:
    li $t0, HEALTHBAR_Y
    li $t1, D_WIDTH_U
    mult $t0, $t1
    mflo $t0
    addi $t0, $t0, HEALTHBAR_X
    addi $t0, $t0, BASE_ADDRESS # t0 = base address of healthbar
    addi $t1, $t0, NEXT_ROW_INCREMENT
    addi $t2, $t1, NEXT_ROW_INCREMENT
    addi $t3, $t0, MAX_HEALTH
    li $t4, HEALTHBAR_COLOUR
draw_healthbar_loop:
    beq $t0, $t3, draw_percent_sign # Branch to draw_percent_sign if healthbar has been drawn
    sw $t4, 0($t0)
    sw $t4, 0($t1)
    sw $t4, 0($t2)
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    j draw_healthbar_loop
draw_percent_sign:
    li $t0, PERCENT_SIGN_Y
    li $t1, D_WIDTH_U
    mult $t0, $t1
    mflo $t0
    addi $t0, $t0, PERCENT_SIGN_X
    addi $t0, $t0, BASE_ADDRESS # t0 = base address of percent sign
    addi $t1, $t0, NEXT_ROW_INCREMENT
    addi $t2, $t1, NEXT_ROW_INCREMENT
    addi $t3, $t2, NEXT_ROW_INCREMENT
    li $t4, PERCENT_SIGN_COLOUR
    # Draw percent sign
    sw $t4, 0($t0)
    sw $t4, 12($t0)
    sw $t4, 8($t1)
    sw $t4, 4($t2)
    sw $t4, 0($t3)
    sw $t4, 12($t3)
draw_progress_bar:
    li $t0, PROG_BAR_Y
    li $t1, D_WIDTH_U
    mult $t0, $t1
    mflo $t0
    addi $t0, $t0, PROG_BAR_X
    addi $t0, $t0, BASE_ADDRESS # t0 = base address of percent sign
    addi $t1, $t0, NEXT_ROW_INCREMENT
    addi $t2, $t1, NEXT_ROW_INCREMENT
    addi $t3, $t0, WIN_CONDITION
    li $t4, BACKGROUND_COLOUR
draw_progress_bar_loop:
    beq $t0, $t3, load_platforms # Branch to load_platform if progress bar has been drawn
    sw $t4, 0($t0)
    sw $t4, 0($t1)
    sw $t4, 0($t2)
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    j draw_progress_bar_loop
load_platforms:
    la $t0, platform_arr

    # Load 10 platforms into plat_arr

    li $t1, 100 # x_pos
    sw $t1, 0($t0)
    li $t1, 204 # y_pos
    sw $t1, 4($t0)
    li $t1, 64 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 192 # x_pos
    sw $t1, 0($t0)
    li $t1, 188 # y_pos
    sw $t1, 4($t0)
    li $t1, 56 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 40 # x_pos
    sw $t1, 0($t0)
    li $t1, 164 # y_pos
    sw $t1, 4($t0)
    li $t1, 44 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 132 # x_pos
    sw $t1, 0($t0)
    li $t1, 148 # y_pos
    sw $t1, 4($t0)
    li $t1, 48 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 120 # x_pos
    sw $t1, 0($t0)
    li $t1, 120 # y_pos
    sw $t1, 4($t0)
    li $t1, 56 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 0 # x_pos
    sw $t1, 0($t0)
    li $t1, 100 # y_pos
    sw $t1, 4($t0)
    li $t1, 80 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 184 # x_pos
    sw $t1, 0($t0)
    li $t1, 80 # y_pos
    sw $t1, 4($t0)
    li $t1, 60 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 32 # x_pos
    sw $t1, 0($t0)
    li $t1, 56 # y_pos
    sw $t1, 4($t0)
    li $t1, 52 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 160 # x_pos
    sw $t1, 0($t0)
    li $t1, 32 # y_pos
    sw $t1, 4($t0)
    li $t1, 68 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

    li $t1, 24 # x_pos
    sw $t1, 0($t0)
    li $t1, 12 # y_pos
    sw $t1, 4($t0)
    li $t1, 72 # width
    sw $t1, 8($t0)
    addi $t0, $t0, PLAT_STRUCT_SIZE

load_point_objs:
    la $t0, point_obj_arr

    # Load 3 point objects into point_obj_arr

    li $t1, 28 # x_pos
    sw $t1, 0($t0)
    li $t1, 120 # y_pos
    sw $t1, 4($t0)
    addi $t0, $t0, POINT_OBJ_STRUCT_SIZE

    li $t1, 180 # x_pos
    sw $t1, 0($t0)
    li $t1, 88 # y_pos
    sw $t1, 4($t0)
    addi $t0, $t0, POINT_OBJ_STRUCT_SIZE

    li $t1, 136 # x_pos
    sw $t1, 0($t0)
    li $t1, 20 # y_pos
    sw $t1, 4($t0)

load_enemies:
    la $t0, enemy_arr

    # Load 4 enemies into enemy_arr

    li $t1, 100 # x_pos
    sw $t1, 0($t0)
    li $t1, 144 # y_pos
    sw $t1, 4($t0)
    addi $t0, $t0, ENEMY_STRUCT_SIZE

    li $t1, 172 # x_pos
    sw $t1, 0($t0)
    li $t1, 120 # y_pos
    sw $t1, 4($t0)
    addi $t0, $t0, ENEMY_STRUCT_SIZE

    li $t1, 8 # x_pos
    sw $t1, 0($t0)
    li $t1, 96 # y_pos
    sw $t1, 4($t0)
    addi $t0, $t0, ENEMY_STRUCT_SIZE

    li $t1, 40 # x_pos
    sw $t1, 0($t0)
    li $t1, 56 # y_pos
    sw $t1, 4($t0)

clear_bullet_arr:
    la $t0, bullet_arr
    li $t1, BULLET_ARR_SIZE
    add $t1, $t0, $t1
clear_bullet_arr_loop:
    beq $t0, $t1, main # Branch to main if all bullets in bullet_arr have draw_bullet set to 0
    sw $zero, 16($t0)
    addi $t0, $t0, BULLET_STRUCT_SIZE
    j clear_bullet_arr_loop

main:
    li $t0, KEY_PRESS_ADDRESS
    lw $t1, 0($t0)
    bne $t1, 1, check_jump # Branch to check_jump if no keys pressed
    lw $t0, 4($t0) # Load ASCII value of key into t0
    beq $t0, 112, init_variables # Branch to init_variables if pressed key = p

check_key:
w_key:
    bne $t0, 119, a_key # Branch to a_key if w is not pressed
    li $t3, 1
    sw $t3, game_start # game_start = 1
    lw $t3, jumps
    lw $t4, max_jumps
    bge $t3, $t4, check_jump # Branch to check_jump if jumps >= max_jumps
increase_jumps:
    addi $t3, $t3, 1
    sw $t3, jumps # jumps++
    li $t3, 1
    sw $t3, in_air # in_air = 1
    sw $zero, jump_height # jump_height = 0
    j check_jump
a_key:
    bne $t0, 97, d_key # Branch to d_key if a is not pressed
    lw $t1, player_x_pos
    ble $t1, WINDOW_LEFT_BORDER, check_jump # Branch to check_jump if player has reached left border of window
    move $a0, $t1
    lw $t1, player_y_pos
    move $a1, $t1
    li $a2, PLAYER_WIDTH
    li $a3, PLAYER_HEIGHT
    jal delete_obj # Delete player at current position
    lw $t1, player_x_pos # Load player_x_pos
    addi $t1, $t1, LEFT_RATE # Move player left by LEFT_RATE units
    sw $t1, player_x_pos # Store player_x_position
    sw $zero, player_direction # player_direction = 0
    j check_jump
d_key:
    bne $t0, 100, space_key # Branch to space_key if d is not pressed
    lw $t1, player_x_pos
    addi $t2, $t1, PLAYER_WIDTH
    bge $t2, WINDOW_RIGHT_BORDER, check_jump # Branch to check_jump if player has reached right border of window
    move $a0, $t1
    lw $t1, player_y_pos
    move $a1, $t1
    li $a2, PLAYER_WIDTH
    li $a3, PLAYER_HEIGHT
    jal delete_obj # Delete player at current position
    lw $t1, player_x_pos # Load player_x_pos
    addi $t1, $t1, RIGHT_RATE # Move player right by RIGHT_RATE units
    sw $t1, player_x_pos # Store player_x_position
    li $t1, 1
    sw $t1, player_direction # player_direction = 1
space_key:
    bne $t0, 32, check_jump # Branch to check_jump if spacebar is not pressed
    li $t1, 1
    sw $t1, spawn_bullet # spawn_bullet = 1
    

check_jump:
    lw $t0, in_air
    beq $t0, $zero, check_jump_end # Branch to check_jump_end if in_air == 0 (player not in air)
    lw $t1, player_x_pos
    move $a0, $t1
    lw $t1, player_y_pos
    move $a1, $t1
    li $a2, PLAYER_WIDTH
    li $a3, PLAYER_HEIGHT
    jal delete_obj # Delete player at current position
    lw $t1, player_y_pos
    bne $t1, WINDOW_TOP_BORDER, check_jump_height # Branch to check_jump_height if player has not reached top border of window
    li $t2, MAX_JUMP_HEIGHT
    sw $t2, jump_height # jump_height = MAX_JUMP_HEIGHT
    j decrease_height
check_jump_height:
    lw $t0, jump_height
    beq $t0, MAX_JUMP_HEIGHT, decrease_height # Branch to decrease_height if jump_height == MAX_JUMP_HEIGHT
increase_height:
    addi $t1, $t1, JUMP_RATE # Move player up by JUMP_RATE units
    sw $t1, player_y_pos
    subi $t0, $t0, JUMP_RATE
    sw $t0, jump_height # jump_height -= JUMP_RATE
    j check_jump_end
decrease_height:
    addi $t2, $t1, PLAYER_HEIGHT
    beq $t2, WINDOW_BOTTOM_BORDER, on_ground # Branch to on_ground if player has reached bottom border of window

    # Checking if player has landed on a platform
    jal check_below_player
    move $t0, $v0
    bne $t0, $zero, on_ground # Branch to on_ground if any one of the units below player is a platform
not_on_platform:
    lw $t1, player_y_pos
    addi $t1, $t1, FALL_RATE # Move player down by FALL_RATE units
    sw $t1, player_y_pos
    j check_jump_end
on_ground:
    sw $zero, in_air # in_air = 0
    sw $zero, jumps # jumps = 0
check_jump_end:


check_on_platform:
    lw $t0, game_start
    beq $t0, $zero, draw_platforms # Branch to draw_platforms if game_start == 0
    lw $t0, in_air
    bne $t0, $zero, draw_platforms # Branch to draw_platforms if in_air == 0
    jal check_below_player # Call check_below_player function
    move $t0, $v0
    bne $t0, $zero, check_update_plat_pos_time # Branch to check_update_plat_pos_time if t0 == 0
    li $t0, 1
    sw $t0, in_air # in_air = 1

check_update_plat_pos_time:
    lw $t0, update_plat_pos_time
    bne $t0, LOWER_PLAT_TIME, draw_platforms # Branch to draw_platforms if update_plat_pos_time != LOWER_PLAT_TIME
    lw $t6, player_y_pos
    addi $t7, $t6, PLAYER_HEIGHT
    bge $t7, WINDOW_BOTTOM_BORDER, draw_platforms # Branch to draw_platforms if player is on the ground
    lw $t0, player_x_pos
    move $a0, $t0
    move $a1, $t6
    li $a2, PLAYER_WIDTH
    li $a3, PLAYER_HEIGHT
    jal delete_obj # Delete player at current position
    addi $t6, $t6, 4
    sw $t6, player_y_pos # player_y_pos += 4

draw_platforms:
    la $s0, platform_arr
    li $s1, PLAT_ARR_SIZE
    add $s1, $s1, $s0 # s1 = PLAT_ARR_SIZE + platform_arr
    lw $s2, update_plat_pos_time
    move $t0, $s2
    bne $s2, LOWER_PLAT_TIME, increment_draw_update_plat_pos_time # Branch to increment_draw_update_plat_pos_time if update_plat_pos_time != LOWER_PLAT_TIME
    li $t0, -1 # t0 = -1
increment_draw_update_plat_pos_time:
    addi $t0, $t0, 1
    sw $t0, update_plat_pos_time # update_plat_pos_time++
draw_platforms_loop_start:
    beq $s0, $s1, spawn_new_bullet # Branch to spawn_new_bullet if reached end of array
    lw $t6, 4($s0) # t6 = y_pos
    bne $s2, LOWER_PLAT_TIME, load_plat_address # Branch to load_plat_address if s2 != LOWER_PLAT_TIME
delete_platform:
    lw $t0, 0($s0)
    move $a0, $t0
    move $a1, $t6
    lw $t0, 8($s0)
    move $a2, $t0
    li $a3, 4
    jal delete_obj # Delete platform at current position
    addi $t6, $t6, 4 # y_pos += 4
    bge $t6, WINDOW_BOTTOM_BORDER, load_new_platform # Branch to load_new_platform if platform reached the ground
    sw $t6, 4($s0)
load_plat_address:
    li $t0, D_WIDTH_U
    mult $t6, $t0
    mflo $t0 # t0 = y_pos * D_WIDTH_U
    lw $t1, 0($s0) # t1 = x_pos
    add $t0, $t0, $t1
    addi $t0, $t0, BASE_ADDRESS # t0 = base address of platform
    lw $t1, 8($s0) # t1 = width
    add $t1, $t0, $t1 # t1 = t1 + width
draw_platform:
    beq $t0, $t1, go_to_next_platform # Branch to go_to_next_platform if reached end of array
    li $t3, PLAT_COLOUR
    sw $t3, 0($t0)
    addi $t0, $t0, 4
    j draw_platform
load_new_platform:
    # Generate random x_pos, y_pos, and width for the new platform

    li $v0, 42
    li $a0, 0
    li $a1, MAX_PLAT_WIDTH
    syscall
    addi $t0, $a0, MIN_PLAT_WIDTH
    sll $t1, $t0, 2
    sw $t1, 8($s0)
    li $t1, D_WIDTH_U
    addi $t1, $t1, 1
    sub $t1, $t1, $t0
    li $v0, 42
    li $a0, 1
    move $a1, $t1
    syscall
    sll $t0, $a0, 2
    sw $t0, 0($s0)
    sw $zero, 4($s0)
go_to_next_platform:
    addi $s0, $s0, PLAT_STRUCT_SIZE # plat_arr += PLAT_STRUCT_SIZE
    j draw_platforms_loop_start


spawn_new_bullet:
    lw $t0, spawn_bullet
    beq $t0, $zero, draw_bullets # Branch to draw_bullets if spawn_bullet == 0
    sw $zero, spawn_bullet # spawn_bullet = 0
    la $t0, bullet_arr # t0 = bullet_arr
    addi $t1, $t0, BULLET_ARR_SIZE # t1 = bullet_arr + BULLET_ARR_SIZE
check_bullet_arr_loop:
    beq $t0, $t1, draw_bullets # Branch to draw_bullets if reached end of array
    lw $t2, 16($t0) # t2 = draw_bullet
    addi $t0, $t0, BULLET_STRUCT_SIZE # bullet_arr += BULLET_STRUCT_SIZE
    bne $t2, $zero, check_bullet_arr_loop # Branch to check_bullet_arr_loop if draw_bullet == 0
    subi $t0, $t0, BULLET_STRUCT_SIZE # bullet_arr -= BULLET_STRUCT_SIZE
    lw $t3, player_direction # t3 = player_direction
    lw $t4, player_x_pos # t4 = player_x_pos
    lw $t5, player_y_pos # t5 = player_y_pos
    addi $t5, $t5, 4 # t5 = player_y_pos + 4 (this will be the y_pos at which the bullet is fired from)
    li $t6, 12 # t6 = bullet_width
    bne $t3, $zero, right_bullet # Branch to right_bullet if player_position != 0
left_bullet:
    beq $t4, WINDOW_LEFT_BORDER, draw_bullets # Branch to draw_bullets if player is at left border of window
    addi $t4, $t4, -12 # t4 = player_x_pos - 12
check_bullet_left_border:
    # Reduce the bullet width so that it will not overflow to the previous row in the display
    bge $t4, WINDOW_LEFT_BORDER, spawn_left_bullet # Branch to spawn_left_bullet if t4 >= WINDOW_LEFT_BORDER
    addi $t4, $t4, 4 # t4 += 4
    addi $t6, $t6, -4 # bullet_width -= 4
    j check_bullet_left_border
spawn_left_bullet:
    # Store the bullet object fields in the array
    sw $t4, 0($t0)
    sw $t5, 4($t0)
    sw $t6, 8($t0)
    li $t7, BULLET_LEFT_RATE
    sw $t7, 12($t0)
    li $t8, 1
    sw $t8, 16($t0)
    j draw_new_bullet
right_bullet:
    addi $t4, $t4, PLAYER_WIDTH
    beq $t4, WINDOW_RIGHT_BORDER, draw_bullets # Branch to draw_bullets if player is at right border of window
    addi $t4, $t4, 8
check_bullet_right_border:
    # Reduce the bullet width so that it will not overflow to the next row in the display
    blt $t4, WINDOW_RIGHT_BORDER, spawn_right_bullet # Branch to spawn_right_bullet if t4 < WINDOW_RIGHT_BORDER
    addi $t4, $t4, -4 # t4 -= 4
    addi $t6, $t6, -4 # bullet_width -= 4
    j check_bullet_right_border
spawn_right_bullet:
    # Store the bullet object fields in the array
    sub $t4, $t4, $t6
    addi $t4, $t4, 4
    sw $t4, 0($t0)
    sw $t5, 4($t0)
    sw $t6, 8($t0)
    li $t7, BULLET_RIGHT_RATE
    sw $t7, 12($t0)
    li $t8, 1
    sw $t8, 16($t0)
draw_new_bullet:
    li $t0, BULLET_COLOUR
    li $t1, D_WIDTH_U
    mult $t5, $t1
    mflo $t1
    add $t1, $t1, $t4
    addi $t1, $t1, BASE_ADDRESS # t1 = base address of bullet
    add $t2, $t1, $t6 # t2 = base_address + bullet_width
draw_new_bullet_loop:
    beq $t1, $t2, draw_bullets # Branch to draw_bullets if bullet has been drawn
    sw $t0, 0($t1)
    addi $t1, $t1, 4
    j draw_new_bullet_loop

draw_bullets:
    la $t0, bullet_arr
    addi $t1, $t0, BULLET_ARR_SIZE
    li $t2, D_WIDTH_U
draw_bullets_loop:
    beq $t0, $t1, draw_enemies
    lw $t3, 16($t0)
    beq $t3, $zero, check_next_bullet
    lw $t3, 0($t0) # t3 = x_pos
    lw $t4, 4($t0) # t4 = y_pos
    mult $t4, $t2
    mflo $t4
    add $t4, $t4, $t3
    addi $t4, $t4, BASE_ADDRESS # t4 = bullet_left_address
    lw $t5, 8($t0) # t5 = width
    lw $t6, 12($t0) # t6 = velocity
    bgt $t6, $zero, update_right_bullet # Branch to update_right_bullet if velocity > 0
update_left_bullet:
    add $t6, $t4, $t5
    addi $t6, $t6, -4 # t6 = bullet_right_address
    lw $t9, 0($t6)
    beq $t9, PLAT_COLOUR, check_left_bullet_info
    li $t7, BACKGROUND_COLOUR
    sw $t7, 0($t6) # Delete right-most unit of bullet
check_left_bullet_info:
    beq $t3, WINDOW_LEFT_BORDER, reduce_bullet_width # Branch to reduce_bullet_width if left-most unit reached left border of window
    addi $t3, $t3, -4 # x_pos -= 4
    sw $t3, 0($t0) # Store x_pos
    addi $t4, $t4, -4 # bullet_left_address -= 4
    li $t7, BULLET_COLOUR
    # Draw bullet
    sw $t7, 0($t4)
    sw $t7, 4($t4)
    sw $t7, 8($t4)
    j check_next_bullet
update_right_bullet:
    add $t6, $t4, $t5 # t6 = bullet_right_address + 4
    lw $t9, 0($t4)
    beq $t9, PLAT_COLOUR, check_right_bullet_info
    li $t7, BACKGROUND_COLOUR
    sw $t7, 0($t4) # Delete left-most unit of bullet
check_right_bullet_info:
    add $t7, $t3, $t5
    addi $t3, $t3, 4 # x_pos += 4
    sw $t3, 0($t0)
    beq $t7, WINDOW_RIGHT_BORDER, reduce_bullet_width # Branch to reduce_bullet_width if right-most unit reached right border of window
    addi $t4, $t4, 4 # bullet_left_address += 4
    li $t7, BULLET_COLOUR
    # Draw bullet
    sw $t7, 0($t4)
    sw $t7, 4($t4)
    sw $t7, 8($t4)
    j check_next_bullet
reduce_bullet_width:
    addi $t5, $t5, -4 # width -= 4
    beq $t5, $zero, delete_bullet # Branch to delete_bullet if width == 0
    sw $t5, 8($t0)
    j check_next_bullet
delete_bullet:
    sw $zero, 16($t0) # draw_bullet = 0
check_next_bullet:
    addi $t0, $t0, BULLET_STRUCT_SIZE # bullet_arr += BULLET_STRUCT_SIZE
    j draw_bullets_loop



draw_enemies:
    la $s0, enemy_arr
    move $s1, $zero # s1 = bullet_collision
    li $t1, ENEMY_ARR_SIZE
    li $t2, ENEMY_COLOUR
    li $t3, D_WIDTH_U
    add $t1, $t1, $s0 # t1 = ENEMY_ARR_SIZE + enemy_arr
draw_enemies_loop:
    beq $s0, $t1, draw_point_objs # Branch to draw_point_objs if reached end of array
    lw $t4, 0($s0) # t4 = x_pos
    lw $t5, 4($s0) # t5 = y_pos
    move $a0, $t4
    move $a1, $t5
    li $a2, ENEMY_WIDTH
    li $a3, ENEMY_HEIGHT
    jal check_collided # Call check_collided function

    mult $t5, $t3
    mflo $t6 # t6 = y_pos * D_WIDTH_U
    add $t6, $t6, $t4
    addi $t6, $t6, BASE_ADDRESS # t6 = base address of enemy
    addi $t7, $t6, NEXT_ROW_INCREMENT
    addi $t8, $t7, NEXT_ROW_INCREMENT
    bne $v0, $zero, delete_enemy # Branch to delete_enemy if player has collided with enemy

    # Branch to bullet_hit_enemy if bullet has hit second row of enemy
    lw $t9, 0($t7)
    beq $t9, BULLET_COLOUR, bullet_hit_enemy
    lw $t9, 4($t7)
    beq $t9, BULLET_COLOUR, bullet_hit_enemy
    lw $t9, 8($t7)
    beq $t9, BULLET_COLOUR, bullet_hit_enemy
    li $t9, RED
    # Draw enemy's second row
    sw $t9, 0($t7)
    sw $t2, 4($t7)
    sw $t9, 8($t7)
    move $t9, $zero
draw_enemy_loop:
    beq $t9, ENEMY_WIDTH, draw_enemy_loop_end # Branch to draw_enemy_loop_end if t9 == ENEMY_WIDTH

    # Branch to bullet_hit_enemy if bullet has hit first or third row of enemy
    lw $t7, 0($t6)
    beq $t7, BULLET_COLOUR, bullet_hit_enemy
    lw $t7, 0($t8)
    beq $t7, BULLET_COLOUR, bullet_hit_enemy
    # Draw enemy's first and third row
    sw $t2, 0($t6)
    sw $t2, 0($t8)
    addi $t6, $t6, 4
    addi $t8, $t8, 4
    addi $t9, $t9, 4
    j draw_enemy_loop
draw_enemy_loop_end:
    addi $s0, $s0, ENEMY_STRUCT_SIZE # enemy_arr += ENEMY_STRUCT_SIZE
    j draw_enemies_loop
bullet_hit_enemy:
    li $s1, 1 # bullet_collision = 1
delete_enemy:
    move $a0, $t4
    move $a1, $t5
    li $a2, ENEMY_WIDTH
    li $a3, ENEMY_HEIGHT
    jal delete_obj # Delete enemy at current position

    # Generate random x_pos and y_pos for the new enemy

    li $t4, D_WIDTH_U
    addi $t4, $t4, -3
    li $t5, 43

    li $v0, 42
    li $a0, 2
    move $a1, $t4
    syscall
    sll $t4, $a0, 2

    li $v0, 42
    li $a0, 3
    move $a1, $t5
    syscall
    sll $t5, $a0, 2

    sw $t4, 0($s0)
    sw $t5, 4($s0)

    beq $s1, 1, draw_point_objs # Branch to draw_point_objs if bullet_collision == 1
    li $t4, 1
    sw $t4, damaged # damaged = 1
    sw $zero, player_status_time # player_status_time = 0

    lw $t4, health
    addi $t4, $t4, HEALTH_DECREASE_RATE
    ble $t4, $zero, death_screen # Branch to death_screen if health <= 0
    sw $t4, health # health -= HEALTH_DECREASE_RATE

update_healthbar:
    # Draw healthbar
    li $t0, HEALTHBAR_Y
    li $t1, D_WIDTH_U
    mult $t0, $t1
    mflo $t0
    addi $t0, $t0, HEALTHBAR_X
    lw $t1, health
    add $t0, $t0, $t1
    addi $t0, $t0, BASE_ADDRESS # t0 = base address of healthbar
    addi $t1, $t0, NEXT_ROW_INCREMENT
    addi $t2, $t1, NEXT_ROW_INCREMENT
    li $t3, BACKGROUND_COLOUR
    sw $t3, 0($t0)
    sw $t3, 0($t1)
    sw $t3, 0($t2)
    sw $t3, 4($t0)
    sw $t3, 4($t1)
    sw $t3, 4($t2)


draw_point_objs:
    la $t0, point_obj_arr
    li $t1, POINT_OBJ_ARR_SIZE
    li $t2, POINT_OBJ_COLOUR
    li $t3, D_WIDTH_U
    add $t1, $t1, $t0 # t1 = POINT_OBJ_ARR_SIZE + point_obj_arr
draw_point_objs_loop:
    beq $t0, $t1, draw_point_objs_end # Branch to draw_point_objs_end if reached end of array
    lw $t4, 0($t0) # t4 = x_pos
    lw $t5, 4($t0) # t5 = y_pos
    move $a0, $t4
    move $a1, $t5
    li $a2, 8
    li $a3, 8
    jal check_collided # Call check_collided function

    mult $t5, $t3
    mflo $t6 # t6 = y_pos * D_WIDTH_U
    add $t6, $t6, $t4
    addi $t6, $t6, BASE_ADDRESS # t6 = base address of point object
    addi $t7, $t6, NEXT_ROW_INCREMENT
    bne $v0, $zero, delete_point_obj # Branch to delete_point_obj if player collided with point object
    # Draw point object
    sw $t2, 0($t6)
    sw $t2, 4($t6)
    sw $t2, 0($t7)
    sw $t2, 4($t7)
    addi $t0, $t0, POINT_OBJ_STRUCT_SIZE # point_obj += POINT_OBJ_STRUCT_SIZE
    j draw_point_objs_loop
delete_point_obj:
    li $t4, BACKGROUND_COLOUR
    # Delete point object
    sw $t4, 0($t6)
    sw $t4, 4($t6)
    sw $t4, 0($t7)
    sw $t4, 4($t7)
    
    li $t4, 1
    sw $t4, gained_point # gained_point = 1
    sw $zero, player_status_time # player_status_time = 0

    lw $t4, points
    addi $t4, $t4, POINT_INCREASE_RATE
    sw $t4, points # points += POINT_INCREASE_RATE

    # Generate random x_pos and y_pos for new point object

    addi $t4, $t3, -2
    li $t5, 47

    li $v0, 42
    li $a0, 5
    move $a1, $t4
    syscall
    sll $t4, $a0, 2

    li $v0, 42
    li $a0, 6
    move $a1, $t5
    syscall
    move $t5, $a0
    sll $t5, $a0, 2

    sw $t4, 0($t0)
    sw $t5, 4($t0)
update_prog_bar:
    li $t0, PROG_BAR_Y
    li $t1, D_WIDTH_U
    mult $t0, $t1
    mflo $t0
    addi $t0, $t0, PROG_BAR_X
    lw $t1, points
    add $t0, $t0, $t1
    addi $t0, $t0, -4
    addi $t0, $t0, BASE_ADDRESS # t0 = base address of progress bar
    addi $t1, $t0, NEXT_ROW_INCREMENT
    addi $t2, $t1, NEXT_ROW_INCREMENT
    li $t3, PROG_BAR_COLOUR
    # Draw progress bar
    sw $t3, 0($t0)
    sw $t3, 0($t1)
    sw $t3, 0($t2)


draw_point_objs_end:
    li $t0, DEFAULT_PLAYER_COLOUR # t0 = DEFAULT_PLAYER_COLOUR

check_new_point:
    lw $t1, gained_point
    beq $t1, $zero, check_damaged # Branch to check_damaged if gained_point == 0
    li $t0, PLAYER_POINT_COLOUR # t0 = PLAYER_POINT_COLOUR
check_damaged:
    lw $t1, damaged
    beq $t1, $zero, draw_player_current_pos # Branch to draw_player_current_pos if damaged == 0
    li $t0, PLAYER_DAMAGED_COLOUR # t0 = PLAYER_DAMAGED_COLOUR

draw_player_current_pos:
    move $a0, $t0 # colour = t0
    jal draw_player # Draw player


update_player_status:
    lw $t0, player_status_time
    # Branch to update_player_status_check_gained_point if player_status_time != DISPLAY_PLAYER_STATUS_TIME
    bne $t0, DISPLAY_PLAYER_STATUS_TIME, update_player_status_check_gained_point
    sw $zero, player_status_time # player_status_time = 0
    sw $zero, gained_point # gained_point = 0
    sw $zero, damaged # damaged = 0
    j check_win_condition
update_player_status_check_gained_point:
    lw $t1, gained_point
    beq $t1, $zero, update_player_status_check_damaged # Branch to update_player_status_check_damaged if gained_point == 0
    addi $t0, $t0, 1
    sw $t0, player_status_time # player_status_time += 1
    j check_win_condition
update_player_status_check_damaged:
    lw $t1, damaged
    beq $t1, $zero, check_win_condition # Branch to check_win_condition if damaged == 0
    addi $t0, $t0, 1
    sw $t0, player_status_time # player_status_time += 1

check_win_condition:
    lw $t0, points
    beq $t0, WIN_CONDITION, win_screen # Branch to win_screen if points == WIN_CONDITION

check_hit_ground:
    lw $t0, game_start
    beq $t0, $zero, sleep # Branch to sleep if game_start == 0
    lw $t1, player_y_pos
    addi $t1, $t1, PLAYER_HEIGHT
    bge $t1, WINDOW_BOTTOM_BORDER, death_screen # Branch to death_screen if player has hit the ground

sleep:
    li $v0, 32
    li $a0, SLEEP_TIME # Sleep for SLEEP_TIME ms
    syscall
    j main # Loop back to main









win_screen:
    li $t0, D_WIDTH_U
    li $t1, 256
    mult $t0, $t1
    mflo $t1
    addi $t1, $t1, BASE_ADDRESS
    li $t0, BASE_ADDRESS
    li $t2, WIN_SCREEN_COLOUR
win_screen_background_loop:
    beq $t0, $t1, win_text # Branch to win_text if the display has been filled with WIN_SCREEN_COLOUR
    sw $t2, 0($t0)
    addi $t0, $t0, 4
    j win_screen_background_loop
win_text:
    # Draw the winning text
    li $t0, BASE_ADDRESS
    li $t1, WHITE
    li $t2, 0x00d0d0d0
    li $t3, NEXT_ROW_INCREMENT
    li $t4, 14
    mult $t3, $t4
    mflo $t5
    add $t0, $t0, $t5

    sw $t2, 16($t0)
    sw $t1, 20($t0)
    sw $t2, 48($t0)
    sw $t1, 52($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 80($t0)
    sw $t1, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t1, 212($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 16($t0)
    sw $t2, 20($t0)
    sw $t1, 24($t0)
    sw $t2, 44($t0)
    sw $t1, 48($t0)
    sw $t2, 52($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 212($t0)
    sw $t1, 216($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 20($t0)
    sw $t2, 24($t0)
    sw $t1, 28($t0)
    sw $t2, 40($t0)
    sw $t1, 44($t0)
    sw $t2, 48($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 212($t0)
    sw $t1, 216($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 24($t0)
    sw $t2, 28($t0)
    sw $t1, 32($t0)
    sw $t2, 36($t0)
    sw $t1, 40($t0)
    sw $t2, 44($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 212($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 28($t0)
    sw $t2, 32($t0)
    sw $t1, 36($t0)
    sw $t2, 40($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 32($t0)
    sw $t1, 36($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 216($t0)
    sw $t2, 220($t0)
    sw $t1, 224($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 32($t0)
    sw $t1, 36($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 220($t0)
    sw $t1, 224($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 32($t0)
    sw $t1, 36($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 160($t0)
    sw $t1, 164($t0)
    sw $t2, 168($t0)
    sw $t1, 172($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 220($t0)
    sw $t2, 224($t0)
    sw $t1, 228($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 32($t0)
    sw $t1, 36($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t2, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t2, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t2, 156($t0)
    sw $t1, 160($t0)
    sw $t2, 164($t0)
    sw $t2, 168($t0)
    sw $t2, 172($t0)
    sw $t1, 176($t0)
    sw $t2, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 224($t0)
    sw $t1, 228($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 32($t0)
    sw $t1, 36($t0)
    sw $t2, 60($t0)
    sw $t1, 64($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 80($t0)
    sw $t1, 84($t0)
    sw $t1, 88($t0)
    sw $t2, 96($t0)
    sw $t1, 100($t0)
    sw $t1, 104($t0)
    sw $t1, 108($t0)
    sw $t1, 112($t0)
    sw $t1, 116($t0)
    sw $t1, 120($t0)
    sw $t1, 124($t0)
    sw $t2, 148($t0)
    sw $t1, 152($t0)
    sw $t1, 156($t0)
    sw $t2, 160($t0)
    sw $t2, 164($t0)
    sw $t2, 172($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t1, 184($t0)
    sw $t2, 192($t0)
    sw $t1, 196($t0)
    sw $t2, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 224($t0)
    sw $t2, 228($t0)
    sw $t1, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 32($t0)
    sw $t2, 36($t0)
    sw $t2, 60($t0)
    sw $t2, 64($t0)
    sw $t2, 68($t0)
    sw $t2, 72($t0)
    sw $t2, 76($t0)
    sw $t2, 80($t0)
    sw $t2, 84($t0)
    sw $t2, 88($t0)
    sw $t2, 96($t0)
    sw $t2, 100($t0)
    sw $t2, 104($t0)
    sw $t2, 108($t0)
    sw $t2, 112($t0)
    sw $t2, 116($t0)
    sw $t2, 120($t0)
    sw $t2, 124($t0)
    sw $t2, 148($t0)
    sw $t2, 152($t0)
    sw $t2, 156($t0)
    sw $t2, 176($t0)
    sw $t2, 180($t0)
    sw $t2, 184($t0)
    sw $t2, 192($t0)
    sw $t2, 196($t0)
    sw $t2, 204($t0)
    sw $t2, 208($t0)
    sw $t2, 228($t0)
    sw $t2, 232($t0)
    sw $t2, 236($t0)

    j restart_text # Jump to restart_text



death_screen:
    li $t0, D_WIDTH_U
    li $t1, 256
    mult $t0, $t1
    mflo $t1
    addi $t1, $t1, BASE_ADDRESS
    li $t0, BASE_ADDRESS
    li $t2, DEATH_SCREEN_COLOUR
death_screen_background_loop:
    beq $t0, $t1, death_text # Branch to death_text if the display has been filled with DEATH_SCREEN_COLOUR
    sw $t2, 0($t0)
    addi $t0, $t0, 4
    j death_screen_background_loop
death_text:
    # Draw the death text
    li $t0, BASE_ADDRESS
    li $t1, WHITE
    li $t2, 0x00d0d0d0
    li $t3, NEXT_ROW_INCREMENT
    li $t4, 14
    mult $t3, $t4
    mflo $t5
    add $t0, $t0, $t5

    sw $t2, 12($t0)
    sw $t1, 16($t0)
    sw $t2, 44($t0)
    sw $t1, 48($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t1, 64($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t1, 152($t0)
    sw $t1, 156($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t1, 196($t0)
    sw $t1, 200($t0)
    sw $t1, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t1, 224($t0)
    sw $t1, 228($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 12($t0)
    sw $t2, 16($t0)
    sw $t1, 20($t0)
    sw $t2, 40($t0)
    sw $t1, 44($t0)
    sw $t2, 48($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t2, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t2, 156($t0)
    sw $t1, 160($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t2, 196($t0)
    sw $t2, 200($t0)
    sw $t2, 204($t0)
    sw $t2, 208($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 228($t0)
    sw $t1, 232($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 16($t0)
    sw $t2, 20($t0)
    sw $t1, 24($t0)
    sw $t2, 36($t0)
    sw $t1, 40($t0)
    sw $t2, 44($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t2, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t2, 160($t0)
    sw $t1, 164($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 20($t0)
    sw $t2, 24($t0)
    sw $t1, 28($t0)
    sw $t2, 32($t0)
    sw $t1, 36($t0)
    sw $t2, 40($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t2, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t1, 196($t0)
    sw $t1, 200($t0)
    sw $t1, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 236($t0)
    sw $t1, 240($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 24($t0)
    sw $t2, 28($t0)
    sw $t1, 32($t0)
    sw $t2, 36($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t2, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t2, 196($t0)
    sw $t2, 200($t0)
    sw $t2, 204($t0)
    sw $t2, 208($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 236($t0)
    sw $t1, 240($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 28($t0)
    sw $t1, 32($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t2, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t2, 164($t0)
    sw $t1, 168($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 236($t0)
    sw $t1, 240($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 28($t0)
    sw $t1, 32($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t2, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t2, 160($t0)
    sw $t1, 164($t0)
    sw $t2, 168($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 232($t0)
    sw $t1, 236($t0)
    sw $t2, 240($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 28($t0)
    sw $t1, 32($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t2, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t2, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t2, 156($t0)
    sw $t1, 160($t0)
    sw $t2, 164($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t2, 228($t0)
    sw $t1, 232($t0)
    sw $t2, 236($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 28($t0)
    sw $t1, 32($t0)
    sw $t2, 56($t0)
    sw $t1, 60($t0)
    sw $t1, 64($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 80($t0)
    sw $t1, 84($t0)
    sw $t2, 92($t0)
    sw $t1, 96($t0)
    sw $t1, 100($t0)
    sw $t1, 104($t0)
    sw $t1, 108($t0)
    sw $t1, 112($t0)
    sw $t1, 116($t0)
    sw $t1, 120($t0)
    sw $t2, 144($t0)
    sw $t1, 148($t0)
    sw $t1, 152($t0)
    sw $t1, 156($t0)
    sw $t2, 160($t0)
    sw $t2, 176($t0)
    sw $t1, 180($t0)
    sw $t2, 188($t0)
    sw $t1, 192($t0)
    sw $t1, 196($t0)
    sw $t1, 200($t0)
    sw $t1, 204($t0)
    sw $t1, 208($t0)
    sw $t2, 216($t0)
    sw $t1, 220($t0)
    sw $t1, 224($t0)
    sw $t1, 228($t0)
    sw $t2, 232($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t2, 28($t0)
    sw $t2, 32($t0)
    sw $t2, 56($t0)
    sw $t2, 60($t0)
    sw $t2, 64($t0)
    sw $t2, 68($t0)
    sw $t2, 72($t0)
    sw $t2, 76($t0)
    sw $t2, 80($t0)
    sw $t2, 84($t0)
    sw $t2, 92($t0)
    sw $t2, 96($t0)
    sw $t2, 100($t0)
    sw $t2, 104($t0)
    sw $t2, 108($t0)
    sw $t2, 112($t0)
    sw $t2, 116($t0)
    sw $t2, 120($t0)
    sw $t2, 144($t0)
    sw $t2, 148($t0)
    sw $t2, 152($t0)
    sw $t2, 156($t0)
    sw $t2, 176($t0)
    sw $t2, 180($t0)
    sw $t2, 188($t0)
    sw $t2, 192($t0)
    sw $t2, 196($t0)
    sw $t2, 200($t0)
    sw $t2, 204($t0)
    sw $t2, 208($t0)
    sw $t2, 216($t0)
    sw $t2, 220($t0)
    sw $t2, 224($t0)
    sw $t2, 228($t0)

    j restart_text # Jump to restart_text


    
restart_text:
    # Draw the restart text
    li $t4, 9
    mult $t3, $t4
    mflo $t5
    add $t0, $t0, $t5

    sw $t1, 24($t0)
    sw $t1, 28($t0)
    sw $t1, 32($t0)
    sw $t1, 140($t0)
    sw $t1, 168($t0)
    sw $t1, 200($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 24($t0)
    sw $t1, 36($t0)
    sw $t1, 140($t0)
    sw $t1, 168($t0)
    sw $t1, 200($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 24($t0)
    sw $t1, 36($t0)
    sw $t1, 44($t0)
    sw $t1, 52($t0)
    sw $t1, 56($t0)
    sw $t1, 64($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 84($t0)
    sw $t1, 88($t0)
    sw $t1, 92($t0)
    sw $t1, 96($t0)
    sw $t1, 104($t0)
    sw $t1, 108($t0)
    sw $t1, 112($t0)
    sw $t1, 116($t0)
    sw $t1, 148($t0)
    sw $t1, 156($t0)
    sw $t1, 160($t0)
    sw $t1, 192($t0)
    sw $t1, 196($t0)
    sw $t1, 200($t0)
    sw $t1, 204($t0)
    sw $t1, 208($t0)
    sw $t1, 216($t0)
    sw $t1, 220($t0)
    sw $t1, 224($t0)
    sw $t1, 228($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 24($t0)
    sw $t1, 28($t0)
    sw $t1, 32($t0)
    sw $t1, 44($t0)
    sw $t1, 48($t0)
    sw $t1, 64($t0)
    sw $t1, 76($t0)
    sw $t1, 84($t0)
    sw $t1, 104($t0)
    sw $t1, 148($t0)
    sw $t1, 152($t0)
    sw $t1, 200($t0)
    sw $t1, 216($t0)
    sw $t1, 228($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 24($t0)
    sw $t1, 44($t0)
    sw $t1, 64($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 84($t0)
    sw $t1, 88($t0)
    sw $t1, 92($t0)
    sw $t1, 96($t0)
    sw $t1, 104($t0)
    sw $t1, 108($t0)
    sw $t1, 112($t0)
    sw $t1, 116($t0)
    sw $t1, 148($t0)
    sw $t1, 200($t0)
    sw $t1, 216($t0)
    sw $t1, 228($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 24($t0)
    sw $t1, 44($t0)
    sw $t1, 64($t0)
    sw $t1, 96($t0)
    sw $t1, 116($t0)
    sw $t1, 148($t0)
    sw $t1, 200($t0)
    sw $t1, 216($t0)
    sw $t1, 228($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 24($t0)
    sw $t1, 44($t0)
    sw $t1, 64($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 84($t0)
    sw $t1, 88($t0)
    sw $t1, 92($t0)
    sw $t1, 96($t0)
    sw $t1, 104($t0)
    sw $t1, 108($t0)
    sw $t1, 112($t0)
    sw $t1, 116($t0)
    sw $t1, 148($t0)
    sw $t1, 200($t0)
    sw $t1, 216($t0)
    sw $t1, 220($t0)
    sw $t1, 224($t0)
    sw $t1, 228($t0)

    li $t4, 5
    mult $t3, $t4
    mflo $t5
    add $t0, $t0, $t5

    sw $t1, 116($t0)
    sw $t1, 184($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 116($t0)
    sw $t1, 184($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 48($t0)
    sw $t1, 56($t0)
    sw $t1, 60($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 80($t0)
    sw $t1, 88($t0)
    sw $t1, 92($t0)
    sw $t1, 96($t0)
    sw $t1, 100($t0)
    sw $t1, 108($t0)
    sw $t1, 112($t0)
    sw $t1, 116($t0)
    sw $t1, 120($t0)
    sw $t1, 124($t0)
    sw $t1, 132($t0)
    sw $t1, 136($t0)
    sw $t1, 140($t0)
    sw $t1, 144($t0)
    sw $t1, 156($t0)
    sw $t1, 164($t0)
    sw $t1, 168($t0)
    sw $t1, 176($t0)
    sw $t1, 180($t0)
    sw $t1, 184($t0)
    sw $t1, 188($t0)
    sw $t1, 192($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 48($t0)
    sw $t1, 52($t0)
    sw $t1, 68($t0)
    sw $t1, 80($t0)
    sw $t1, 88($t0)
    sw $t1, 116($t0)
    sw $t1, 132($t0)
    sw $t1, 144($t0)
    sw $t1, 156($t0)
    sw $t1, 160($t0)
    sw $t1, 184($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 48($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 80($t0)
    sw $t1, 88($t0)
    sw $t1, 92($t0)
    sw $t1, 96($t0)
    sw $t1, 100($t0)
    sw $t1, 116($t0)
    sw $t1, 132($t0)
    sw $t1, 144($t0)
    sw $t1, 156($t0)
    sw $t1, 184($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 48($t0)
    sw $t1, 68($t0)
    sw $t1, 100($t0)
    sw $t1, 116($t0)
    sw $t1, 132($t0)
    sw $t1, 144($t0)
    sw $t1, 156($t0)
    sw $t1, 184($t0)
    sw $t1, 200($t0)
    sw $t1, 204($t0)

    addi $t0, $t0, NEXT_ROW_INCREMENT

    sw $t1, 48($t0)
    sw $t1, 68($t0)
    sw $t1, 72($t0)
    sw $t1, 76($t0)
    sw $t1, 80($t0)
    sw $t1, 88($t0)
    sw $t1, 92($t0)
    sw $t1, 96($t0)
    sw $t1, 100($t0)
    sw $t1, 116($t0)
    sw $t1, 132($t0)
    sw $t1, 136($t0)
    sw $t1, 140($t0)
    sw $t1, 144($t0)
    sw $t1, 148($t0)
    sw $t1, 156($t0)
    sw $t1, 184($t0)
    sw $t1, 200($t0)
    sw $t1, 204($t0)
wait_to_restart:
    li $t0, KEY_PRESS_ADDRESS
    lw $t1, 0($t0)
    bne $t1, 1, restart_wait # Branch to restart_wait if no keys pressed
    lw $t0, 4($t0) # Load ASCII value of key into t0
    beq $t0, 114, init_variables # Branch to init_variables if pressed key = r
    beq $t0, 112, init_variables # Branch to init_variables if pressed key = p
restart_wait:
    li $v0, 32
    li $a0, SLEEP_TIME # Sleep for SLEEP_TIME ms
    syscall
    j wait_to_restart # Loop back to wait_to_restart





# ====================================================================================================
# void delete_obj(x_pos, y_pos, width, height)
# ====================================================================================================
delete_obj:
    li $t0, D_WIDTH_U
    mult $a1, $t0
    mflo $t1
    add $t1, $t1, $a0
    addi $t1, $t1, -4
    addi $t1, $t1, BASE_ADDRESS # t1 = base address of object
    move $t2, $t1
    move $t3, $zero
    li $t0, BACKGROUND_COLOUR

# Clear the units using a row by column basis (i.e. for (row in rows): for (column in columns): do something...)
delete_obj_load_row:
    beq $t3, $a2, delete_obj_return # Branch to delete_obj_return if t3 == width
    addi $t2, $t2, 4
    addi $t3, $t3, 4
    move $t4, $t2
    move $t5, $zero
delete_obj_load_column:
    beq $t5, $a3, delete_obj_load_row # Branch to delete_obj_load_row if t5 == height
    sw $t0, 0($t4)
    addi $t4, $t4, NEXT_ROW_INCREMENT
    addi $t5, $t5, 4
    j delete_obj_load_column
delete_obj_return:
    jr $ra # Return to caller


# ====================================================================================================
# void draw_player(colour)
# ====================================================================================================
draw_player:
    move $t0, $a0 # t0 = colour
    lw $t1, player_x_pos
    lw $t2, player_y_pos
    li $t9, D_WIDTH_U
    mult $t2, $t9
    mflo $t3 # t3 = player_y_pos * D_WIDTH_U
    add $t3, $t3, $t1
    addi $t3, $t3, BASE_ADDRESS # t3 = base address of player
    addi $t4, $t3, NEXT_ROW_INCREMENT
    addi $t5, $t4, NEXT_ROW_INCREMENT
    addi $t6, $t5, NEXT_ROW_INCREMENT
    move $t7, $zero # t7 = 0
draw_player_loop_start:    
    beq $t7, PLAYER_WIDTH, draw_player_loop_end # Branch to draw_player_loop_end if t7 == PLAYER_WIDTH
    # Draw the units of first, second, and fourth row of current column
    sw $t0, 0($t3)
    sw $t0, 0($t5)
    sw $t0, 0($t6)
    # Move units right by 1 unit
    addi $t3, $t3, 4
    addi $t5, $t5, 4
    addi $t6, $t6, 4
    addi $t7, $t7, 4 # t7 += 4
    j draw_player_loop_start
draw_player_loop_end:
    # Draw the second row
    sw $t0, 4($t4)
    sw $t0, 8($t4)
    li $t1, WHITE
    lw $t8, player_direction
    bne $t8, $zero, draw_player_right # Branch to draw_player_right if player_direction != 0
draw_player_left:
    # Draw eye on the right
    sw $t1, 0($t4)
    sw $t0, 12($t4)
    j draw_player_return
draw_player_right:
    # Draw eye on the left
    sw $t0, 0($t4)
    sw $t1, 12($t4)
draw_player_return:
    jr $ra


# ====================================================================================================
# int check_below_player()
# Return 0 if none of the units below player matches a platform colour, otherwise return 1
# ====================================================================================================
check_below_player:
    lw $t0, player_x_pos
    lw $t1, player_y_pos
    li $t9, D_WIDTH_U
    addi $t2, $t1, PLAYER_HEIGHT
    mult $t2, $t9
    mflo $t2
    add $t2, $t2, $t0
    addi $t2, $t2, BASE_ADDRESS # t2 = base address of player
    # Load the colours below the player
    lw $t3, 0($t2)
    lw $t4, 4($t2)
    lw $t5, 8($t2)
    lw $t6, 12($t2)
    # Branch to check_below_player_return_1 if either one of units below player contains PLAT_COLOUR
    beq $t3, PLAT_COLOUR, check_below_player_return_1
    beq $t4, PLAT_COLOUR, check_below_player_return_1
    beq $t5, PLAT_COLOUR, check_below_player_return_1
    beq $t6, PLAT_COLOUR, check_below_player_return_1
check_below_player_return_0:
    move $v0, $zero # Return 0
    jr $ra # Return to caller
check_below_player_return_1:
    li $t7, 1
    move $v0, $t7 # Return 1
    jr $ra # Return to caller


# ====================================================================================================
# int check_collided(x_pos, y_pos, width, height)
# Return 0 if player did not collide with object specified by x_pos, y_pos, width, and height, otherwise return 1
# ====================================================================================================
check_collided:
    move $t7, $a0
    lw $t8, player_x_pos
    sub $t9, $t8, $a2 # t9 = player_x_pos - width
    bge $t9, $t7, return_not_collided # Branch to return_not_collided if t9 >= x_pos
    add $t7, $t7, $a2
    addi $t7, $t7, -4 # t7 = x_pos + width - 4
    addi $t9, $t8, PLAYER_WIDTH
    addi $t9, $t9, -4
    add $t9, $t9, $a2 # t9 = player_right_x_pos + width - 4
    ble $t9, $t7, return_not_collided # Branch to return_not_collided if t9 <= t7
    move $t7, $a1
    lw $t8, player_y_pos
    sub $t9, $t8, $a3 # t9 = player_y_pos - height
    bge $t9, $t7, return_not_collided # Branch to return_not_collided if t9 >= y_pos
    add $t7, $t7, $a3
    addi $t7, $t7, -4 # t7 = y_pos + height - 4
    addi $t9, $t8, PLAYER_HEIGHT
    addi $t9, $t9, -4
    add $t9, $t9, $a3 # t9 = player_bottom_y_pos + height - 4
    ble $t9, $t7, return_not_collided # Branch to return_not_collided if t9 <= t7
return_collided:
    li $t9, 1
    move $v0, $t9 # Return 1
    jr $ra # Return to caller
return_not_collided:
    move $v0, $zero # Return 0
    jr $ra # Return to caller