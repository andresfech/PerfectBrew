# PRD: OCR Coffee Bag Scanner

## 📋 Summary

Add OCR (Optical Character Recognition) functionality to automatically extract text from coffee bag labels and auto-fill form fields in the "Add Coffee" screen. This feature uses Apple's Vision framework for text recognition (no AI, pure OCR) to improve user experience by reducing manual data entry.

## 🎯 Goals

**Primary Goal**: Allow users to take a photo of a coffee bag label and automatically populate the coffee form fields with extracted text information.

**How**: 
- Integrate iOS Vision framework for text recognition
- Add camera/photo library access with proper permissions
- Parse extracted text using pattern matching and keyword detection
- Auto-fill available fields in CoffeeFormView
- Provide user with ability to review and edit extracted data before saving

## 🧪 Gherkin User Stories

### Story 1: Take Photo and Extract Text
```
Feature: Scan coffee bag label with camera

Given I am on the "Add Coffee" screen
When I tap the "Scan Label" button
And I grant camera permission
And I take a photo of a coffee bag label
Then the app extracts text from the image using OCR
And displays extracted text in a review view
And auto-fills matching form fields:
  - Coffee name (e.g., "Ethiopia Yirgacheffe")
  - Roaster name (e.g., "Blue Bottle Coffee")
  - Country (e.g., "Ethiopia")
  - Region (e.g., "Yirgacheffe")
  - Variety (e.g., "Geisha")
  - Altitude (e.g., "2000m")
And I can review and edit the extracted data
```

### Story 2: Select Photo from Library
```
Feature: Select existing photo for OCR

Given I am on the "Add Coffee" screen
When I tap the "Scan Label" button
And I tap "Choose from Library"
And I select a photo of a coffee bag label
Then the app extracts text from the selected image
And auto-fills form fields with extracted information
And allows me to review and edit before saving
```

### Story 3: Review and Edit Extracted Data
```
Feature: Review OCR results before saving

Given OCR has extracted text from a coffee bag label
When the extraction review view is displayed
Then I see a list of extracted fields with values
And I can tap on any field to edit it
And I can reject incorrect extractions
And I can manually fill missing fields
When I tap "Use This Data"
Then the form fields are populated with reviewed data
And I can continue editing the form normally
```

### Story 4: Handle OCR Errors
```
Feature: Handle OCR failures gracefully

Given I am scanning a coffee bag label
When OCR fails to extract any text
Then I see a message "No text found. Please try again."
And I can retry the scan
And I can cancel and fill the form manually
```

### Story 5: Partial Text Extraction
```
Feature: Handle partial text extraction

Given OCR extracts only some text from the label
When some fields are extracted and others are not
Then extracted fields are auto-filled
And empty fields remain editable
And I can manually complete missing information
```

## 📦 Functional Requirements

### FR1: Camera/Photo Access
- **FR1.1**: Request camera permission on first use
- **FR1.2**: Request photo library permission on first use
- **FR1.3**: Show permission denied UI with instructions to enable in Settings
- **FR1.4**: Support both camera capture and photo library selection

### FR2: OCR Text Extraction
- **FR2.1**: Use Vision framework's `VNRecognizeTextRequest` for text recognition
- **FR2.2**: Process images in both English and Spanish (multi-language support)
- **FR2.3**: Extract all text blocks from the image
- **FR2.4**: Handle images with various orientations and lighting conditions

### FR3: Text Parsing and Field Mapping
- **FR3.1**: Parse extracted text to identify:
  - Coffee name (typically largest/boldest text, often at top)
  - Roaster name (company/brand name, often near top or bottom)
  - Origin information (Country, Region - look for common coffee country names)
  - Variety (common varieties: Geisha, Bourbon, Typica, Caturra, etc.)
  - Altitude (patterns like "2000m", "2000 masl", "6000 ft")
  - Roast level keywords (Light, Medium, Dark)
  - Process keywords (Washed, Natural, Honey, Anaerobic)
