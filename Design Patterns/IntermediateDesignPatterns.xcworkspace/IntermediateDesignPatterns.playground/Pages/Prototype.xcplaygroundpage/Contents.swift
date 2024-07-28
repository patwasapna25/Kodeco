/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Prototype
 - - - - - - - - - -
 ![Prototype Diagram](Prototype_Diagram.png)
 
 The prototype pattern is a creational pattern that allows an object to copy itself. It involves two types:
 
 1. A **copying** protocol declares copy methods.
 
 2. A **prototype** is a class that conforms to the copying protocol.
 
 ## Code Example
 */
public protocol Copying: AnyObject {
    init(_ prototype: Self)
}

extension Copying {
    public func copy() -> Self {
        return type(of: self).init(self)
    }
}

public class Monster: Copying {
    public var health: Int
    public var level: Int
    
    init(health: Int, level: Int) {
        self.health = health
        self.level = level
    }
    
    required convenience public init(_ prototype: Monster) {
        self.init(health: prototype.health, level: prototype.level)
    }
}

public class EyeballMonster: Monster {
    public var redness = 0
    override convenience init(health: Int, level: Int) {
        self.init(health: health, level: level, redness: 0)
    }
    
    init(health: Int, level: Int, redness: Int) {
        self.redness
        super.init(health: health, level: level)
    }
    
    @available(*, unavailable, message: "Call copy() instead")
    public required convenience init(_ prototype: Monster) {
        let eyeballMonster = prototype as! EyeballMonster
        self.init(health: eyeballMonster.health, level: eyeballMonster.level, redness: eyeballMonster.redness)
    }
}

let monster = Monster(health: 700, level: 37)
let monster2 = monster.copy()
print(monster2.level)

let eyeball = EyeballMonster(health: 3002, level: 32, redness: 33)
let eyeball2 = eyeball.copy()
print(eyeball2.level)
