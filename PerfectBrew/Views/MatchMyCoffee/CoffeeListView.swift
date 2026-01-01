import SwiftUI

struct CoffeeListView: View {
    @StateObject private var viewModel = CoffeeListViewModel()
    @State private var showingAddSheet = false
    @State private var coffeeToEdit: Coffee?
    
    var body: some View {
        List {
            ForEach(viewModel.coffees) { coffee in
                // Navigation to Recommendations
                NavigationLink(destination: RecommendationsView(coffee: coffee)) {
                    CoffeeRow(coffee: coffee) {
                        coffeeToEdit = coffee
                    }
                }
            }
            .onDelete(perform: viewModel.delete)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("My Coffees")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CoffeeFormView()
        }
        .sheet(item: $coffeeToEdit) { coffee in
            CoffeeFormView(coffeeToEdit: coffee)
        }
        .overlay(
            Group {
                if viewModel.coffees.isEmpty {
                    ContentUnavailableView(
                        "No Coffees Yet",
                        systemImage: "cup.and.saucer",
                        description: Text("Add your coffee beans to get personalized recipe recommendations.")
                    )
                }
            }
        )
    }
}

struct CoffeeRow: View {
    let coffee: Coffee
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(coffee.name)
                    .font(.headline)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle()) // Prevent list row selection hijack
            }
            
            // Roaster & Origin
            if !coffee.roaster.isEmpty || !coffee.country.isEmpty {
                HStack(spacing: 4) {
                    if !coffee.roaster.isEmpty {
                        Text(coffee.roaster)
                            .fontWeight(.medium)
                    }
                    if !coffee.roaster.isEmpty && !coffee.country.isEmpty {
                        Text("•")
                    }
                    if !coffee.country.isEmpty {
                        Text(coffee.country)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            // Badges
            HStack(spacing: 8) {
                Text(coffee.roastLevel.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.brown.opacity(0.2))
                    .cornerRadius(4)
                
                Text(coffee.process.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
                
                // Show first couple of tags (predefined + custom)
                let allTags = coffee.allFlavorTagStrings
                ForEach(Array(allTags.prefix(2)), id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if allTags.count > 2 {
                    Text("+\(allTags.count - 2)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 2)
            
            // Roast Date (if available)
            if let date = coffee.roastDate {
                Text("Roasted: \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CoffeeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoffeeListView()
        }
    }
}
