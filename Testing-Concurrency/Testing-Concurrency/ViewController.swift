//
//  ViewController.swift
//  Testing-Concurrency
//
//  Created by OrangeOu on 6/16/24.
//

import UIKit

enum MyError: Error {
    case error1, error2
}

class MyArray<T> {
    let serialQueue = DispatchQueue(label: "serialQueue")
    private var myArray = [T]()
    
    public func appendElement(_ element: T) {
        serialQueue.sync {
            myArray.append(element)
        }
    }
    
    public func currentSize() -> Int {
        return myArray.count
    }
    
    public func getAt(_ index: Int) -> T {
        return myArray[index]
    }
    
    public func remove(at index: Int) -> T {
        return myArray.remove(at: index)
    }
}

struct MyStruct1 {
    var completion: (() -> Void)?
    func execute() {
        completion?()
    }
}

@MainActor
struct TimeConsumingProcessor {
    func syncProcessData(_ imageData: Data) -> UIImage {
        print(#function, "started", Thread.isMainThread, Thread.current)
        Thread.sleep(forTimeInterval: 10) // simulates a blocking operation
        print(#function, "finished", Thread.isMainThread, Thread.current)
        return UIImage(systemName: "sun.max")!
    }

    func process(_ imageData: Data) async -> UIImage? {
        print(#function, Thread.isMainThread, Thread.current)
//        let image = await Task {
//            syncProcessData(imageData)
//        }.value
        print(#function, Thread.isMainThread, Thread.current)
        return nil
    }
}

class ViewController: UIViewController {
    //MARK: Property
    var myArray = MyArray<Int>()
    
    let concurrentQueue = DispatchQueue(label: "com.example.concurrentQueue", attributes: .concurrent)
    let myGroup = DispatchGroup()


    //MARK: Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        test00001()
//        test0002()
        test0003()
    }
    
    func test0003() {
//        let task = Task { () -> String in
//            print("Starting: \(Thread.current)")
//            try await Task.sleep(nanoseconds: 1_000_000_000)
//            try Task.checkCancellation()
//            return "Done"
//        }
        
//        Task(priority: .background) {
//            do {
////                sleep(2)
////                let result = try await task.value
////                print("\(result), \(Thread.current)")
//                try await mimicRequestRemoteData()
//            } catch {
//                print("Task was cancelled.")
//            }
//        }
        
        
        let imageProcessor = TimeConsumingProcessor()
        
        @Sendable func process(_ imageData: Data) async -> UIImage? {
            print(#function, Thread.isMainThread, Thread.current)
    //        let image = await Task {
    //            syncProcessData(imageData)
    //        }.value
            print(#function, Thread.isMainThread, Thread.current)
            return nil
        }

        
        func applyEffectsToImage() {
            print(#function, Thread.isMainThread, Thread.current)
            Task.detached {
                print(#function, Thread.isMainThread, Thread.current)
                let imageData = Data()
                let tmp = await imageProcessor.process(imageData)
//                let _ = await process(imageData)
            }
        }
        
        applyEffectsToImage()

    }
    
    func mimicRequestRemoteData() async throws {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        print("Thread: \(Thread.current)")
    }

    func test00001() {
        test0001Sub()
        
        func test0001Sub() {
            for i in 0...1000 {
                concurrentQueue.async(group: myGroup) {
                    self.myArray.appendElement(i)
                }
            }
        }
        
        myGroup.wait()
        print(myArray.currentSize())
    }
    
    func test0002() {
//        func deferTask(task: @escaping () -> ()) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                task()
//            }
//        }
//        deferTask {
//            print("Defer task")
//        }
        let obj = MyStruct1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                print("Defer task")
            }
        }
        obj.execute()
    }
    
}

