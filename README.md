# Tetris Final Project

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Typical_Tetris_Game.svg/800px-Typical_Tetris_Game.svg.png" alt="drawing" width="250"/>

# Expected Behavior

![](https://media.giphy.com/media/MOSebUr4rvZS0/giphy.gif?cid=790b7611y89cjijcemjxeo82wlig343d49jmynnubyurp9g2&ep=v1_gifs_search&rid=giphy.gif&ct=g)

The purpose of this project is for us to simulate the gameplay style of the popular video game Tetris.
This will include:

- A gameboard that will be a 10 x 15 40-pixel grid
- Block shapes fall from the top of the screen into this gameboard
- The block shapes stack on top of each other in the gameboard
- Players can use buttons to move the blocks horizontally to position where they land
- There are multiple shapes and they can be rotated for a better fit in the gameboard
- Once a row in the gameboard is filled up entirely, that row is cleared
- If the blocks stack over a certain height in the gameboard, the game is over
- The game will count how many blocks are placed
- The players goal is to place as many blocks as possible

# Required Hardware

The following is needed to run this game:

- Nexys A7-100t
- Computer with Vivado
- Micro-USB Cable
- VGA monitor
- VGA cable

# Block Diagram

![image](https://github.com/user-attachments/assets/dc0d718f-e1ca-4b59-8e9e-b92b6f5fe4d1)


# Instructions
A summary of the steps to get the project to work in Vivado and on the Nexys board (5 points of the Submission category)


### 1. Create a new RTL project tetris in Vivado Quick Start
- Create six new source files of file type VHDL called pong, bat_n_ball, clk_wiz_0, clk_wiz_0_clk_wiz, leddec16, vga_sync
- Create a new constraint file of file type XDC called pong
- Choose Nexys A7-100T board for the project
- Click 'Finish'
- Click design sources and copy the VHDL code from pong.vhd, bat_n_ball.vhd, clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd, leddec16.vhd, vga_sync.vhd
- Click constraints and copy the code from pong.xdc
- As an alternative, you can instead download files from Github and import them into your project when creating the project. The source file or files would still be imported during the Source step, and the constraint file or files would still be imported during the Constraints step.
### 2. Run synthesis
### 3. Run implementation
### 4. Generate bitstream, open hardware manager, and program device
- Click 'Generate Bitstream'
- Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'
- Click 'Program Device' then xc7a100t_0 to download pong.bit to the Nexys A7-100T board
### 5. How to play
![IMG_6285](https://github.com/user-attachments/assets/9c1f4c2d-ec90-490a-ae53-9c281535780c)
- Press btn0 to start the game
- Use btnl to move the block left
- Use btnr to move the block right
- When the block lands on the bottom it will jump to the top
- A cyan block will fill its place at the bottom that you can land on
- Goal is to fill the screen below the red line
  
# I/O
The inputs and outputs were taken from lab 6. The 3 buttons are used for horizontal movement, and resetting the block in the game.

```
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { btn0 }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports { btnl }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { btnr }]; #IO_L10N_T1_D15_14 Sch=btnr
```


# Images / Videos
Images and/or videos of the project in action interspersed throughout to provide context (10 points of the Submission category)

# Modifications
### We started this project with lab 6 as the baseline and slowly converted it into tetris. Below describes all the changes we made:

### 1. Gameplay Changes
  
  - The ball logic was removed entirely.
  - The bat became a falling block that drops from the top of the screen.
  - Blocks lock into place when they reach the bottom of the screen or another block.
  - Multiple blocks stack on top of each other, forming a grid.
  - A red horizontal line was drawn at y = 100 to indicate a threshold for the game end.


### 2. New Features Added

  Grid:
  - A grid of 10 columns by 15 rows was implemented (ROWS = 15, COLS = 10). Where each grid cell represents a location where blocks can land.
  - A signal board (STD_LOGIC_VECTOR(149 DOWNTO 0)) tracks which grid cells are occupied.
    
  Block Landing:
  - The block checks the grid to determine if it should stop falling, when a block stops, its position updates the grid to mark the corresponding cell as occupied.
    
  Block Reset:
  - After a block lands, a new block spawns at the top of the screen.

### 3. Signal Changes and New Components

  Added Signals:
  - falling: Indicates if the block is actively falling.
  - block_count: Counts the total number of blocks placed.
  - landed_row and landed_col: Grid cell coordinates where the block landed.
  - board_in and board_out: Pass the grid status between components.
    
  A new component falling_block was introduced to:
  - Calculate and update the block's position using bat_x, bat_y.
  - Check for collisions with the bottom or other blocks.
  - Output the color of the falling block.
  - Update the grid when the block lands.

### 4. Visual Changes

  Original Pong:
  - Visuals included a bat and ball, with a white background.
    
  Our Conversion:
  - A fixed black border on the left and right sides of the screen.
  - The grid displays cyan blocks for landed positions.
  - The falling block alternates between red and green based on the block_count.
  - A red horizontal line at y = 100 marks the game-over threshold.

### 5. Control Logic

  Original Pong:
  - Simple left/right movement for the bat using buttons btnl and btnr.
    
  Our Conversion:
  - The falling block moves in 40-pixel increments when btnl or btnr is pressed.
  - Movement is constrained within the boundaries using LEFT_BOUND and RIGHT_BOUND.
  - A reset_block_sig signal triggers the spawning of a new block after the current block lands.




# Summary

Conclude with a summary of the process itself – who was responsible for what components (preferably also shown by each person contributing to the github repository!), the timeline of work completed, any difficulties encountered and how they were solved, etc. (10 points of the Submission category)
