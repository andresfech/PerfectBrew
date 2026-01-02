import Foundation

/// Represents extracted coffee information from OCR text recognition
struct ExtractedCoffeeData {
    var name: String?
    var roaster: String?
    var country: String?
    var region: String?
    var variety: String?
    var altitude: String?
    var roastLevel: RoastLevel?
    var process: Process?
    
    /// Check if any field has been extracted
    var hasAnyData: Bool {
        name != nil || roaster != nil || country != nil || region != nil ||
        variety != nil || altitude != nil || roastLevel != nil || process != nil
    }
    
    /// Count of extracted fields
    var extractedFieldCount: Int {
        var count = 0
        if name != nil { count += 1 }
        if roaster != nil { count += 1 }
        if country != nil { count += 1 }
        if region != nil { count += 1 }
        if variety != nil { count += 1 }
        if altitude != nil { count += 1 }
        if roastLevel != nil { count += 1 }
        if process != nil { count += 1 }
        return count
    }
}

