import SwiftUI

struct CoffeeFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: CoffeeFormViewModel
    
    // Initializer to allow injecting an existing coffee for editing
    init(coffeeToEdit: Coffee? = nil) {
        _viewModel = StateObject(wrappedValue: CoffeeFormViewModel(coffeeToEdit: coffeeToEdit))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Coffee Name", text: $viewModel.name)
                    TextField("Roaster", text: $viewModel.roaster)
                }
                
                Section(header: Text("Profile")) {
                    Picker("Roast Level", selection: $viewModel.roastLevel) {
                        ForEach(RoastLevel.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Process", selection: $viewModel.process) {
                        ForEach(Process.allCases) { process in
                            Text(process.rawValue).tag(process)
                        }
                    }
                }
                
                Section(header: Text("Flavor Tags")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(FlavorTag.allCases) { tag in
                            FlavorTagButton(
                                tag: tag,
                                isSelected: viewModel.selectedFlavorTags.contains(tag)
                            ) {
                                viewModel.toggleFlavorTag(tag)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Coffee" : "Add Coffee")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

struct FlavorTagButton: View {
    let tag: FlavorTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CoffeeFormView_Previews: PreviewProvider {
    static var previews: some View {
        CoffeeFormView()
    }
}

