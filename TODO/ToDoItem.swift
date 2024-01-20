//
//  ToDoItem.swift
//  TODO
//
//  Created by keven on 2024/1/18.
//

import Foundation

import CoreData

//任务紧急程度的枚举
enum Priority: Int {
    case low = 0
    case normal = 1
    case high = 2
}

public class ToDoItem: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged var name: String
    @NSManaged var priorityNum: Int32
    @NSManaged var isCompleted: Bool
}

extension ToDoItem: Identifiable {
    
    var priority: Priority {
        get {
            return Priority(rawValue: Int(priorityNum)) ?? .normal
        }
        
        set {
            self.priorityNum = Int32(newValue.rawValue)
        }
    }
}
