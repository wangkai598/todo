//
//  ContentView.swift
//  TODO
//
//  Created by keven on 2024/1/18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var context

    @FetchRequest( entity: ToDoItem.entity(),
                   sortDescriptors: [ NSSortDescriptor(keyPath: \ToDoItem.priorityNum, ascending: false)])
    
    var todoItems: FetchedResults<ToDoItem>
    
    @State private var showNewTask = false
    @State private var offset: CGFloat = .zero //使用.animation 防止报错 iOS15的特性
    
    // 去掉list 背景色
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            VStack {
                TopBarMenu(showNewTask: $showNewTask)
            
                List {
                    ForEach(todoItems) {
                        todoItem in
                        ToDoListRow(todoItem: todoItem)
                    }.onDelete(perform: deleteTask)
                }
                
            }
            
            if todoItems.count == 0 {
                NoDataView()
            }
            
            if showNewTask {
                
                MaskView(bgColor: .black)
                    .opacity(0.5)
                    .onTapGesture {
                        self.showNewTask = false
                    }
                
                NewToDoView(name: "", priority: .normal, showNewTask: $showNewTask)
                    .transition(.move(edge: .bottom))
                    .animation(.interpolatingSpring(stiffness: 200.0, damping: 25.0, initialVelocity: 10.0), value: offset)
            }
        }
        
    
    }


    private func deleteTask(indexSet: IndexSet) {
        for index in indexSet {
            
            let itemToDelete = todoItems[index]
            
            context.delete(itemToDelete)
        }
        
        DispatchQueue.main.async {
            do {
                try context.save()
            }catch {
                print(error)
            }
        }
    }
    
    
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// 顶部导航栏按钮
struct TopBarMenu: View {
    
    @Binding var showNewTask: Bool
    
    var body: some View {
        HStack {
            Text("待办事项")
                .font(.system(size: 40, weight: .black))
            
            Spacer()
            
            Button(action: {
                self.showNewTask = true
                
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle).foregroundStyle(.blue)
            })
        }
        .padding()
    }
}

//NoDataView缺省页
struct NoDataView: View {
    var body: some View {
        Text ("哎呀，清单上好像还没有待办事项，有什么我可以帮助您添加的吗？")
            .padding()
            .font(.system(size: 14))
    }
}

//列表内容
struct ToDoListRow: View {
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var todoItem: ToDoItem
    
    var body: some View {
        Toggle(isOn: self.$todoItem.isCompleted) {
            HStack {
                Text(todoItem.name)
                    .strikethrough(todoItem.isCompleted, color: .black)
                    .bold()
                    .animation(.default)
                
                Spacer()
                
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(color(for: todoItem.priority))
            }
        }.toggleStyle(CheckboxStyle())
        
        //监听todoItem数组参数变化并保存
            .onReceive(todoItem.objectWillChange, perform: { _ in
                if self.context.hasChanges {
                    try? self.context.save()
                }
            })
    
    }
    
    
    //根据优先级显示不同颜色
    private func color(for priority: Priority) -> Color {
        
        switch priority {
        case .high:
            return .red
        case.normal:
            return.orange
        case .low:
            return.green
        }
    }
}

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(configuration.isOn ? .purple : .gray)
                .font(.system(size: 20, weight: .bold, design: .default))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

//蒙层
struct MaskView: View {
    
    var bgColor: Color
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(bgColor)
        .ignoresSafeArea(.all)
    }
}
