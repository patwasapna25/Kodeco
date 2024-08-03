import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

DispatchQueue.global(qos: .background).async {
    for i in 11...21 {
        print(i)
    }
}

DispatchQueue.global(qos: .userInteractive).async {
    for i in 0...10 {
        print(i)
    }
}

// we cannot predict the output of above code becuase both task are executed asynchronously on different theards, but we can say second task will finish first


// Target Queues
sleep(3)
print("============== Targey Queue ===============")
let a = DispatchQueue(label: "A")
let b = DispatchQueue(label: "B", attributes: .concurrent, target: a)

a.async {
    for i in 0...5 {
        print(i)
    }
}
a.async {
    for i in 6...10 {
        print(i)
    }
}
b.async {
    for i in 11...15 {
        print(i)
    }
}
b.async {
    for i in 16...20 {
        print(i)
    }
}
