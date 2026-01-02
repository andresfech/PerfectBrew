import Foundation
import UIKit
import Vision

/// Service for extracting text from images using Vision framework OCR
class OCRService {
    static let shared = OCRService()
    
    private init() {}
    
    /// Extract text from an image using Vision framework OCR
    /// - Parameters:
    ///   - image: The UIImage to process
    /// - Returns: Extracted text as a single string
    /// - Throws: OCRServiceError if processing fails
    func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRServiceError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRServiceError.processingFailed(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRServiceError.noTextFound)
                    return
                }
                
                var extractedStrings: [String] = []
                
                for observation in observations {
                    guard let topCandidate = observation.topCandidates(1).first else {
                        continue
                    }
                    extractedStrings.append(topCandidate.string)
                }
                
                if extractedStrings.isEmpty {
                    continuation.resume(throwing: OCRServiceError.noTextFound)
                } else {
                    // Join all extracted text blocks with newlines
                    let fullText = extractedStrings.joined(separator: "\n")
                    continuation.resume(returning: fullText)
                }
            }
            
            // Configure for both English and Spanish, accurate recognition
            request.recognitionLanguages = ["en-US", "es-ES"]
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRServiceError.processingFailed(error))
            }
        }
    }
}

enum OCRServiceError: LocalizedError {
    case invalidImage
    case noTextFound
    case processingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided"
        case .noTextFound:
            return "No text found in image"
        case .processingFailed(let error):
            return "Failed to process image: \(error.localizedDescription)"
        }
    }
}

