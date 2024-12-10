//
//  MinesweeperGame.swift
//  MineSwift
//
//  Created by Nihaal Sharma on 08/12/2024.
//

import Foundation

enum MinesweeperMode: String, CaseIterable {
	case beginner, intermediate, expert, custom
	
	var details: (rows: Int, cols: Int, bombs: Int) {
		switch self {
		case .beginner: return (10, 10, 10)
		case .intermediate: return (16, 16, 40)
		case .expert: return (30, 16, 99)
		case .custom: return (20, 20, 10)
		}
	}
}

struct MinesweeperGrid {
	let rows: Int
	let cols: Int
	let bombs: Int
	
	init(mode: MinesweeperMode, cRows: Int = 20, cCols: Int = 20, cBombs: Int = 10) {
		switch mode {
			case .beginner, .intermediate, .expert:
				let details = mode.details
				self.rows = details.rows
				self.cols = details.cols
				self.bombs = details.bombs
			case .custom:
				self.rows = cRows
				self.cols = cCols
				self.bombs = cBombs
		}
	}
	
	func describe() -> String {
		return "\(rows)x\(cols) minefield with \(bombs) mines."
	}
}

class MinesweeperGame: ObservableObject {
	enum CellState {
		case hidden, revealed, flagged
	}
	
	struct Cell {
		var isMine: Bool = false
		var adjacentMines: Int = 0
		var state: CellState = .hidden
	}
	
	struct Position: Hashable {
		var row: Int
		var col: Int
	}
	
	private var rows: Int
	private var columns: Int
	@Published var board: [[Cell]]
	@Published var gameOver: Bool = false
	@Published var gameWon: Bool = false
	@Published var revealedCells = Set<Position>()
	
	init(rows: Int = 10, columns: Int = 10, mineCount: Int = 10) {
		self.rows = rows
		self.columns = columns
		self.board = Array(repeating: Array(repeating: Cell(), count: columns), count: rows)
		placeMines(mineCount)
		calculateAdjacentMines()
	}
	
	private func placeMines(_ mineCount: Int) {
		var minesPlaced = 0
		while minesPlaced < mineCount {
			let row = Int.random(in: 0..<rows)
			let col = Int.random(in: 0..<columns)
			if !board[row][col].isMine {
				board[row][col].isMine = true
				minesPlaced += 1
			}
		}
	}
	
	private func calculateAdjacentMines() {
		for row in 0..<rows {
			for col in 0..<columns {
				if board[row][col].isMine {
					continue
				}
				var adjacentMines = 0
				for r in -1...1 {
					for c in -1...1 {
						if r == 0 && c == 0 { continue }
						let newRow = row + r
						let newCol = col + c
						if newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns {
							if board[newRow][newCol].isMine {
								adjacentMines += 1
							}
						}
					}
				}
				board[row][col].adjacentMines = adjacentMines
			}
		}
	}
	
	func revealCell(row: Int, col: Int) {
		guard !gameOver else { return }
		
		var stack: [(Int, Int)] = [(row, col)]
		var revealedCellsLocal = Set<Position>()
				
		while !stack.isEmpty {
			let (r, c) = stack.removeLast()
			let pos = Position(row: r, col: c)
			if revealedCellsLocal.contains(pos) { continue }
			revealedCellsLocal.insert(pos)
			
			if board[r][c].isMine {
				gameOver = true
				revealAllBombs()
				return
			}
			board[r][c].state = .revealed
			revealedCells.insert(pos)
			
			if board[r][c].adjacentMines == 0 {
				for dr in -1...1 {
					for dc in -1...1 {
						if dr == 0 && dc == 0 { continue }
						let newRow = r + dr
						let newCol = c + dc
						if newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns {
							if !revealedCellsLocal.contains(Position(row: newRow, col: newCol)) {
								stack.append((newRow, newCol))
							}
						}
					}
				}
			}
		}
		
		func revealAllBombs() {
			for row in 0..<rows {
				for col in 0..<columns {
					if board[row][col].isMine {
						board[row][col].state = .revealed
					}
				}
			}
		}
		
		gameWon = !board.flatMap { $0 }.contains { $0.state == .hidden && !$0.isMine }
	}
	
	func flagCell(row: Int, col: Int) {
		guard !gameOver else { return }
		if board[row][col].state == .hidden {
			board[row][col].state = .flagged
		} else if board[row][col].state == .flagged {
			board[row][col].state = .hidden
		}
	}
}

