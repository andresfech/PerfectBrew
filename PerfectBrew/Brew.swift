import Foundation

struct Brew: Codable, Identifiable {
    var id = UUID()
    let coffeeDose: Double
    let waterAmount: Double
    let waterTemperature: Double
    let grindSize: Int
    let brewTime: TimeInterval
    let tasteRating: Int
    let strengthRating: Int
    let acidityRating: Int
    let notes: String
    let date: Date
}
