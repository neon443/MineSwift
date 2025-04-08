//
//  MinesweeperView.swift
//  MineSwift
//
//  Created by Nihaal Sharma on 08/12/2024.
//

import SwiftUI

struct MinesweeperView: View {
	@StateObject private var game: MinesweeperGame

	init(rows: Int, cols: Int, bombs: Int) {
		self.rows = rows
		self.cols = cols
		self.bombs = bombs
		_game = StateObject(wrappedValue: MinesweeperGame(rows: rows, columns: cols, mineCount: bombs))
	}

	let rows: Int
	let cols: Int
	let bombs: Int

	@State private var flag: Bool = false
	@State private var hoveredCell: (Int, Int)? = nil

	var body: some View {
		VStack {
			ZStack {
				VStack(spacing: 0) {
					ForEach(0..<rows, id: \..self) { row in
						HStack(spacing: 0) {
							ForEach(0..<cols, id: \..self) { col in
								Button(action: {
									if flag {
										game.flagCell(row: row, col: col)
									} else {
										game.revealCell(row: row, col: col)
									}
								}) {
									CellView(cell: game.board[row][col], isHighlighted: isNeighborHovered(row: row, col: col))
										.frame(width: 30, height: 30)
										.border(Color.gray.opacity(0.2))
										.animation(.easeInOut(duration: 0.3), value: isNeighborHovered(row: row, col: col))
								}
								.buttonStyle(PlainButtonStyle())
								.onHover { isHovering in
									withAnimation {
										hoveredCell = isHovering ? (row, col) : nil
									}
								}
								.onTapGesture(count: 2) {
									game.flagCell(row: row, col: col)
								}
							}
						}
					}
				}
				.clipShape(RoundedRectangle(cornerRadius: 10))
				
				if game.gameOver {
					Text("Game Over")
						.font(.largeTitle)
						.bold()
						.foregroundColor(.red)
						.shadow(radius: 10)
						.shadow(radius: 10)
						.shadow(radius: 10)
				} else if game.gameWon {
					Text("You Win!")
						.font(.largeTitle)
						.bold()
						.foregroundColor(.green)
						.shadow(radius: 10)
						.shadow(radius: 10)
						.shadow(radius: 10)
				}
				if game.gameOver || game.gameWon {
					Button() {
						
					} label: {
						Text("Restart game")
					}
				}
			}

			List {
				Toggle(isOn: $flag, label: {
					Text("Flag Mode")
				})
				.padding(.bottom)

				Text("Total Bombs: \(bombs)")
					.padding()
					.frame(alignment: .center)
			}
		}
		.padding()
	}

	private func isNeighborHovered(row: Int, col: Int) -> Bool {
		guard let hovered = hoveredCell else { return false }
		let (hoveredRow, hoveredCol) = hovered
		return abs(row - hoveredRow) <= 1 && abs(col - hoveredCol) <= 1
	}
}

struct CellView: View {
	var cell: MinesweeperGame.Cell
	var isHighlighted: Bool

	var body: some View {
		ZStack {
			if cell.state == .revealed {
				Color.black.opacity(isHighlighted ? 0.5 : 1)
			} else {
				Color.blue.opacity(isHighlighted ? 0.8 : 1)
//					.animation(.spring(duration: 0.1), value: isHighlighted)
			}
			
//			if isHighlighted {
//				Color.gray.opacity(0.05)
//					.animation(.spring(duration: 0.1), value: isHighlighted)
//			}

			if cell.state == .revealed {
				if cell.isMine {
					Image(systemName: "multiply")
						.resizable()
						.scaledToFit()
						.frame(width: 20)
						.foregroundStyle(.red)

				} else if cell.adjacentMines > 0 {
					Text("\(cell.adjacentMines)")
						.foregroundStyle(.white)
						.bold()
				}
			}

			if cell.state == .flagged {
				Image(systemName: "flag.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 20)
					.foregroundStyle(.yellow)
			}
		}
	}
}

#Preview {
	MinesweeperView(rows: 10, cols: 10, bombs: 10)
}
