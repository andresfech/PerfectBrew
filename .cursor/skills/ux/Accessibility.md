# Accessibility Standards for PerfectBrew

## VoiceOver Support

### Accessibility Labels
Every interactive element needs a meaningful label:

```swift
// ✅ Correct: Descriptive labels
Button(action: {}) {
    Image(systemName: "star.fill")
}
.accessibilityLabel("Add to favorites")

// ❌ Avoid: Generic labels
Button(action: {}) {
    Image(systemName: "star.fill")
}
// Missing accessibility label - VoiceOver will say "Button"
```

### Accessibility Hints
Provide hints for complex interactions:

```swift
Button(action: {}) {
    Text("Settings")
}
.accessibilityLabel("Settings")
.accessibilityHint("Double tap to open app settings")
```

### Accessibility Traits
Use traits to communicate element behavior:

```swift
// Button trait (default for Button)
Button(action: {}) {}
    .accessibilityLabel("Submit")

// Header trait
Text("Section Title")
    .accessibilityAddTraits(.isHeader)

// Selected trait
Toggle("Option", isOn: $isSelected)
    .accessibilityAddTraits(isSelected ? .isSelected : [])

// Link trait
Link("Learn More", destination: url)
    .accessibilityAddTraits(.isLink)
```

### Decorative Elements
Hide purely decorative elements from VoiceOver:

```swift
Image("decoration")
    .accessibilityHidden(true)
```

### Grouping Related Elements
Group related elements for better VoiceOver navigation:

```swift
VStack {
    Text("Coffee Name")
    Text("Roaster Name")
    Text("Roast Level")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Coffee: Name from Roaster, Roast Level")
```

## Dynamic Type

### Semantic Fonts
Always use semantic font styles:

```swift
// ✅ Correct: Semantic fonts adapt to user preferences
Text("Title")
    .font(.title)

Text("Body")
    .font(.body)

// ❌ Avoid: Fixed sizes
Text("Title")
    .font(.system(size: 20)) // Doesn't adapt
```

### Layout Adaptation
Ensure layouts adapt to larger text:

```swift
// ✅ Correct: Flexible layout
VStack(alignment: .leading, spacing: 8) {
    Text("Title")
        .font(.headline)
    Text("Description")
        .font(.body)
}
.fixedSize(horizontal: false, vertical: true) // Allows wrapping

// ❌ Avoid: Fixed heights that cut off text
Text("Long text that might wrap")
    .frame(height: 20) // May cut off at larger sizes
```

### Dynamic Type Size Limits
Respect user preferences but prevent extreme sizes:

```swift
Text("Content")
    .font(.body)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Cap at xxxLarge
```

## Color & Contrast

### Contrast Requirements
- **Normal text**: 4.5:1 contrast ratio (WCAG AA)
- **Large text** (18pt+): 3:1 contrast ratio
- **Interactive elements**: 3:1 contrast ratio

### Testing Contrast
Use Xcode's Accessibility Inspector or online tools to verify contrast ratios.

### Color Independence
Never rely solely on color to convey information:

```swift
// ❌ Bad: Color only
Circle()
    .fill(isSelected ? .green : .gray)

// ✅ Good: Color + icon/shape
HStack {
    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
    Circle()
        .fill(isSelected ? .green : .gray)
}
```

## Motor Accessibility

### Touch Target Sizes
- **Minimum**: 44x44 points
- **Recommended**: 48x48 points for primary actions
- **Spacing**: Minimum 8pt between touch targets

```swift
// ✅ Correct: Adequate touch target
Button(action: {}) {
    Text("Action")
        .frame(minWidth: 44, minHeight: 44)
}

// ❌ Avoid: Small touch targets
Button(action: {}) {
    Text("Action")
        .frame(width: 20, height: 20) // Too small
}
```

### Gesture Alternatives
Provide alternatives to complex gestures:

```swift
// ✅ Correct: Provide button alternative to swipe
HStack {
    // Swipeable list item
    ListItem()
        .swipeActions {
            Button("Delete") { delete() }
        }
    
    // Also provide button
    Button("Delete") { delete() }
}
```

## Screen Reader Testing

