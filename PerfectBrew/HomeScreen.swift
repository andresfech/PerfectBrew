import SwiftUI

struct HomeScreen: View {
    @State private var selectedMethod: BrewMethod = .v60
    
    enum BrewMethod: String, CaseIterable {
        case v60 = "V60"
        case chemex = "Chemex"
        case frenchPress = "French Press"
        case aeroPress = "AeroPress"
        
        var isAvailable: Bool {
            // Enable all methods now that we have recipes
            return true
        }
        
        var icon: String {
            switch self {
            case .v60: return "drop.fill"
            case .chemex: return "hourglass"
            case .frenchPress: return "cylinder.fill"
            case .aeroPress: return "bolt.fill"
            }
        }
        
        var iconColor: Color {
            switch self {
            case .v60: return .orange
            case .chemex: return .gray
            case .frenchPress: return .red
            case .aeroPress: return .yellow
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Perfect Brew")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Craft the perfect cup")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Match My Coffee (Coffee-First)
            NavigationLink(destination: CoffeeListView()) {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Match My Coffee")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Find the perfect recipe for your beans")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(16)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(16)
                .shadow(color: Color.brown.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Brew Method")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(BrewMethod.allCases, id: \.self) { method in
                        BrewMethodCard(
                            method: method,
                            isSelected: selectedMethod == method,
                            onTap: {
                                if method.isAvailable {
                                    selectedMethod = method
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                if selectedMethod.isAvailable {
                    NavigationLink(destination: RecipeSelectionScreen(selectedMethod: selectedMethod)) {
                        Text("Start New Brew")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: BrewHistoryScreen()) {
                        Text("Brew History")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}

struct BrewMethodCard: View {
    let method: HomeScreen.BrewMethod
    let isSelected: Bool
    let onTap: () -> Void
    
    @ViewBuilder
    private func methodIcon() -> some View {
        switch method {
        case .v60:
            Image("v60_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? method.iconColor.opacity(0.1) : Color.gray.opacity(0.1))
                )
        case .chemex:
            Image("chemex")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? method.iconColor.opacity(0.1) : Color.gray.opacity(0.1))
                )
        case .aeroPress:
            Image("aeropress")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? method.iconColor.opacity(0.1) : Color.gray.opacity(0.1))
                )
        case .frenchPress:
            Image("french-press")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? method.iconColor.opacity(0.1) : Color.gray.opacity(0.1))
                )
        default:
            Image(systemName: method.icon)
                .font(.system(size: 40))
                .foregroundColor(isSelected ? method.iconColor : .gray)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? method.iconColor.opacity(0.1) : Color.gray.opacity(0.1))
                )
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                methodIcon()
                
                Text(method.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                if !method.isAvailable {
                    Text("Coming Soon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? method.iconColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? method.iconColor.opacity(0.2) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
