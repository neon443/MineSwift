//
//  ContentView.swift
//  MineSwift
//
//  Created by Nihaal Sharma on 08/12/2024.
//

import SwiftUI

struct ContentView: View {
	@State private var cRows: Int = 10
	@State private var cCols: Int = 10
	@State private var cBombs: Int = 10
	@State private var selectedMode: MinesweeperMode = .beginner
	
	var body: some View {
		let selectedGrid = MinesweeperGrid(mode: selectedMode, cRows: cRows, cCols: cCols, cBombs: cBombs)
		
		NavigationStack {
			VStack {
				List {
					Section("Game Settings") {
						Text(selectedMode == .custom ? "Custom Game" : "Preset Difficulty")
							.font(.system(.title2, design: .rounded, weight: .heavy))
						ModePicker(selectedMode: $selectedMode)
						Text(selectedGrid.describe())
						
						if selectedMode == .custom {
							CustomSettingsView(cRows: $cRows, cCols: $cCols, cBombs: $cBombs, maxBombs: cRows * cCols)
								.animation(.spring, value: selectedMode)
						}
					}

					Section("How to play") {
						Text("1. Select difficulty or choose a custom grid")
						Text("2. Tap Start Game")
						Text("3. Tap a square to reveal if it is a mine")
						Text("4. If it isnt a mine, it will display the number of mines in a 1 square radius, including diagonally")
						Text("5. Use the flag switch to place flags on squares")
						Text("Try to find all the squares that are not bombs.")
						Text("Good Luck!")
					}
				}
				
				Spacer()
				
				if cBombs > cRows * cCols {
					List {
						Text("More bombs than squares!")
						Text("You can have a max of \(cRows*cCols) bombs.")
					}
				}
				
				NavigationLink(destination: MinesweeperView(rows: selectedGrid.rows, cols: selectedGrid.cols, bombs: selectedGrid.bombs)) {
					Text("Start Game")
						.font(.system(.title, weight: .bold))
						.foregroundStyle(.white)
						.padding(10)
						.background(cBombs > cRows * cCols ? .red : .blue)
						.clipShape(RoundedRectangle(cornerRadius: 10))
						.padding(.bottom)
				}
			}
			.navigationTitle("MineSwift")
			#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
			#endif
		}
	}
}

struct ModePicker: View {
	@Binding var selectedMode: MinesweeperMode
	
	var body: some View {
		Picker("Mode", selection: $selectedMode) {
			ForEach(MinesweeperMode.allCases, id: \.self) { mode in
				Text(mode.rawValue).tag(mode)
			}
		}
		.pickerStyle(.segmented)
	}
}

struct CustomSettingsView: View {
	@Binding var cRows: Int
	@Binding var cCols: Int
	@Binding var cBombs: Int
	let maxBombs: Int
	
	var body: some View {
		Stepper("Rows: \(cRows)", value: $cRows, in: 1...30)
		Stepper("Columns: \(cCols)", value: $cCols, in: 1...30)
		Stepper("Bombs: \(cBombs)", value: $cBombs, in: 1...maxBombs)
	}
}

#Preview {
	ContentView()
}
