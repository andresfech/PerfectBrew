# OCR Coffee Bag Scanner - Implementation Plan

## 📊 PRD Review & Completeness Score

### Completeness Score: **8.5/10**

**Strengths:**
- ✅ Clear goals and non-goals
- ✅ Comprehensive Gherkin stories
- ✅ Well-defined functional requirements
- ✅ Architecture alignment with MVVM pattern
- ✅ Proper file structure
- ✅ State management defined

**Gaps Identified:**
- ⚠️ Missing specific Info.plist configuration steps (project uses GENERATE_INFOPLIST_FILE = YES)
- ⚠️ Text parsing heuristics need more detail (country/region/variety detection patterns)
- ⚠️ Error handling edge cases (low light, blurry images, no text found)
- ⚠️ Localization support for OCR UI strings
- ⚠️ Permission state management details

### PerfectBrew Consistency Check: ✅ PASS
- Follows MVVM pattern (CoffeeFormViewModel)
- Uses @Published properties for state
- Uses .sheet() for modal presentations (consistent with FeedbackScreen pattern)
- Follows SwiftUI best practices
- Matches existing service architecture (singleton pattern like AudioService)

---

## 🚀 Executable Implementation Plan

### Phase 1: Foundation & Permissions
- [ ] **Task 1**: Add Info.plist keys via build settings (INFOPLIST_KEY_NSCameraUsageDescription and INFOPLIST_KEY_NSPhotoLibraryUsageDescription) since project uses GENERATE_INFOPLIST_FILE
- [ ] **Task 2**: Create ExtractedCoffeeData struct in Models/Coffee.swift or new file Models/ExtractedCoffeeData.swift
- [ ] **Task 3**: Create OCRService.swift with Vision framework integration, implement extractText(from image: UIImage) async throws -> String method

### Phase 2: Text Parsing Service
- [ ] **Task 1**: Create TextParserService.swift with parseExtractedText(_ text: String) -> ExtractedCoffeeData method
- [ ] **Task 2**: Implement country/region detection using common coffee origin keywords (Ethiopia, Colombia, Brazil, Kenya, etc.) and positional heuristics
- [ ] **Task 3**: Implement variety, altitude, roast level, and process detection using keyword matching against existing enums (RoastLevel.allCases, Process.allCases)

### Phase 3: ViewModel Integration
- [ ] **Task 1**: Add @Published properties to CoffeeFormViewModel: extractedFields, isProcessingOCR, showingOCRReview, showingCameraPicker
- [ ] **Task 2**: Add methods to CoffeeFormViewModel: processImageWithOCR(_ image: UIImage), applyExtractedData(_ data: ExtractedCoffeeData)
- [ ] **Task 3**: Add permission checking logic using AVFoundation (AVCaptureDevice.authorizationStatus for camera, PHPhotoLibrary.authorizationStatus for photos)

### Phase 4: Camera/Photo Picker UI
- [ ] **Task 1**: Create CoffeeLabelScannerView.swift with PHPickerViewController wrapper for photo library and UIImagePickerController for camera
- [ ] **Task 2**: Implement permission request UI and denied state handling with Settings deep link
- [ ] **Task 3**: Add action sheet to choose between camera and photo library, integrate with CoffeeFormView via .sheet modifier

### Phase 5: OCR Review Screen
- [ ] **Task 1**: Create OCRReviewView.swift displaying ExtractedCoffeeData in editable list format with field labels and text fields
- [ ] **Task 2**: Implement "Use This Data" button that calls viewModel.applyExtractedData() and dismisses review view
- [ ] **Task 3**: Add loading state UI during OCR processing (ProgressView with "Extracting text..." message)

### Phase 6: Form Integration & Polish
- [ ] **Task 1**: Add "Scan Label" button to CoffeeFormView in Details section with camera icon, connected to showingCameraPicker state
- [ ] **Task 2**: Wire up OCR flow: scanner → OCR processing → review view → form auto-fill
- [ ] **Task 3**: Add error handling UI for OCR failures (no text found, processing errors) with retry option

---

## 🔍 Investigation Resolutions

### I1: Text Parsing Strategy ✅
**Decision**: Use multi-pass heuristic approach:
1. **Position-based**: Top 20% of text blocks likely contain coffee name/roaster
2. **Size-based**: Larger text typically indicates coffee name
3. **Keyword matching**: Known coffee countries, varieties, processes
4. **Pattern matching**: Altitude patterns (regex for "\\d+\\s*(m|masl|ft|feet)")
5. **Context clues**: If "Ethiopia" found, check nearby text for region (Yirgacheffe, Sidamo)

### I2: Vision Framework Performance ✅
**Decision**: 
- OCR typically takes 1-3 seconds for coffee bag images
- Use async/await with Task for background processing
- Show ProgressView during processing
- No need for complex queue management

### I3: Multi-language Support ✅
**Decision**: Configure VNRecognizeTextRequest with `.supportedRecognitionLanguages = ["en-US", "es-ES"]` and `.recognitionLevel = .accurate`

### I4: Field Mapping Confidence ✅
**Decision**: 
- Use priority system: region > country (if both match same value)
- Store both possible matches, allow user to choose in review screen
- Default to more specific field (region over country)

---

## 📝 Additional Implementation Details

### Info.plist Configuration (via Build Settings)
Since `GENERATE_INFOPLIST_FILE = YES`, add to project.pbxproj build settings:
```
INFOPLIST_KEY_NSCameraUsageDescription = "PerfectBrew needs camera access to scan coffee bag labels and extract information automatically.";
INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "PerfectBrew needs photo library access to select coffee bag label photos for text extraction.";
```

### Country/Region Keywords for Text Parser
```swift
let coffeeCountries = ["Ethiopia", "Colombia", "Brazil", "Kenya", "Guatemala", "Costa Rica", "Panama", "Honduras", "Rwanda", "Burundi", "Tanzania", "Yemen", "Indonesia", "India", "Vietnam", "Peru", "Bolivia", "Ecuador"]
let coffeeRegions = ["Yirgacheffe", "Sidamo", "Harrar", "Narino", "Huila", "Antioquia", "Cauca", "Nyeri", "Kiambu", "Boquete", "Tarrazu", "Yauco"]
```

### Common Variety Keywords
```swift
let varieties = ["Geisha", "Gesha", "Bourbon", "Typica", "Caturra", "Catuai", "Pacamara", "Maragogype", "SL28", "SL34", "Blue Mountain", "Java"]
```

### Altitude Pattern Regex
```swift
let altitudePattern = #"\d+\s*(m|masl|meters?|ft|feet|f\.?a\.?s\.?l\.?)"#
```

---

## ⚠️ Known Limitations & Edge Cases

1. **Label Layout Variations**: Some labels may have text in unexpected positions - parsing may be less accurate
2. **Handwritten Labels**: OCR struggles with handwritten text - will handle gracefully with error message
3. **Multiple Languages on Same Label**: Vision framework handles this, but parsing may mix languages
4. **Low Contrast/Lighting**: May result in poor OCR - user can retry or use photo library with better image
5. **Very Small Text**: May not be recognized - acceptable limitation, user can fill manually
6. **Partial Text Extraction**: Always allow user to complete missing fields manually

---

## ✅ Ready for Implementation

This plan is ready for execution with:
- ✅ All file paths verified
- ✅ Architecture alignment confirmed
- ✅ State management patterns defined
- ✅ Error scenarios considered
- ✅ No placeholders or TODOs
- ✅ Follows PerfectBrew conventions

**Awaiting user approval before proceeding with implementation.**

