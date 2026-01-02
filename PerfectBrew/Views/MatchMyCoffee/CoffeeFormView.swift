import SwiftUI
import UIKit

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
                    // Scan Label button
                    Button(action: {
                        viewModel.showingCameraPicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.orange)
                            Text("Scan Label")
                                .foregroundColor(.orange)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    TextField("Coffee Name", text: $viewModel.name)
                    TextField("Roaster", text: $viewModel.roaster)
                }
                
                Section(header: Text("Origin")) {
                    TextField("Country (e.g. Ethiopia)", text: $viewModel.country)
                    TextField("Region (e.g. Yirgacheffe)", text: $viewModel.region)
                    TextField("Altitude (e.g. 2000m)", text: $viewModel.altitude)
                        .keyboardType(.numbersAndPunctuation)
                }
                
                Section(header: Text("Bean Info")) {
                    TextField("Variety (e.g. Geisha)", text: $viewModel.variety)
                    
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
                
                Section(header: Text("Roast Date")) {
                    Toggle("Include Roast Date", isOn: $viewModel.hasRoastDate)
                    if viewModel.hasRoastDate {
                        DatePicker("Date", selection: $viewModel.roastDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Flavor Tags")) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search or create tag...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.vertical, 5)
                    
                    // Create custom tag button (if search doesn't match existing)
                    if viewModel.canCreateCustomTag {
                        Button(action: {
                            viewModel.createCustomTag(viewModel.searchText)
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create '\(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines))'")
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.bottom, 5)
                    }
                    
                    // Filtered predefined tags
                    if !viewModel.filteredFlavorTags.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(viewModel.filteredFlavorTags) { tag in
                                FlavorTagButton(
                                    tag: tag,
                                    isSelected: viewModel.selectedFlavorTags.contains(tag)
                                ) {
                                    viewModel.toggleFlavorTag(tag)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    } else if !viewModel.searchText.isEmpty {
                        Text("No tags found matching '\(viewModel.searchText)'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 10)
                    }
                    
                    // Selected custom tags
                    if !viewModel.selectedCustomTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Tags")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 10)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(Array(viewModel.selectedCustomTags), id: \.self) { customTag in
                                    CustomFlavorTagButton(
                                        tag: customTag,
                                        isSelected: true
                                    ) {
                                        viewModel.toggleCustomTag(customTag)
                                    }
                                }
                            }
                        }
                    }
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
            .sheet(isPresented: $viewModel.showingCameraPicker) {
                CoffeeLabelScannerView(isPresented: $viewModel.showingCameraPicker) { image in
                    viewModel.processImageWithOCR(image)
                }
            }
            .sheet(isPresented: $viewModel.showingOCRReview) {
                if let extractedData = viewModel.extractedFields {
                    OCRReviewView(viewModel: viewModel)
                }
            }
            .overlay {
                if viewModel.isProcessingOCR {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Extracting text...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
            }
            .alert("OCR Error", isPresented: $viewModel.showingOCRError) {
                Button("OK") {
                    viewModel.ocrError = nil
                }
            } message: {
                Text(viewModel.ocrError ?? "An error occurred while processing the image.")
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

struct CustomFlavorTagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(tag)
                    .font(.caption)
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1)
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
