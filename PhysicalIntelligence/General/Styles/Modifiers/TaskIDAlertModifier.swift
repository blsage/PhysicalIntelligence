//
//  TaskIDAlertModifier.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import SwiftUI

struct TaskIDAlertModifier: ViewModifier {
    @Environment(\.model) var model

    @State private var taskID = ""

    func body(content: Content) -> some View {
        @Bindable var model = model

        content
            .alert("Task ID", isPresented: $model.showSetTaskIDAlert) {
                textField
                Button("Record") {
                    model.taskID = taskID.lowercased()
                    model.tryStartRecording()
                }
            } message: {
                Text("Name this task.")
            }
            .alert("Task ID", isPresented: $model.showEditTaskIDAlert) {
                textField
                Button("Done") {
                    model.taskID = taskID.lowercased()
                }
            } message: {
                Text("Edit your Task ID.")
            }
    }

    var textField: some View {
        TextField("put_away_dishes", text: $taskID)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
}

extension View {
    func taskIDAlert() -> some View {
        modifier(TaskIDAlertModifier())
    }
}
