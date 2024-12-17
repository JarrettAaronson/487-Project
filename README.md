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

The more detailed the better – you all know how much I love a good finite state machine and Boolean logic, so those could be some good ideas if appropriate for your system. If not, some kind of high level block diagram showing how different parts of your program connect together and/or showing how what you have created might fit into a more complete system could be appropriate instead.


# Instructions
A summary of the steps to get the project to work in Vivado and on the Nexys board (5 points of the Submission category)

# I/O

```
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { btn0 }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports { btnl }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { btnr }]; #IO_L10N_T1_D15_14 Sch=btnr
```

Description of inputs from and outputs to the Nexys board from the Vivado project (10 points of the Submission category)

As part of this category, if using starter code of some kind (discussed below), you should add at least one input and at least one output appropriate to your project to demonstrate your understanding of modifying the ports of your various architectures and components in VHDL as well as the separate .xdc constraints file.

# Images / Videos
Images and/or videos of the project in action interspersed throughout to provide context (10 points of the Submission category)

# Modifications
“Modifications” (15 points of the Submission category)

If building on an existing lab or expansive starter code of some kind, describe your “modifications” – the changes made to that starter code to improve the code, create entirely new functionalities, etc. Unless you were starting from one of the labs, please share any starter code used as well, including crediting the creator(s) of any code used. It is perfectly ok to start with a lab or other code you find as a baseline, but you will be judged on your contributions on top of that pre-existing code!




# Summary

Conclude with a summary of the process itself – who was responsible for what components (preferably also shown by each person contributing to the github repository!), the timeline of work completed, any difficulties encountered and how they were solved, etc. (10 points of the Submission category)
