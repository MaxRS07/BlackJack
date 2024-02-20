import Foundation
import SwiftUI

public class Deck : CustomStringConvertible {
    
    public var description: String {
        return (Cards.map { $0.description }).joined(separator: ", ")
    }
    
    public var Cards : [Card] = []
    
    public func Shuffle() {
        Cards.shuffle()
    }
    public init (numdecks: Int) {
        for i in 0..<numdecks {
            for i in 0..<4 {
                let this = Suites[i]
                Cards.append(Card(face: "ace", suit: this))
                for i in 2...10 {
                    Cards.append(Card(face: String(i), suit: this))
                }
                Cards.append(Card(face: "jack", suit: this))
                Cards.append(Card(face: "queen", suit: this))
                Cards.append(Card(face: "king", suit: this))
            }
        }
    }
    public func deal(num : Int = 1) -> [Card] {
        var a : [Card] = []
        
        if Cards.isEmpty { return a }
        
        for _ in 0..<num {
            if let b = Cards.randomElement() {
                if let c = Cards.firstIndex(where: {$0 == b}) {
                    Cards.remove(at: c)
                }
                a.append(b)
            } else {
                return a
            }
        }
        return a
    }
}
public class Card : CustomStringConvertible, Equatable {
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.face == rhs.face && lhs.suit == rhs.suit
    }
    
    public var description: String {
        return "(" + face + ", " + suit.rawValue + ")"
    }
    public var intify : Int {
        if let thwang = Int(self.face) {
            return thwang
        }
        if self.face == "ace" {
            return 1
        }
        return 10
    }
    
    public var suit : Suit
    public var face : String
    
    public init(face : String, suit: Suit) {
        self.suit = suit
        self.face = face
    }
    public func image() -> UIImage {
        var ext = face
        if let post = Int(face) {
            ext = "00" + String(post - 1)
        } else {
            switch ext {
            case "jack":
                ext = "010"
                break
            case "queen":
                ext = "011"
                break
            case "king":
                ext = "012"
                break
            default:
                ext = "000"
            }
        }
        return UIImage(named: self.suit.rawValue.lowercased() + ext)!
    }
}
public enum Suit : String  {
    case Hearts = "Hearts"
    case Clubs = "Clubs"
    case Spades = "Spades"
    case Diamonds = "Diamonds"
}
public var Suites : [Suit] = [.Hearts, .Clubs, .Diamonds, .Spades]

extension Array where Element : CustomStringConvertible {
    public func join(seperator: String) -> String {
        return self.map{$0.description}.join(seperator: seperator)
    }
}

public struct Player {
    public var name : String
    public var image : UIImage?
    public var cash : Double
    public var hand : [Card]
    
    public init(cash: Double = 0, hand: [Card] = [], name: String = "", image: UIImage? = nil) {
        self.cash = cash
        self.hand = hand
        if name != "" {
            self.name = name
        } else {
            self.name = Eli.Adrian()
        }
        self.image = image
    }
}
public extension Player {
    func total() -> Int {
        return self.hand.reduce(0, {x, y in x + y.intify})
    }
    func turn(dealer: Int) -> Actions {
        let hardhands : [[Int]] = [
            [1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,0,0,0,0,0],
            [1,1,1,1,1,0,0,0,0,0],
            [1,1,1,1,1,0,0,0,0,0],
            [1,1,1,1,1,0,0,0,0,0],
            [0,0,1,1,1,0,0,0,0,0],
            [2,2,2,2,2,2,2,2,2,2],
            [2,2,2,2,2,2,2,2,0,0],
            [0,2,2,2,2,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0],
        ]
        let softhands : [[Int]] = [
            [1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,2,1,1,1,1,1],
            [2,2,2,2,2,1,1,0,0,0],
            [0,2,2,2,2,0,0,0,0,0],
            [0,0,2,2,2,0,0,0,0,0],
            [0,0,2,2,2,0,0,0,0,0],
            [0,0,0,2,2,0,0,0,0,0],
            [0,0,0,2,2,0,0,0,0,0],
        ]
        let pairs : [[Int]] = [
        ]
        func index(_ index: Int) -> Actions {
            switch index {
            case 0:
                return .Hit
            case 1:
                return .Stand
            case 2:
                return .Double
            default:
                return .Split
            }
        }
        var wrap = dealer - 2
        if wrap < 0 {wrap = 9}
        let number = hardhands[self.total()-5][wrap]
        return index(number)
    }
}