### Testing Checklist
- [ ] All interactive elements are labeled
- [ ] Navigation order is logical
- [ ] Form fields have labels and hints
- [ ] Buttons describe their action
- [ ] Images have descriptions or are decorative
- [ ] Dynamic content is announced
- [ ] Error messages are clear

### VoiceOver Navigation
Test with:
1. **Single-finger swipe right**: Next element
2. **Single-finger swipe left**: Previous element
3. **Double tap**: Activate element
4. **Two-finger double tap**: Pause/resume
5. **Three-finger swipe**: Navigate by headings, links, etc.

## Accessibility Modifiers

### Common Modifiers
```swift
// Label
.accessibilityLabel("Descriptive label")

// Hint
.accessibilityHint("What happens when activated")

// Value
.accessibilityValue("Current value")

// Traits
.accessibilityAddTraits(.isButton)
.accessibilityRemoveTraits(.isStaticText)

// Hidden
.accessibilityHidden(true)

// Element grouping
.accessibilityElement(children: .combine)
.accessibilityElement(children: .contain)
.accessibilityElement(children: .ignore)
```

## Form Accessibility

### Form Field Labels
```swift
// ✅ Correct: Labeled text field
VStack(alignment: .leading) {
    Text("Email")
        .font(.headline)
    TextField("Enter email", text: $email)
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
}

// ✅ Better: Use accessibility label
TextField("Email", text: $email)
    .accessibilityLabel("Email address")
    .accessibilityHint("Enter your email address")
```

### Form Validation
Announce validation errors to screen readers:

```swift
if !isValid {
    Text("Error: Invalid email format")
        .foregroundColor(.red)
        .accessibilityLabel("Error")
        .accessibilityValue("Invalid email format")
}
```

## PerfectBrew-Specific Accessibility

### Brewing Guide Screen
- Timer announcements should be clear
- Step instructions should be readable
- Button actions should be descriptive

```swift
Button(action: { viewModel.startTimer() }) {
    Text("start_brewing".localized)
}
.accessibilityLabel("Start brewing timer")
.accessibilityHint("Double tap to begin the brewing process")
```

### Feedback Screen
- Rating controls should be accessible
- Form fields need labels and hints
- Submit button should indicate requirements

```swift
// Star rating accessibility
HStack {
    ForEach(1...5, id: \.self) { star in
        Button(action: { rating = star }) {
            Image(systemName: star <= rating ? "star.fill" : "star")
        }
        .accessibilityLabel("\(star) star")
        .accessibilityAddTraits(star <= rating ? .isSelected : [])
    }
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Overall rating")
.accessibilityValue("\(rating) out of 5 stars")
```

## Testing Tools

### Xcode Accessibility Inspector
1. Open Accessibility Inspector
2. Select your app
3. Inspect elements for:
   - Labels
   - Hints
   - Traits
   - Frame sizes
   - Contrast ratios

### VoiceOver Testing
1. Enable VoiceOver (Settings > Accessibility > VoiceOver)
2. Navigate through your app
3. Verify all content is accessible
4. Test all interactions

### Dynamic Type Testing
1. Settings > Display & Brightness > Text Size
2. Test at all sizes
3. Verify layouts adapt correctly
4. Check for text truncation

## Common Accessibility Issues

### Missing Labels
```swift
// ❌ Bad
Button(action: {}) {
    Image(systemName: "heart.fill")
}

// ✅ Good
Button(action: {}) {
    Image(systemName: "heart.fill")
}
.accessibilityLabel("Add to favorites")
```

### Poor Contrast
```swift
// ❌ Bad: Low contrast
Text("Important")
    .foregroundColor(.gray)

// ✅ Good: High contrast
Text("Important")
    .foregroundColor(.primary)
```

### Fixed Sizes
```swift
// ❌ Bad: Doesn't adapt
.font(.system(size: 16))

// ✅ Good: Adapts to user preferences
.font(.body)
```

### Small Touch Targets
```swift
// ❌ Bad: Too small
Button(action: {}) {
    Image(systemName: "star")
        .frame(width: 20, height: 20)
}

// ✅ Good: Adequate size
Button(action: {}) {
    Image(systemName: "star")
        .frame(minWidth: 44, minHeight: 44)
}
```
