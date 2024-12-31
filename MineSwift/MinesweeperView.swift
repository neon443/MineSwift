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

			List {
				Toggle(isOn: $flag, label: {
					Text("Flag Mode")
				})
				.padding(.bottom)

				Text("Total Bombs: \(bombs)")
					.padding()
					.frame(alignment: .center)
			}

			if game.gameOver {
				Text("Game Over")
					.font(.largeTitle)
					.foregroundColor(.red)
			} else if game.gameWon {
				Text("You Win!")
					.font(.largeTitle)
					.foregroundColor(.green)
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
			if isHighlighted {
				Color.gray.opacity(0.1)
					.animation(.easeInOut(duration: 0.3), value: isHighlighted)
			} else if cell.state == .revealed {
				Color.black
			} else {
				Color.blue
			}

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
	MinesweeperView(rows: 10, cols: 10, bombs: 5)
}
