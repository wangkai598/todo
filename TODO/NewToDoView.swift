//
//  NewToDoView.swift
//  TODO
//
//  Created by keven on 2024/1/19.
//

import SwiftUI

struct NewToDoView: View {

    
    @State var name: String
    @State var isEditing = false
    @State var priority: Priority
    @Binding var showNewTask: Bool
    
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack {
                TopNavBar(showNewTask: $showNewTask)
                InputNameView(name: $name, isEditing: $isEditing)
                PrioritySelectView(priority: $priority)
                SaveButtioon(name: $name, showNewTask: $showNewTask, priority: $priority)
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .clipped(antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            .offset(y: isEditing ? -320 : 0)
        }.ignoresSafeArea(.all)
       

    }
}

#Preview {
    NewToDoView(name: "", priority: .normal, showNewTask: .constant(true))
}

//顶部导航栏
struct TopNavBar: View {
    
    @Binding var showNewTask: Bool
    
    var body: some View {
        HStack {
            Text("新建事项")
                .font(.system(.title))
                .bold()
            
            Spacer()
            
            Button(action: {
                self.showNewTask = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.title)
            }
            
        }
    }
}

//InputNameView输入框视图
struct InputNameView: View {
    @Binding var name: String
    @Binding var isEditing: Bool
    
    var body: some View {
        
        TextField("请输入", text: $name) { (editingChanged) in
            
            self.isEditing = editingChanged
            
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.bottom)
    }
}

//选择优先级
struct PrioritySelectView: View {
    
    @Binding var priority: Priority
    
    var body: some View {
        
        HStack {
            PrioritySelectRow(name: "高", color: priority == .high ? .red : Color(.systemGray4))
                .onTapGesture { self.priority = .high }
            
            PrioritySelectRow(name: "中", color: priority == .normal ? .orange : Color(.systemGray4))
                .onTapGesture {
                    self.priority = .normal
                }
            
            PrioritySelectRow(name: "低", color: priority == .low ? .green : Color(.systemGray4))
                .onTapGesture {
                    self.priority = .low
                }
        }
    }
}

//选择优先级
struct PrioritySelectRow: View {
    
    var name: String
    var color: Color
    
    var body: some View {
        
        Text(name)
            .frame(width: 80)
            .font(.system(.headline))
            .padding(10)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
}

// 保存按钮
struct SaveButtioon: View {
    
    @Binding var name: String
    @Binding var showNewTask: Bool

    @Binding var priority: Priority
    
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        
        Button(action: {
             
            //判断输入框是否为空
            if self.name.trimmingCharacters(in: .whitespaces) == "" {
                 return
            }
            
            //添加一条数据
            self.addTask(name: self.name, priority: self.priority)
            // 关闭弹框
            self.showNewTask = false
        }) {
            
            Text("保存")
                .font(.system(.headline))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding([.top, .bottom])
    }
    
    //添加新事项方法
    private func addTask(name: String, priority: Priority, isCompleted: Bool = false) {
        
        let task = ToDoItem(context: context)
        task.id = UUID()
        task.name = name
        task.priority = priority
        task.isCompleted = isCompleted
        
        do {
            try context.save()
        }catch {
            print(error)
        }
    }
}
