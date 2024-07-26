/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Memento
 - - - - - - - - - -
 ![Memento Diagram](Memento_Diagram.png)
 
 The memento pattern allows an object to be saved and restored. It involves three parts:
 
 (1) The **originator** is the object to be saved or restored.
 
 (2) The **memento** is a stored state.
 
 (3) The **caretaker** requests a save from the originator, and it receives a memento in response. The care taker is responsible for persisting the memento, so later on, the care taker can provide the memento back to the originator to request the originator restore its state.
 
 ## Code Example
 */

import UIKit

// Originator
class Game: Codable {
    class State: Codable {
        public var attemptsRemaining = 3
        public var level = 1
        public var score = 0
    }
    
    public var state = State()
    
    public func rackUpMassivePoints() {
        state.score += 9002
    }
    
    func monstersEatPlayer() {
        state.attemptsRemaining -= 1    
    }
}

// Momento
typealias GameMemento = Data

// Care taker
class GameSystem {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    private let userDefaults = UserDefaults.standard
    
    func save(_ game: Game, title: String) throws {
        let data = try encoder.encode(game)
        userDefaults.set(data, forKey: title)
    }
    
    func load(title: String) throws -> Game {
        guard let data = userDefaults.data(forKey: title), let game = try? decoder.decode(Game.self, from: data) else {
            return Error.gameNotFound as! Game
        }
        return game
    }
    
    public enum Error: String, Swift.Error {
        case gameNotFound
    }
}

//Example

var game = Game()
game.monstersEatPlayer()
game.rackUpMassivePoints()

//Save game
let gameSystem = GameSystem()
try gameSystem.save(game, title: "Best Game Ever")

// new game
game = Game()
print("New Game score: \(game.state.score)")

// load game
game = try! gameSystem.load(title: "Best Game Ever")
print("Loaded game score: \(game.state.score)")
