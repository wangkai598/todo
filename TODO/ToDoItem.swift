//
//  ToDoItem.swift
//  TODO
//
//  Created by keven on 2024/1/18.
//

import Foundation

//任务紧急程度的枚举
enum Priority: Int {
    case low = 0
    case normal = 1
    case high = 2
}

class ToDoItem: ObservableObject, Identifiable {
    var id = UUID()
    @Published var name: String = ""
    @Published var priority: Priority = .high
    @Published var isCompleted: Bool = false
    
    //实例化
    init(name: String, priority: Priority = .normal, isCompleted: Bool = false) {
        self.name = name
        self.priority = priority
        self.isCompleted = isCompleted
    }
    
}
