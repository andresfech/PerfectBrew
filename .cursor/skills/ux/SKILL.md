---
name: ux
description: Review iOS SwiftUI screens for UX issues, design new features with UX guidance, check accessibility compliance, and recommend mobile UX patterns. Use when reviewing screens, designing features, checking accessibility, or when the user asks about UX, user experience, interface design, accessibility, or mobile patterns.
---

# UX Review & Design for PerfectBrew

## Quick Start

When reviewing or designing screens:

1. **Run UX Review Checklist** - Use the checklist below for systematic review
2. **Check Accessibility** - Verify VoiceOver, Dynamic Type, color contrast
3. **Validate SwiftUI Patterns** - Ensure proper navigation, state management, animations
4. **Apply PerfectBrew Patterns** - Follow established design patterns from the codebase

## UX Review Checklist

Use this checklist when reviewing existing screens or designing new features:

### Navigation & Flow
- [ ] Navigation hierarchy is clear and logical
- [ ] Back navigation works correctly
- [ ] Deep links don't create orphaned states
- [ ] Tab navigation uses `NavigationStack` (iOS 16+)
- [ ] Navigation titles are localized and concise

### Layout & Spacing
- [ ] Content respects safe areas (notches, home indicator)
- [ ] Minimum touch target is 44x44 points
- [ ] Spacing follows 8pt grid system (8, 16, 24, 32)
- [ ] Text doesn't overflow or truncate unexpectedly
- [ ] Scrollable content scrolls smoothly

### Visual Design
- [ ] Accent color (`.orange`) used consistently for primary actions
- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] Dark mode support works correctly
- [ ] Icons use SF Symbols consistently
- [ ] Visual hierarchy guides user attention

### Interaction & Feedback
- [ ] Buttons provide clear visual feedback on tap
- [ ] Loading states are shown for async operations
- [ ] Error states are clear and actionable
- [ ] Success states confirm completion
- [ ] Haptic feedback used appropriately (settings toggle)

### Forms & Input
- [ ] Form fields have clear labels
- [ ] Validation errors are shown inline
- [ ] Required vs optional fields are distinguished
- [ ] Keyboard types match input (number pad for quantities)
- [ ] Submit buttons are disabled until valid

### Content & Copy
- [ ] All text is localized (uses `.localized`)
- [ ] Instructions are clear and actionable
- [ ] Error messages are helpful, not technical
- [ ] Empty states guide next actions

### Performance
- [ ] Lists use `LazyVGrid` or `LazyVStack` for large datasets
- [ ] Images are optimized and cached
- [ ] Animations are smooth (60fps)
- [ ] No blocking operations on main thread

## Accessibility Checklist

### VoiceOver Support
- [ ] All interactive elements have `.accessibilityLabel()`
- [ ] Images have meaningful descriptions or are decorative
- [ ] Form fields have `.accessibilityHint()` for complex inputs
- [ ] Buttons describe their action, not just "Button"
- [ ] Navigation is logical when swiping through elements

### Dynamic Type
- [ ] Text uses semantic fonts (`.headline`, `.body`, `.caption`)
- [ ] Layout adapts to larger text sizes
- [ ] No fixed font sizes (use `.font(.system(size:))` only when necessary)
- [ ] Text doesn't get cut off at largest sizes

### Color & Contrast
- [ ] Text meets 4.5:1 contrast ratio (WCAG AA)
- [ ] Interactive elements have 3:1 contrast
- [ ] Color isn't the only indicator (use icons + color)
- [ ] Dark mode tested and working

### Motor Accessibility
- [ ] Touch targets are minimum 44x44 points
- [ ] Spacing between interactive elements is adequate
- [ ] Swipe gestures have alternatives
- [ ] No time-limited interactions without extensions

## SwiftUI Patterns

### Navigation
```swift
// ✅ Correct: Use NavigationStack (iOS 16+)
NavigationStack {
    HomeScreen()
}

// ❌ Avoid: NavigationView (deprecated)
NavigationView {
    HomeScreen()
}
```

