import SwiftUI

struct ContentView: View {
    
    struct MemoryCard: Identifiable {
        let id = UUID()
        let content: String
        var isFaceUp: Bool = false
        var isMatched: Bool = false
    }
    
    let allEmojis = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼"]
    
    @State private var cards: [MemoryCard] = []
    @State private var firstSelectedIndex: Int? = nil
    @State private var isProcessing = false
    @State private var numberOfPairs = 4
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Memory Game")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            Picker("Number of Pairs", selection: $numberOfPairs) {
                Text("2 Pairs").tag(2)
                Text("4 Pairs").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Button("Reset Game") {
                resetGame()
            }
            .padding(.vertical)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(cards.indices, id: \.self) { index in
                        MemoryCardView(card: cards[index])
                            .onTapGesture {
                                handleCardTap(at: index)
                            }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            resetGame()
        }
        .onChange(of: numberOfPairs) { _ in
            resetGame()
        }
    }
    
    func resetGame() {
        let chosenEmojis = Array(allEmojis.prefix(numberOfPairs))
        var newCards: [MemoryCard] = []
        
        for emoji in chosenEmojis {
            newCards.append(MemoryCard(content: emoji))
            newCards.append(MemoryCard(content: emoji))
        }
        
        cards = newCards.shuffled()
        firstSelectedIndex = nil
        isProcessing = false
    }
    
    func handleCardTap(at index: Int) {
        guard !isProcessing else { return }
        guard !cards[index].isMatched else { return }
        guard !cards[index].isFaceUp else { return }
        
        cards[index].isFaceUp = true
        
        if let firstIndex = firstSelectedIndex {
            isProcessing = true
            
            if cards[firstIndex].content == cards[index].content {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cards[firstIndex].isMatched = true
                    cards[index].isMatched = true
                    firstSelectedIndex = nil
                    isProcessing = false
                }
            } else {
                let secondIndex = index
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    cards[firstIndex].isFaceUp = false
                    cards[secondIndex].isFaceUp = false
                    firstSelectedIndex = nil
                    isProcessing = false
                }
            }
        } else {
            firstSelectedIndex = index
        }
    }
}

struct MemoryCardView: View {
    let card: ContentView.MemoryCard
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(card.isFaceUp ? Color.white : Color.blue)
                .frame(height: 100)
                .shadow(radius: 3)
                .opacity(card.isMatched ? 0 : 1)
            
            if card.isFaceUp && !card.isMatched {
                Text(card.content)
                    .font(.largeTitle)
            } else if !card.isMatched {
                Text("?")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
