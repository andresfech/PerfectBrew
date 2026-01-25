import SwiftUI

// MARK: - Taste Self-Assessment Guide (Phase 3)

struct TasteSelfAssessmentGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("taste_self_assess_guide".localized)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("how_to_self_assess".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("ok".localized) { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .accessibilityLabel("How to self-assess taste ratings")
    }
}

// MARK: - Exertion-Style Taste Modal (Phase 3)

/// Modal: blurred background, floating card, taste dimensions + Clear / How-to / Save / Dismiss.
/// PRD: Exertion-Style Taste Feedback UI — Phase 3.
/// 0–1 → 1–5 for expected band.
private func expected1to5(_ x: Double?) -> Double? {
    guard let x = x else { return nil }
    return x * 4 + 1
}

struct ExertionStyleTasteModal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var feedbackData: FeedbackData
    var expectedProfile: ExtractionCharacteristics?
    
    @State private var draftAcidity: Double = 3
    @State private var draftSweetness: Double = 3
    @State private var draftBody: Double = 3
    @State private var showingGuide: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("taste_profile".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        ExertionStyleTasteView(
                            id: "acidity_level",
                            dimension: "acidity_level".localized,
                            value: $draftAcidity,
                            expected: expected1to5(expectedProfile?.acidity)
                        )
                        
                        ExertionStyleTasteView(
                            id: "sweetness_level",
                            dimension: "sweetness_level".localized,
                            value: $draftSweetness,
                            expected: expected1to5(expectedProfile?.sweetness)
                        )
                        
                        ExertionStyleTasteView(
                            id: "body_level",
                            dimension: "body_mouthfeel".localized,
                            value: $draftBody,
                            expected: expected1to5(expectedProfile.map { $0.body })
                        )
                        
                        HStack(spacing: 20) {
                            Button(action: { clearAll() }) {
                                Text("clear_entry".localized)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                            }
                            .accessibilityLabel("Clear Entry")
                            .accessibilityHint("Resets acidity, sweetness, and body to middle (3)")
                            .frame(minWidth: 44, minHeight: 44)
                            
                            Button(action: { showingGuide = true }) {
                                HStack(spacing: 4) {
                                    Text("how_to_self_assess".localized)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            .accessibilityLabel("How to Self-Assess")
                            .accessibilityHint("Opens guidance on rating taste")
                            .frame(minHeight: 44)
                        }
                        
                        Button(action: saveAndDismiss) {
                            VStack(spacing: 4) {
                                Text("save".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("save_taste_subtitle".localized)
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        .accessibilityLabel("Save taste ratings")
                        .accessibilityHint("Saves your taste ratings and closes")
                        .padding(.top, 8)
                        
                        Button(action: { dismiss() }) {
                            Text("dismiss".localized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .accessibilityLabel("Dismiss")
                        .accessibilityHint("Closes without saving")
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 40)
                }
            }
        }
        .onAppear {
            draftAcidity = feedbackData.acidityLevel
            draftSweetness = feedbackData.sweetnessLevel
            draftBody = feedbackData.bodyLevel
        }
        .sheet(isPresented: $showingGuide) {
            TasteSelfAssessmentGuideView()
        }
    }
    
    private func clearAll() {
        draftAcidity = 3
        draftSweetness = 3
        draftBody = 3
    }
    
    private func saveAndDismiss() {
        feedbackData.acidityLevel = draftAcidity
        feedbackData.sweetnessLevel = draftSweetness
        feedbackData.bodyLevel = draftBody
        dismiss()
    }
}

#Preview("ExertionStyleTasteModal") {
    struct PreviewWrapper: View {
        @State var data = FeedbackData()
        var body: some View {
            ExertionStyleTasteModal(
                feedbackData: $data,
                expectedProfile: ExtractionCharacteristics(
                    clarity: 0.5,
                    acidity: 0.6,
                    sweetness: 0.55,
                    body: 0.5
                )
            )
        }
    }
    return PreviewWrapper()
}
