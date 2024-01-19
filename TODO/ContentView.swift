//
//  ContentView.swift
//  TODO
//
//  Created by keven on 2024/1/18.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State var todoItems: [ToDoItem] = []
    
    // 去掉list 背景色
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            VStack {
                TopBarMenu()
                ToDoListView(todoItems: $todoItems)
                
            }
            
            if todoItems.count == 0 {
                NoDataView()
            }
        }
    
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
 
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// 顶部导航栏按钮
struct TopBarMenu: View {
    var body: some View {
        HStack {
            Text("待办事项")
                .font(.system(size: 40, weight: .black))
            
            Spacer()
            
            Button(action: {
                
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
        Image("image1")
            .resizable()
            .scaledToFit()
            .padding()
    }
}

//列表
struct ToDoListView: View {
    
    @Binding var todoItems: [ToDoItem]
    
    var body: some View {
        List {
            ForEach(todoItems) { todoItem in
                ToDoListRow(todoItem: todoItem)
                
            }
        }
    }
}

//列表内容
struct ToDoListRow: View {
    
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