### State Management
```swift
// ✅ Correct: Use @StateObject for view models
@StateObject private var viewModel = BrewingGuideViewModel()

// ✅ Correct: Use @ObservedObject when passed in
@ObservedObject var viewModel: BrewingGuideViewModel

// ❌ Avoid: Creating view models in body
var body: some View {
    let viewModel = BrewingGuideViewModel() // ❌ Creates new instance each render
}
```

### Forms
```swift
// ✅ Correct: Use Form with Sections
Form {
    Section(header: Text("Settings")) {
        Toggle("Haptic Feedback", isOn: $hapticEnabled)
    }
}

// ✅ Correct: Custom buttons in Forms use PlainButtonStyle
Button(action: {}) {
    Text("Action")
}
.buttonStyle(PlainButtonStyle()) // Prevents Form hijacking
```

### Animations
```swift
// ✅ Correct: Use withAnimation for state changes
withAnimation(.easeInOut(duration: 0.2)) {
    isSelected = true
}

// ✅ Correct: Animate value changes
.animation(.easeInOut(duration: 0.2), value: isSelected)
```

## PerfectBrew-Specific Patterns

### Color Scheme
- **Primary Accent**: `.orange` for primary actions
- **Secondary**: `.brown` for coffee-related elements
- **Background**: `.systemBackground` (adapts to dark mode)
- **Cards**: `.systemGray6` for section backgrounds

### Button Styles
```swift
// Primary Action Button
Button(action: {}) {
    Text("Start Brewing")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color.orange)
        .cornerRadius(10)
}

// Secondary Action Button
Button(action: {}) {
    Text("Cancel")
        .foregroundColor(.orange)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
}
```

### Progress Indicators
```swift
// Progress Dots (used in PreferenceQuestionnaireView)
HStack(spacing: 8) {
    ForEach(0..<totalSteps, id: \.self) { index in
        Circle()
            .fill(index < completedSteps ? Color.orange : Color.gray.opacity(0.3))
            .frame(width: 8, height: 8)
            .animation(.easeInOut(duration: 0.2), value: completedSteps)
    }
}
```

### Section Cards
```swift
// FeedbackSection pattern (used in FeedbackScreen)
VStack(alignment: .leading, spacing: 16) {
    Text("Section Title")
        .font(.title3)
        .fontWeight(.semibold)
    
    // Content
}
.padding(20)
.background(Color(.systemGray6))
.cornerRadius(12)
```

### Localization
```swift
// ✅ Always use localized strings
Text("home".localized)

// ❌ Never hardcode English strings in UI
Text("Home") // ❌
```

## Common UX Issues to Flag

### Navigation Issues
- Missing back buttons in modal presentations
- NavigationStack not wrapping content
- Deep navigation without breadcrumbs
- Tab state not persisting correctly

### State Management Issues
- View models created in `body` (causes re-initialization)
- State not updating UI (missing `@Published` or `@State`)
- Race conditions in async operations
- Memory leaks from retained closures

### Accessibility Issues
- Missing accessibility labels
- Decorative images not marked as such
- Form fields without hints
- Color-only indicators
- Fixed font sizes

### Performance Issues
- Lists not using lazy loading
- Heavy computations in `body`
- Images not optimized
- Unnecessary view updates

## Review Workflow

1. **Read the screen code** - Understand structure and purpose
2. **Run UX checklist** - Check each category systematically
3. **Test accessibility** - Verify VoiceOver, Dynamic Type, contrast
4. **Check patterns** - Ensure SwiftUI and PerfectBrew patterns are followed
5. **Flag issues** - Document specific problems with code references
6. **Suggest improvements** - Provide concrete code examples

## Additional Resources

- For iOS Human Interface Guidelines, see [HIG.md](HIG.md)
- For detailed SwiftUI patterns, see [SwiftUI-Patterns.md](SwiftUI-Patterns.md)
- For accessibility standards, see [Accessibility.md](Accessibility.md)
- For PerfectBrew design system, see [PerfectBrew-Patterns.md](PerfectBrew-Patterns.md)
