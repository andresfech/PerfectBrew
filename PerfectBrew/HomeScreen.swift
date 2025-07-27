import SwiftUI

struct HomeScreen: View {
    @State private var selectedMethod: BrewMethod = .v60
    
    enum BrewMethod: String, CaseIterable {
        case v60 = "V60"
        case chemex = "Chemex"
        case frenchPress = "French Press"
        case aeroPress = "AeroPress"
        
        var isAvailable: Bool {
            return self == .v60
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
        NavigationView {
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
                        NavigationLink(destination: BrewSetupScreen()) {
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
            .navigationBarHidden(true)
        }
    }
}

struct BrewMethodCard: View {
    let method: HomeScreen.BrewMethod
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: method.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? method.iconColor : .gray)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? method.iconColor.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                
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
