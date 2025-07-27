import Foundation

struct Brew: Codable, Identifiable {
    var id = UUID()
    
    // Recipe Information
    let recipeTitle: String
    let brewingMethod: String
    
    // Brew Parameters
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval
    
    // Detailed Feedback Data
    let feedbackData: FeedbackData
    
    // Legacy fields for backward compatibility
    let tasteRating: Int
    let strengthRating: Int
    let acidityRating: Int
    let notes: String
    
    let date: Date
    
    // Custom initializer for new structure
    init(recipeTitle: String, brewingMethod: String, coffeeDose: Double, waterAmount: Double, waterTemperature: Double, grindSize: Int, brewTime: TimeInterval, feedbackData: FeedbackData, tasteRating: Int, strengthRating: Int, acidityRating: Int, notes: String, date: Date) {
        self.recipeTitle = recipeTitle
        self.brewingMethod = brewingMethod
        self.coffeeDose = coffeeDose
        self.waterAmount = waterAmount
        self.waterTemperature = waterTemperature
        self.grindSize = grindSize
        self.brewTime = brewTime
        self.feedbackData = feedbackData
        self.tasteRating = tasteRating
        self.strengthRating = strengthRating
        self.acidityRating = acidityRating
        self.notes = notes
        self.date = date
    }
    
    // Computed properties for backward compatibility
    var overallRating: Int {
        // Calculate overall rating from detailed feedback
        var totalRating = 0
        var ratingCount = 0
        
        if feedbackData.sweetnessLevel > 0 {
            totalRating += Int(feedbackData.sweetnessLevel)
            ratingCount += 1
        }
        if feedbackData.bitternessLevel > 0 {
            totalRating += Int(feedbackData.bitternessLevel)
            ratingCount += 1
        }
        if feedbackData.acidityLevel > 0 {
            totalRating += Int(feedbackData.acidityLevel)
            ratingCount += 1
        }
        
        return ratingCount > 0 ? totalRating / ratingCount : 0
    }
}
