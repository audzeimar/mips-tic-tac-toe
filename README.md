# Tic-Tac-Toe in MIPS Assembly

A console-based implementation of the classic Tic-Tac-Toe game written in **MIPS Assembly**.  
The program allows a human player to compete against a computer opponent in multiple rounds.

This project was created as part of a low-level programming / computer architecture course.

---

## Features

- Human vs Computer gameplay
- Player can choose symbol (`X` or `O`)
- Board displayed after each move
- Input validation for moves and settings
- Multiple rounds (1–5)
- Automatic computer move generation
- Win detection (rows, columns, diagonals)
- Game statistics summary:
  - player wins
  - computer wins
  - draws
- Option to restart the game

---

## How the Game Works

1. The program greets the player.
2. The player chooses a symbol (`X` or `O`).
3. The player selects the number of rounds (1–5).
4. Each round:
   - The board is cleared.
   - The player makes a move (position 1–9).
   - The computer selects the first available position.
   - The program checks for a win condition.
5. After all rounds finish, a summary of results is displayed.
6. The player can choose whether to play again.

---

## Board Layout

The board positions correspond to numbers:

1 | 2 | 3
4 | 5 | 6
7 | 8 | 9


Players enter the number corresponding to the desired position.

---

## Technologies

- **MIPS Assembly**
- Tested with **MARS / SPIM simulator**

---

## Running the Program

1. Open the program in a MIPS simulator (e.g. **MARS**).
2. Assemble and run the file.
3. Follow the on-screen instructions in the console.

---

## Example Gameplay

Witaj w grze Kółko i krzyżyk
Choose your symbol (O/X): X
How many rounds (1-5)? 3

Your move (1-9): 5

---

## Learning Objectives

This project demonstrates:

- low-level programming in assembly
- memory manipulation
- branching and control flow
- simple game logic implementation
- user input validation
- structured program organization in assembly

---

## Author

Created as a university project in computer architecture / assembly programming.