- **FR3.2**: Use keyword matching and pattern recognition (no AI/NLP)
- **FR3.3**: Handle multiple text formats and label layouts
- **FR3.4**: Provide confidence scoring for extracted fields (optional visual indicator)

### FR4: Form Auto-Fill
- **FR4.1**: Auto-populate matching fields in CoffeeFormView
- **FR4.2**: Preserve existing form data if fields are already filled
- **FR4.3**: Allow user to override auto-filled values
- **FR4.4**: Highlight auto-filled fields (optional: different styling)

### FR5: User Experience
- **FR5.1**: Show loading indicator during OCR processing
- **FR5.2**: Display extraction review screen before auto-filling form
- **FR5.3**: Allow user to accept, edit, or reject extracted data
- **FR5.4**: Provide "Scan Again" option if extraction is unsatisfactory
- **FR5.5**: Support editing individual extracted values before applying

## 🚫 Non-Goals (Scope Boundaries)

- **NG1**: AI-powered semantic understanding of label text (using pure OCR/pattern matching only)
- **NG2**: Automatic flavor tag extraction from text descriptions (too complex for OCR)
- **NG3**: Barcode/QR code scanning (separate feature)
- **NG4**: Batch scanning multiple coffee bags at once
- **NG5**: Saving scanned images to the coffee record (text extraction only)
- **NG6**: Offline OCR processing limitations (Vision framework requires device processing)
- **NG7**: Automatic roast date extraction from "Roasted On" labels (manual entry preferred)

## 📁 Affected Files

### New Files
- `PerfectBrew/Services/OCRService.swift` - OCR text extraction service
- `PerfectBrew/Services/TextParserService.swift` - Text parsing and field mapping logic
- `PerfectBrew/Views/MatchMyCoffee/CoffeeLabelScannerView.swift` - Camera/photo picker UI
- `PerfectBrew/Views/MatchMyCoffee/OCRReviewView.swift` - Review extracted data UI

