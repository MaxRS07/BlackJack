import SwiftUI
import CoreData

public enum Actions {
    case Hit
    case Double
    case Stand
    case Split
}
public enum GameState {
    case Start
    case Dealing
    case PlayerTurn
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var deck = Deck(numdecks: 1)
    
    @State var cachedPeople: [UIImage] = []
    @State var bots : Int = 0
    
    @State var state : GameState = .Start
    
    @State var dealer : Player = Player()
    @State var players : [Player] = [
        Player(),
        Player(),
        Player(name: "You"),
        Player()
    ]
    
    @State var showing = false
    
    var body: some View {
        ZStack {
            VStack {
                PlayerView(player: $players[0], status: 0)
                Spacer()
                DeckView(deck: $deck)
                Spacer()
                HStack {
                    Spacer()
                    if (bots == 2) {
                        PlayerView(player: $players[1], status: 1, rotation: 15)
                            .offset(y: -30)
                        
                        PlayerView(player: $players[2], status: -1)
                        
                        PlayerView(player: $players[3], status: 1, rotation: -15)
                            .offset(y: -30)
                    }
                    if (bots == 1) {
                        PlayerView(player: $players[1], status: 1, rotation: 0)
                        
                        PlayerView(player: $players[2], status: -1)
                        
                        Button {
                            bots += 1
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    if (bots == 0) {
                        Button {
                            bots += 1
                        } label: {
                            Image(systemName: "plus")
                        }
                        PlayerView(player: $players[2], status: -1)
                            .padding(10)
                        Button {
                            bots += 1
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    Spacer()
                }
                .disabled(state != GameState.Start)
                .buttonStyle(.borderedProminent)
                ButtonView()
                    .padding(15)
                    .disabled(state != GameState.PlayerTurn)
                BetView()
            }
            .background(Color(uiColor: UIColor(_colorLiteralRed: 0.2078, green: 0.3961, blue: 0.302, alpha: 1)).ignoresSafeArea(), alignment: .center)
            if state == .Start {
                Button("Start") {
                    state = .Dealing
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .onAppear {
            var count = 0
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task {
                    if cachedPeople.count < 4  {
                        cachedPeople.append(await PersonGetter.getPerson()!)
                        count += 1
                    }
                }
            }
        }
        .onChange(of: cachedPeople) {
            _ in
            for i in 0..<cachedPeople.count {
                players[i].image = cachedPeople[i]
            }
        }
        //.background()
        //UIColor(55, 126, 127)
    }
}

struct PlayerView: View {
    
    @Binding var player : Player
    @State var status : Int8
    @State var rotation : CGFloat = 0
    
    var body: some View {
        VStack {
            if status == 0 {
                if let image = player.image {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(Color.white,lineWidth:4).shadow(radius: 10))
                        .foregroundStyle(.white, .white)
                } else {
                    ProgressView()
                        .controlSize(.large)
                }
                Text(player.name + " (Dealer)")
                    .foregroundStyle(.white)
            }
            HandView(player: $player, rotation: rotation)
            if status != 0 {
                if status == -1 {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                }
                else if let image = player.image {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(Color.white,lineWidth:4).shadow(radius: 10))
                        .offset(x: -rotation)
                } else {
                    ProgressView()
                        .offset(x: -rotation)
                        .controlSize(.large)
                }
                Text(player.name)
                    .offset(x: -rotation)
                    .foregroundStyle(.white)
            }
        }
        .padding(20)
    }
}
struct HandView : View {
    
    @Binding var player : Player
    @State var rotation : CGFloat
    
    var vec : CGSize {
        get {return rotatedVector(angle: rotation)}
    }
    let rat = 88/CGFloat(124)
    
    var body: some View {
        HStack {
            ZStack {
                ForEach(0..<player.hand.count, id: \.self) { i in
                    Image(uiImage: player.hand[i].image())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 40)
                        .padding(10)
                        .rotationEffect(.degrees(Double(rotation)))
                        .offset(
                            x: vec.width * CGFloat(i * 10),
                            y: vec.height * CGFloat(i * 10) * rat
                        )
                }
            }
            .offset(vec * -CGFloat((player.hand.count-1) * 5))
            .rotationEffect(.degrees(rotation))
        }
    }
    func rotatedVector(angle: CGFloat) -> CGSize {
        var new_x = cos(angle)
        let new_y = sin(angle)
        
        if abs(new_x) != 1 {
            new_x *= -1
        }
        return CGSize(width: new_x, height: new_y)
    }
}
struct DeckView : View {
    @Binding var deck : Deck
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "deckblue")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 40)
        }
    }
}
struct ButtonView: View {
    var body: some View {
        VStack {
            HStack {
                Button("Hit") {
                    
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                Button("Stand") {
                    
                }
                .buttonStyle(.bordered)
                .tint(.red)
                Button("Kill Bots") {
                    
                }
                .buttonStyle(.bordered)
                .tint(.yellow)
            }
        }
    }
}
struct BetView : View {
    
    @State var amount : Double = 0
    
    let values = [1, 5, 10, 25, 100]
    
    var body: some View {
        HStack {
            ForEach(0..<5, id: \.self) { i in
                ZStack {
                    Image(uiImage: UIImage(named: "chip00" + String(i))!)
                        .onAppear() {
                        }
                    Text(String(values[i]))
                        .font(.system(size: 20, design: .serif))
                        .offset(y:-5)
                }
            }
        }
    }
}
        
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension CGSize {
    static public func *(lhs : CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}
