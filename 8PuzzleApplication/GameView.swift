import SwiftUI

struct GameView: View {
    @ObservedObject private var model: GameModel
    @State private var showExitConfirmation = false
    @State private var showWinAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var themeArray = 0
    @State private var backgroundColors = [
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3)]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.red.opacity(0.3)]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.orange.opacity(0.3)]), startPoint: .top, endPoint: .bottom),
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.orange.opacity(0.3)]), startPoint: .top, endPoint: .bottom),

]

    @State private var tileColor: [[Color]] = [
        [Color.blue, Color.green],
        [Color.purple, Color.yellow],
        [Color.red, Color.orange],
        [Color.teal, Color.pink]
    ]

    
    init(gridSize: Int) {
        _model = ObservedObject(initialValue: GameModel(gridSize: gridSize))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text("Time: \(Int(model.elapsedTime))s")
                        .font(.headline)
                        .padding()
                    Spacer()
                    Text("Best: \(model.bestTime < Double.greatestFiniteMagnitude ? "\(Int(model.bestTime))s" : "None")")
                        .font(.headline)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .shadow(radius: 5)
                
                Spacer()

                // Grid Display centered
                VStack(spacing: 20) {
                    ForEach(0..<model.gridSize, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(0..<model.gridSize, id: \.self) { column in
                                let index = row * model.gridSize + column
                                if model.grid[index] != 0 {
                                    Text("\(model.grid[index])")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .frame(width: 70, height: 70)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [tileColor[themeArray][0].opacity(0.8), tileColor[themeArray][1].opacity(0.8)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                                        .onTapGesture {
                                            withAnimation {
                                                model.moveTile(at: index)
                                            }
                                        }
                                } else {
                                    Rectangle()
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                Spacer() // Pushes everything above to the middle
                Button(action: {
                    withAnimation {
                        // adds 1 to array and will increment and loop around when pressed
                        themeArray = (themeArray + 1) % backgroundColors.count
                    }
                }) {
                    Text("Change Theme")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(width: 150, height:40)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.green.opacity(0.4), radius: 5, x: 0, y: 5)
                }
                
                // End Game Button remains at the bottom
                Button(action: {
                    self.showExitConfirmation = true
                }) {
                    Text("End Game")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(width: 100, height: 40)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.red.opacity(0.4), radius: 5, x: 0, y: 5)
                }
                .alert(isPresented: $showExitConfirmation) {
                    Alert(
                        title: Text("Exit Game"),
                        message: Text("Are you sure you want to exit the game?"),
                        primaryButton: .destructive(Text("Yes")) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }

                // Alert for game won
                .alert(isPresented: $model.gameWon) {
                    Alert(
                        title: Text("Congratulations!"),
                        message: Text("You've successfully solved the puzzle!"),
                        dismissButton: .default(Text("OK")) {
                            model.resetGame()
                        }
                    )
                }
            }
            .frame(width: geometry.size.width) // Ensure it spans the full width
            .background(backgroundColors[themeArray].edgesIgnoringSafeArea(.all))
            .navigationBarBackButtonHidden(true)
            .onAppear {
                model.resetGame()
            }
        }
    }
}