### Modified Files
- `PerfectBrew/Views/MatchMyCoffee/CoffeeFormView.swift` - Add "Scan Label" button, integrate OCR flow
- `PerfectBrew/ViewModels/CoffeeFormViewModel.swift` - Add OCR methods and extracted data handling
- `PerfectBrew.xcodeproj/project.pbxproj` - Add Info.plist keys for camera/photo permissions
- `PerfectBrew/Info.plist` (or build settings) - Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`

## 🔍 Investigation Needed

### I1: Text Parsing Strategy
- **Question**: What patterns reliably identify coffee name vs roaster name on labels?
- **Approach**: Analyze common label layouts, position of text blocks, font sizes
- **Decision**: Use heuristic rules (position, size, keyword matching) rather than ML

### I2: Vision Framework Performance
- **Question**: How long does OCR processing take for typical coffee bag images?
- **Approach**: Test with various image sizes and qualities
- **Decision**: Determine if async processing is needed, loading indicators

### I3: Multi-language Support
- **Question**: Can Vision framework handle Spanish text labels effectively?
- **Approach**: Test OCR with Spanish coffee labels, configure recognition languages
- **Decision**: Configure VNRecognizeTextRequest with both English and Spanish

### I4: Field Mapping Confidence
- **Question**: How to handle ambiguous extractions (e.g., is "Ethiopia" country or region)?
- **Approach**: Use context clues (other fields), positional hints
- **Decision**: Prefer more specific field (region) if both could match, allow user override

## 🗄️ Data Schema

**No changes required** - All extracted data maps to existing `Coffee` model fields:
- `name: String`
- `roaster: String`
- `country: String`
- `region: String`
- `variety: String`
- `altitude: String`
- `roastLevel: RoastLevel` (parsed from text)
- `process: Process` (parsed from text)

## 🎨 Design/UI

### UI Flow
1. **CoffeeFormView**: Add "Scan Label" button (camera icon) above or in "Details" section
2. **Camera/Photo Picker**: Native iOS picker or custom camera view
3. **Processing View**: Loading indicator with "Extracting text..." message
4. **OCR Review View**: List of extracted fields with values, edit buttons, "Use This Data" button
5. **Form Integration**: Extracted data appears in form fields, user can edit normally

### Visual Design
- Camera button: Orange accent color to match app theme
- Extraction review: Card-based layout showing field name and extracted value
- Edit indicators: Tappable fields, edit icons
- Confidence indicators (optional): Visual cue for high/medium/low confidence extractions

## ⚙️ State Management

### ViewModel State
```swift
@Published var extractedText: String = ""
@Published var extractedFields: ExtractedCoffeeData?
@Published var isProcessingOCR: Bool = false
@Published var showingOCRReview: Bool = false
@Published var showingCameraPicker: Bool = false
```

### Extracted Data Model
```swift
struct ExtractedCoffeeData {
    var name: String?
    var roaster: String?
    var country: String?
    var region: String?
    var variety: String?
    var altitude: String?
    var roastLevel: RoastLevel?
    var process: Process?
}
```

## 🔐 Permissions Required

### Info.plist Keys
```xml
<key>NSCameraUsageDescription</key>
<string>PerfectBrew needs camera access to scan coffee bag labels and extract information automatically.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>PerfectBrew needs photo library access to select coffee bag label photos for text extraction.</string>
```

## 📊 Success Metrics

1. **User Adoption**: % of new coffee entries that use OCR vs manual entry
2. **Accuracy Rate**: % of correctly extracted fields (user validation)
3. **Time Savings**: Average time saved per coffee entry vs manual entry
4. **Error Rate**: % of OCR extractions requiring significant manual correction
5. **Completion Rate**: % of OCR scans that result in successful coffee creation

## 🔄 Git Strategy

### Branch Naming
- Feature branch: `feature/ocr-coffee-scanner`

### Commit Checkpoints
1. **Setup**: Add Vision framework, permissions, basic OCR service structure
2. **Camera Integration**: Camera/photo picker UI implementation
3. **OCR Extraction**: Vision framework text recognition implementation
4. **Text Parsing**: Field mapping and parsing logic
5. **Review UI**: OCR review screen implementation
6. **Form Integration**: Auto-fill form fields with extracted data
7. **Polish**: Error handling, loading states, edge cases
8. **Testing**: QA and bug fixes

## ✅ QA Strategy

### LLM Self-Test
- [ ] Verify OCR service correctly extracts text from sample images
- [ ] Test text parser identifies common coffee label patterns
- [ ] Validate field mapping accuracy with various label formats
- [ ] Check error handling for failed OCR or no text found
- [ ] Verify permissions are requested and handled correctly

### Manual User Verification
- [ ] Test with real coffee bag labels (various brands, languages)
- [ ] Verify camera capture works correctly
- [ ] Test photo library selection
- [ ] Validate form auto-fill accuracy
- [ ] Test editing extracted data before saving
- [ ] Verify app handles permission denial gracefully
- [ ] Test on different device sizes (iPhone, iPad)
- [ ] Verify performance (processing time, memory usage)

## 🚀 Implementation Phases

### Phase 1: Foundation (Week 1)
- Set up OCRService with Vision framework
- Add camera/photo permissions
- Basic text extraction functionality

### Phase 2: Text Parsing (Week 1-2)
- Implement TextParserService with pattern matching
- Field mapping logic for common label formats
- Keyword detection for roast level and process

### Phase 3: UI Integration (Week 2)
- Camera/photo picker UI
- OCR review screen
- Form auto-fill integration

### Phase 4: Polish & Testing (Week 2-3)
- Error handling and edge cases
- Loading states and user feedback
- QA testing and bug fixes

---

## 📝 Notes

- Vision framework is built into iOS, no external dependencies needed
- OCR processing happens on-device (privacy-friendly, no network required)
- Text parsing uses heuristic rules, not AI, as per requirements
- User always has final control over extracted data before saving
- Can be extended later to support barcode scanning or AI-powered understanding

