import SwiftUI

/// View for reviewing and editing extracted OCR data before applying to form
struct OCRReviewView: View {
    @ObservedObject var viewModel: CoffeeFormViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var editableData: ExtractedCoffeeData
    
    init(viewModel: CoffeeFormViewModel) {
        self.viewModel = viewModel
        _editableData = State(initialValue: viewModel.extractedFields ?? ExtractedCoffeeData())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Extracted Information")) {
                    if !editableData.hasAnyData {
                        Text("No information could be extracted from the image.")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        extractedFieldRow(title: "Coffee Name", value: $editableData.name)
                        extractedFieldRow(title: "Roaster", value: $editableData.roaster)
                        extractedFieldRow(title: "Country", value: $editableData.country)
                        extractedFieldRow(title: "Region", value: $editableData.region)
                        extractedFieldRow(title: "Variety", value: $editableData.variety)
                        extractedFieldRow(title: "Altitude", value: $editableData.altitude)
                        
                        if editableData.roastLevel != nil {
                            Picker("Roast Level", selection: Binding(
                                get: { editableData.roastLevel ?? .medium },
                                set: { editableData.roastLevel = $0 }
                            )) {
                                ForEach(RoastLevel.allCases) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                        }
                        
                        if editableData.process != nil {
                            Picker("Process", selection: Binding(
                                get: { editableData.process ?? .washed },
                                set: { editableData.process = $0 }
                            )) {
                                ForEach(Process.allCases) { process in
                                    Text(process.rawValue).tag(process)
                                }
                            }
                        }
                    }
                }
                
                Section(footer: Text("Review and edit the extracted information, then tap 'Use This Data' to fill the form.")) {
                    if editableData.hasAnyData {
                        Button(action: {
                            viewModel.extractedFields = editableData
                            viewModel.applyExtractedData(editableData)
                            dismiss()
                        }) {
                            HStack {
                                Spacer()
                                Text("Use This Data")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.orange)
                    }
                }
            }
            .navigationTitle("Review Extracted Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearExtractedData()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func extractedFieldRow(title: String, value: Binding<String?>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            if let currentValue = value.wrappedValue {
                TextField("", text: Binding(
                    get: { currentValue },
                    set: { value.wrappedValue = $0.isEmpty ? nil : $0 }
                ))
                .multilineTextAlignment(.trailing)
                .foregroundColor(.orange)
            } else {
                Text("Not found")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}

