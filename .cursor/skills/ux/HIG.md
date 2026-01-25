# iOS Human Interface Guidelines for PerfectBrew

## Design Principles

### Clarity
- Text is legible at all sizes
- Icons are precise and lucid
- Decorations are subtle and appropriate
- Focused functionality drives the design

### Deference
- UI defers to content
- Content fills the screen
- Transparent backgrounds and blurring reveal context
- Minimal use of bezels, gradients, and shadows

### Depth
- Visual layers and realistic motion communicate hierarchy
- Touch and discoverability heighten delight
- Transitions provide a sense of depth

## Layout Guidelines

### Safe Areas
Always respect safe areas for notches and home indicators:

```swift
// ✅ Correct: Content respects safe areas
VStack {
    // Content
}
.padding()
.ignoresSafeArea(.keyboard, edges: .bottom) // Only ignore keyboard

// ❌ Avoid: Ignoring all safe areas
.ignoresSafeArea() // ❌ May cause content under notch
```

### Spacing
Use 8pt grid system:
- **8pt**: Tight spacing (related elements)
- **16pt**: Standard spacing (sections)
- **24pt**: Loose spacing (major sections)
- **32pt**: Extra spacing (screen sections)

### Touch Targets
- **Minimum**: 44x44 points
- **Recommended**: 48x48 points for primary actions
- **Spacing**: Minimum 8pt between touch targets

## Typography

### Text Styles
Use semantic text styles that adapt to Dynamic Type:

```swift
// ✅ Correct: Semantic styles
Text("Title")
    .font(.title)
    .fontWeight(.bold)

Text("Body")
    .font(.body)

Text("Caption")
    .font(.caption)

// ❌ Avoid: Fixed sizes (unless absolutely necessary)
.font(.system(size: 16)) // ❌ Doesn't adapt to user preferences
```

### Text Hierarchy
- **Large Title**: `.largeTitle` - Main screen titles
- **Title**: `.title` - Section headers
- **Title 2**: `.title2` - Subsection headers
- **Title 3**: `.title3` - Card titles
- **Headline**: `.headline` - Emphasis text
- **Body**: `.body` - Primary content
- **Callout**: `.callout` - Secondary content
- **Subheadline**: `.subheadline` - Supporting text
- **Footnote**: `.footnote` - Tertiary text
- **Caption**: `.caption` - Small labels

## Color

### System Colors
Use semantic colors that adapt to appearance:

```swift
// ✅ Correct: Semantic colors
.foregroundColor(.primary)      // Adapts to light/dark
.foregroundColor(.secondary)    // Muted text
.backgroundColor(.systemBackground)  // Background
.backgroundColor(.systemGray6)  // Card backgrounds

// ❌ Avoid: Hardcoded colors for text
.foregroundColor(.black) // ❌ Doesn't work in dark mode
```

### Accent Colors
- PerfectBrew uses `.orange` as primary accent
- Use sparingly for primary actions
- Ensure 4.5:1 contrast ratio for text on colored backgrounds

### Color Contrast Requirements
- **Normal text**: 4.5:1 contrast ratio (WCAG AA)
- **Large text** (18pt+): 3:1 contrast ratio
- **Interactive elements**: 3:1 contrast ratio

## Icons

### SF Symbols
Always use SF Symbols for consistency:

```swift
// ✅ Correct: SF Symbols
Image(systemName: "house.fill")
Image(systemName: "star.fill")

// ❌ Avoid: Custom icons when SF Symbols exist
Image("custom_icon") // ❌ Only if SF Symbols doesn't have equivalent
```

### Icon Sizes
- **Tab bar**: 25x25 points
- **Navigation bar**: 22x22 points
- **Inline**: Match text size
- **Large**: 30x30 points for emphasis

## Navigation

### Navigation Hierarchy
- **Tab Bar**: Primary navigation (3-5 tabs max)
- **Navigation Stack**: Secondary navigation within tabs
- **Modal**: Temporary tasks or detailed views
- **Sheet**: Contextual actions or forms

### Navigation Patterns
```swift
// Tab Navigation
TabView {
    NavigationStack {
        HomeScreen()
    }
    .tabItem {
        Image(systemName: "house.fill")
        Text("Home")
    }
}

// Stack Navigation
NavigationStack {
    List {
        NavigationLink("Detail") {
            DetailScreen()
        }
    }
    .navigationTitle("List")
}

// Modal Presentation
.sheet(isPresented: $showModal) {
    ModalScreen()
}
```

## Buttons

### Button Hierarchy
1. **Primary**: Main action (orange background, white text)
2. **Secondary**: Alternative action (outlined or tinted)
3. **Tertiary**: Less important actions (text only)

### Button Sizes
- **Standard**: 44pt height minimum
- **Large**: 50pt height for primary actions
- **Compact**: 36pt height for toolbars (minimum)

### Button States
Always show clear states:
- **Normal**: Default appearance
- **Highlighted**: Pressed state
- **Disabled**: Reduced opacity (0.5-0.6)
- **Loading**: Show activity indicator

## Forms

### Form Structure
```swift
Form {
    Section(header: Text("Section Title")) {
        // Form fields
    }
    
    Section(footer: Text("Help text")) {
        // More fields
    }
}
```

### Input Types
- **Text**: Standard keyboard
- **Numbers**: Number pad or decimal pad
- **Email**: Email keyboard
- **URL**: URL keyboard
- **Phone**: Phone pad

### Validation
- Show errors inline, below fields
- Use clear, actionable error messages
- Disable submit until valid
- Highlight invalid fields

## Feedback

### Loading States
```swift
// Show loading indicator
if isLoading {
    ProgressView()
} else {
    ContentView()
}
```

### Success States
- Show confirmation message
- Use checkmark icon
- Auto-dismiss after 2-3 seconds
- Provide undo option when appropriate

### Error States
- Clear error message
- Suggest solution
- Provide retry option
- Don't block user from other actions

## Animations

### Animation Principles
- **Purposeful**: Animations should have meaning
- **Smooth**: 60fps, no jank
- **Fast**: Complete in <300ms for most interactions
- **Natural**: Use ease-in-out curves

### Common Animations
```swift
// State change animation
withAnimation(.easeInOut(duration: 0.2)) {
    isSelected = true
}

// Value animation
.animation(.spring(response: 0.3), value: isExpanded)

// Transition
.transition(.opacity.combined(with: .move(edge: .top)))
```

## Dark Mode

### Testing Checklist
- [ ] All colors adapt correctly
- [ ] Images have appropriate contrast
- [ ] Custom colors work in both modes
- [ ] Text remains readable
- [ ] Interactive elements are visible

### Dark Mode Best Practices
- Use semantic colors (`.primary`, `.secondary`)
- Test custom colors in both modes
- Adjust image opacity if needed
- Ensure sufficient contrast
