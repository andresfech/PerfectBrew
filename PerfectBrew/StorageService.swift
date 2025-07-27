import Foundation
import SwiftUI

class StorageService: ObservableObject {
    @AppStorage("brews") private var brewData: Data?
    @AppStorage("detailed_feedback") private var detailedFeedbackData: Data?

    func saveBrews(_ brews: [Brew]) {
        if let encoded = try? JSONEncoder().encode(brews) {
            brewData = encoded
        }
    }

    func loadBrews() -> [Brew] {
        if let data = brewData,
           let decoded = try? JSONDecoder().decode([Brew].self, from: data) {
            return decoded
        }
        return []
    }
    
    func saveBrew(_ brew: Brew) {
        var brews = loadBrews()
        brews.append(brew)
        saveBrews(brews)
    }
    
    func saveDetailedFeedback(_ feedback: DetailedBrewFeedback) {
        var feedbacks = loadDetailedFeedback()
        feedbacks.append(feedback)
        if let encoded = try? JSONEncoder().encode(feedbacks) {
            detailedFeedbackData = encoded
        }
    }
    
    func loadDetailedFeedback() -> [DetailedBrewFeedback] {
        if let data = detailedFeedbackData,
           let decoded = try? JSONDecoder().decode([DetailedBrewFeedback].self, from: data) {
            return decoded
        }
        return []
    }
}
