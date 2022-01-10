# Assembly-Implementation-of-Pong
This program uses assembly code (.asm), with the help of MARS MIPS, to create a functioning game of Pong. This was created for a Bitmap assembly project.

---

## Instructions:
1) Click Tools -> Bitmap display
2) set pixel dim to 4x4
3) set display dim to 256x256
4) Set base address for display to 0x10008000 ($gp)
5) Connect to MIPS
6) Click Tools -> Keyboard and Display MMIO Simulator
7) Connect to MIPS
8) Run the program
9) Instructions after this are also given in the console for convenience. Click w, a, s, or d to start. If you want to force quit, press Space.
10) Try to keep the ball in the boxed area, and don’t let it fall in the bottom pit, below the paddle. Use a and d to control the paddle.
11) Aim to get 5 points to achieve the combo.
12) If you receive 5+ points, you will win. This may be hard, however, given the ball’s initial random velocities. Once you lose your streak of paddle hits, the game will end.
13) A dialog box will pop up with your score. Click OK to go to the next dialog box.
14) A dialog box will now ask if you wish to restart. Click Yes, No, or cancel (also no).
15) If you win, you will hear a tune from “The Office” theme song ending. If you lose, you will hear a tune from the “sad trombone” sound effect.

---

 ## Written Overview:

  The goal of this bitmap/keyboard project is to make a fun and simple game, with unique and creative features. The game is the popular game, Pong, which is common in many classic video game consoles. This involves a paddle, and a ball, and the goal is to keep the ball in the air for the longest time possible. The greater the number of hits with the paddle, the longer the ball stays in the air, and the better the score will be.
	
  Some unique aspects from the typical/basic Pong game would be a starting screen. This shows the name of the game in colorful and bold text, for aesthetic appeal. This makes the user want to try out the game. Furthermore, the game focuses a lot on various colors, instead of the basic black and white colors seen in a normal Pong game. Here, the color of the ball is constantly changing, and the color of the paddle (and its interior) changes when the ball hits the paddle. Not only does this look nice, but it also allows the user to confirm whether the ball actually hit the paddle, as it may often be hard to distinguish when the ball hits the edge/near the edge of the paddle. In addition, when the ball hits the paddle, the color of the ball at that instance becomes the new color of the paddle’s exterior, creating a sort of “infected” effect.
	
  One of the other unique aspects of this version of Pong is also the music. It has its an intro song (intel chime), a game win song (The Office theme), and a game lose song (sad trombone effect). Overall, the colorful theme, sound effects, intro and outros make this version of Pong a fun game to play, especially if created in assembly language.

--- 

## Flowchart:
![Here](https://i.gyazo.com/d4d93eed90d560b1f01f2c3c26855c62.png)
---

## Screenshots:

![Intro Screen](https://i.gyazo.com/8db1f35483174075996cc4ad52225d6b.png)
![Bitmap Display](https://i.gyazo.com/66387661f9c1c8b26d02f43c2d228738.png)
![Game Over Screen](https://i.gyazo.com/27b09e30e6e85e8e031dcb9e8445727b.png)
---

## Notice to users:
	
  MIPS tends to cause an issue with the program if the program is run multiple times. This can result in a broken game intro, weird ball movements, broken paddle, etc. The best way to fix this is to restart MARS. Also, you need to click on the dialog box buttons at the end, in order to proceed, and sometimes the dialog box may be hidden behind the bitmap display/keyboard input. A hint is to predict where the ball is going to go when it reaches at the bottom of the box, as it may be too late to move the paddle later on, as the ball will have already fallen into the pit.
