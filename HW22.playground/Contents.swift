import Foundation

var lifoStack = Array<Chip>()
let cond = NSCondition()
var isEmptyStack = true

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    public let chipType: ChipType

    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        print ("\nЧип создан")
        return Chip(chipType: chipType)
    }

    public func soldering() {
        let solderingTime = chipType.rawValue
        sleep(UInt32(solderingTime))
        print ("Чип запаян \(lifoStack.compactMap{ $0.chipType.rawValue })")
    }
}

var createThread = Thread {
    for _ in 1...10 {
        cond.lock()
        lifoStack.insert(Chip.make(), at: 0)
        print ("Чип добавлен в стек \(lifoStack.compactMap{ $0.chipType.rawValue })")
        
        isEmptyStack = false
        cond.signal()
        cond.unlock()
        sleep(2)
    }
}


