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
    
    // New Fields for AEC-11 Smart Feedback
    var coffeeID: UUID?
    var defect: String?
    var adjustment: String?
    
    // Legacy fields for backward compatibility
    let tasteRating: Int
    let strengthRating: Int
    let acidityRating: Int
    let notes: String
    
    let date: Date
    
    // Custom initializer for new structure
    init(recipeTitle: String, brewingMethod: String, coffeeDose: Double, waterAmount: Double, waterTemperature: Double, grindSize: Int, brewTime: TimeInterval, feedbackData: FeedbackData, tasteRating: Int, strengthRating: Int, acidityRating: Int, notes: String, date: Date, coffeeID: UUID? = nil, defect: String? = nil, adjustment: String? = nil) {
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
        self.coffeeID = coffeeID
        self.defect = defect
        self.adjustment = adjustment
    }
    
    // Computed property for overall rating
    var overallRating: Int {
        return Int(feedbackData.overallRating)
    }
}
