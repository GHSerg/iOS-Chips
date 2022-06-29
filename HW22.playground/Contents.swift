import Foundation


// решение 1

import Foundation

struct Chip {
    enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }

    let chipType: ChipType

    static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        return Chip(chipType: chipType)
    }

    func soldering() {
        let solderingTime = chipType.rawValue
        sleep(UInt32(solderingTime))
    }
}

class ChipStorage {

    private var stack = [Chip]()
    private let concurrentQueue = DispatchQueue(label: "concurrent-queue", qos: .utility, attributes: .concurrent)
    var count: Int { stack.count }

    func addChip(_ chip: Chip) {
        concurrentQueue.async(flags: .barrier) { [unowned self] in
            self.stack.append(chip)
            print ("Чип \(chip.chipType.rawValue) добавлен в коробку. Чипы в коробке: \(getAllChips())")
        }
    }

    func grabChip() -> Chip? {
        var chip: Chip?
        concurrentQueue.sync { [unowned self] in
            guard let grabbedChip = self.stack.popLast() else { return }
            chip = grabbedChip
            print("Чип \(grabbedChip.chipType.rawValue) взят из коробки. Оставшиеся чипы: \(getAllChips())")
        }
        return chip
    }

    func getAllChips() -> [UInt32] {
        stack.compactMap { $0.chipType.rawValue }
    }
}

class WorkingThread: Thread {

    private var stack: ChipStorage
    private let needChipsCount: Int
    private let interval: Double

    init(stack: ChipStorage, count: Int = 10, interval: Double = 2) {
        self.stack = stack
        needChipsCount = count
        self.interval = interval
    }

    override func main() {
        for _ in 1...needChipsCount {
            let chip = createChip()
            stack.addChip(chip)
            Thread.sleep(forTimeInterval: interval)
        }
        cancel()
        print("WorkingThread завершен")
    }

    private func createChip() -> Chip {
        let chip = Chip.make()
        print("\nЧип \(chip.chipType.rawValue) создан. Чипы в коробке: \(stack.getAllChips())")
        return chip
    }
}

class SolderThread: Thread {

    private var stack: ChipStorage
    
    init(stack: ChipStorage) { self.stack = stack }

    override func main() {
        while stack.count > 0 || !workingThread.isCancelled {
            doWork()
        }
        cancel()
        print("SolderThread завершен")
    }

    private func doWork() {
        guard let chip = stack.grabChip() else { return }
        solderChip(chip)
    }

    private func solderChip(_ chip: Chip) {
        chip.soldering()
        print ("Чип \(chip.chipType.rawValue) запаян. Оставшиеся чипы: \(stack.getAllChips())")
    }
}

let stack = ChipStorage()
let workingThread = WorkingThread(stack: stack, interval: 1)
let solderThread = SolderThread(stack: stack)
workingThread.start()
solderThread.start()

// решение 2

//var lifoStack = Array<Chip>()
//let cond = NSCondition()
//var isEmptyStack = true
//
//public struct Chip {
//    public enum ChipType: UInt32 {
//        case small = 1
//        case medium
//        case big
//    }
//
//    public let chipType: ChipType
//
//    public static func make() -> Chip {
//        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
//            fatalError("Incorrect random value")
//        }
//        print ("\nЧип создан")
//        return Chip(chipType: chipType)
//    }
//
//    public func soldering() {
//        let solderingTime = chipType.rawValue
//        sleep(UInt32(solderingTime))
//        print ("Чип запаян \(lifoStack.compactMap{ $0.chipType.rawValue })")
//    }
//}
//
//var createThread = Thread {
//    for _ in 1...10 {
//        cond.lock()
//        lifoStack.insert(Chip.make(), at: 0)
//        print ("Чип добавлен в стек \(lifoStack.compactMap{ $0.chipType.rawValue })")
//        
//        isEmptyStack = false
//        cond.signal()
//        cond.unlock()
//        sleep(2)
//    }
//}
//
//var solderThread = Thread {
//    for _ in 1...10 {
//        while isEmptyStack {
//            cond.wait()
//        }
//        
//        lifoStack.removeFirst().soldering()
//        if lifoStack.count < 1 {
//            isEmptyStack = true
//        }
//    }
//}
//
//createThread.start()
//solderThread.start()

