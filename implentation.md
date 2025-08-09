# 🎮 Tetras Game — Implementation Details

## 1️⃣ Game Overview

A **simple, free, Tetris-inspired game** built in Flutter with:

* No paid packages.
* Smooth UI/UX and animations.
* Multiple levels with increasing difficulty.
* Mobile-friendly controls.

---

## 2️⃣ Core Features

### 🎯 Gameplay

* **Classic Tetromino Pieces**: I, O, T, S, Z, J, L.
* **Grid Size**: 10 columns × 20 rows.
* **Random Piece Generator**: Uses the 7-bag system for fairness.
* **Piece Controls**:

  * Move left/right.
  * Rotate clockwise.
  * Soft drop (faster descent).
  * Hard drop (instant lock).
* **Hold Piece**:

  * Store one piece for later use.
  * Swap between held and active piece (once per turn).
* **Line Clear System**:

  * Detect and remove full horizontal lines.
  * Award points depending on lines cleared at once.
* **Scoring & Levels**:

  * Level increases every 10 cleared lines.
  * Speed increases with each level.
  * Bonus points for hard drops.

---

### 💾 Game Persistence

* **Local High Score Storage** using `shared_preferences`.
* **Save/Load Settings**:

  * Last chosen theme (light/dark).
  * Optionally: Sound on/off.

---

### 🚧 Game States

* **Playing**: Main active gameplay.
* **Paused**: Game loop stops, UI shows "Paused".
* **Game Over**: Board frozen, final score displayed.
* **Restart**: Clears the board and starts a new game.

---

## 3️⃣ UI & UX Focus

### 🎨 Main Design Goals

* **Modern, Minimal, and Clean**.
* Smooth animations for:

  * Piece movement.
  * Line clearing.
  * Game over fade effect.
* High-contrast colors for visibility.
* Soft drop shadows for a "floating" tile look.
* Responsive layout for all screen sizes.

---

### 📱 UI Layout

1. **Top Section**

   * Game Title (Tetras) in bold, stylized font.
   * Score & High Score in large font.
   * Level display.

2. **Middle Section**

   * **Main Game Grid** (10×20 board) centered.
   * **Next Piece Preview** (small grid).
   * **Hold Piece Preview** (small grid).

3. **Bottom Section**

   * **Control Buttons** for mobile:

     * Left arrow.
     * Right arrow.
     * Rotate button.
     * Soft drop button.
     * Hard drop button.
     * Hold button.
   * Buttons have rounded edges, shadows, and hover/tap animations.

---

## 4️⃣ Animations & Effects

* **Line Clear Animation**: Fade out or shrink effect before removal.
* **Piece Drop Animation**: Smooth fall when soft dropping.
* **Game Over Animation**: Fade overlay + shaking effect on the board.
* **Button Feedback**: Scale-up on press for tactile feel.

---

## 5️⃣ Technical Implementation Plan

### 🧩 Data Structures

* **Grid**: 2D list of nullable Colors (for tiles).
* **Piece Class**:

  * Type (I, O, T, etc.)
  * Rotation index.
  * Position (row, col).
* **GameModel Class**:

  * Handles game logic, scoring, collision detection, spawning pieces, etc.

---

### 🕹 Game Loop

* Use `Timer.periodic` to move the active piece down at a set interval.
* Adjust speed based on current level.
* Pause/resume by starting/stopping the timer.

---

### 📦 Packages Used

* **shared\_preferences** (free) for saving high score.
* No other external dependencies unless needed for fonts/icons.

---

## 6️⃣ Future Extensions (Optional)

* Sound effects for rotation, drop, and line clear.
* Multiple themes (Retro, Neon, Minimal).
* Leaderboard via Firebase (if you want online scores).
* Customizable controls.

