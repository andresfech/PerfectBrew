import SwiftUI

struct PreferenceQuestionnaireView: View {
    let coffee: Coffee
    
    @State private var bodyPreference: BodyPreference?
    @State private var acidityPreference: AcidityPreference?
    @State private var sweetnessPreference: SweetnessPreference?
    @State private var recommendationType: RecommendationType = .general
    @State private var selectedMethod: String = "V60"
    @State private var showingRecommendations = false
    @State private var builtPreferences: UserTastePreferences?
    
    @Environment(\.dismiss) var dismiss
    
    private let availableMethods = ["V60", "AeroPress", "French Press", "Chemex"]
    
    // Progress calculation
    private var completedQuestions: Int {
        var count = 0
        if bodyPreference != nil { count += 1 }
        if acidityPreference != nil { count += 1 }
        if sweetnessPreference != nil { count += 1 }
        return count
    }
    
    private var totalQuestions: Int {
        return 3 // Required questions: body, acidity, sweetness
    }
    
    private var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(completedQuestions) / Double(totalQuestions)
    }
    
    private var missingFields: [String] {
        var missing: [String] = []
        if bodyPreference == nil { missing.append("body") }
        if acidityPreference == nil { missing.append("acidity") }
        if sweetnessPreference == nil { missing.append("sweetness") }
        return missing
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                VStack(spacing: 8) {
                    // Progress Dots
                    HStack(spacing: 8) {
                        ForEach(0..<totalQuestions, id: \.self) { index in
                            Circle()
                                .fill(index < completedQuestions ? Color.orange : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: completedQuestions)
                        }
                    }
                    
                    // Progress Text
                    Text("Step \(completedQuestions) of \(totalQuestions)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))
                
                Form {
                    // Large Skip Button at the top
                    Section {
                        Button(action: {
                            builtPreferences = nil
                            showingRecommendations = true
                        }) {
                            HStack {
                                Spacer()
                                VStack(spacing: 6) {
                                    Text("Get Recommendations")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Skip preferences")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.orange)
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    
                    // Divider text
                    Section {
                        HStack {
                            Spacer()
                            Text("OR fill out preferences below")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowBackground(Color.clear)
                    
                    // Body Preference Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("body_preference_question".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(BodyPreference.allCases, id: \.self) { preference in
                                    PreferenceChip(
                                        title: preference.rawValue,
                                        isSelected: bodyPreference == preference
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            bodyPreference = preference
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Acidity Preference Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("acidity_preference_question".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(AcidityPreference.allCases, id: \.self) { preference in
                                    PreferenceChip(
                                        title: preference.rawValue,
                                        isSelected: acidityPreference == preference
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            acidityPreference = preference
                                        }
                                    }
                                }
                            }
                            
                            Text("acidity_hint".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Sweetness Preference Section (now horizontal)
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("sweetness_preference_question".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(SweetnessPreference.allCases, id: \.self) { preference in
                                    PreferenceChip(
                                        title: preference.rawValue,
                                        isSelected: sweetnessPreference == preference
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            sweetnessPreference = preference
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Recommendation Type Section
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("recommendation_type_question".localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Type", selection: $recommendationType) {
                                ForEach(RecommendationType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            if recommendationType == .methodSpecific {
                                Picker("Method", selection: $selectedMethod) {
                                    ForEach(availableMethods, id: \.self) { method in
                                        Text(method).tag(method)
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Primary CTA Button
                    Section {
                        Button(action: {
                            if let prefs = buildPreferences() {
                                builtPreferences = prefs
                                showingRecommendations = true
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text("get_recommendations_button".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                if !isComplete {
                                    Text(buttonHintText)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isComplete ? Color.orange : Color.gray.opacity(0.6))
                            .cornerRadius(12)
                        }
                        .disabled(!isComplete)
                        .animation(.easeInOut(duration: 0.2), value: isComplete)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
            .navigationTitle("preference_questionnaire_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationLink(
                    destination: RecommendationsView(
                        coffee: coffee,
                        preferences: builtPreferences
                    ),
                    isActive: $showingRecommendations
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    private var buttonHintText: String {
        if missingFields.isEmpty {
            return ""
        } else if missingFields.count == 1 {
            let field = missingFields[0]
            switch field {
            case "body":
                return "Select body preference to continue"
            case "acidity":
                return "Select acidity preference to continue"
            case "sweetness":
                return "Select sweetness preference to continue"
            default:
                return "Complete all preferences to continue"
            }
        } else {
            return "Select \(missingFields.count) more preferences to continue"
        }
    }
    
    private var isComplete: Bool {
        bodyPreference != nil &&
        acidityPreference != nil &&
        sweetnessPreference != nil
    }
    
    private func buildPreferences() -> UserTastePreferences? {
        guard let body = bodyPreference,
              let acidity = acidityPreference,
              let sweetness = sweetnessPreference else {
            return nil
        }
        
        return UserTastePreferences(
            bodyPreference: body,
            bodyTexture: nil, // Removed - redundant
            acidityPreference: acidity,
            sweetnessPreference: sweetness,
            recommendationType: recommendationType,
            selectedMethod: recommendationType == .methodSpecific ? selectedMethod : nil
        )
    }
}

struct PreferenceChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle()) // Important: prevents Form from hijacking tap
    }
}

