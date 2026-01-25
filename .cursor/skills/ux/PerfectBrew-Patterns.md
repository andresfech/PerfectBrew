# PerfectBrew Design Patterns

## Color System

### Primary Colors
- **Accent**: `.orange` - Primary actions, selected states
- **Coffee**: `.brown` - Coffee-related elements, gradients
- **Background**: `.systemBackground` - Main background (adapts to dark mode)
- **Card**: `.systemGray6` - Section/card backgrounds

### Usage Guidelines
```swift
// Primary action button
Button(action: {}) {
    Text("Start Brewing")
        .foregroundColor(.white)
        .background(Color.orange)
}

// Secondary action button
Button(action: {}) {
    Text("Cancel")
        .foregroundColor(.orange)
        .background(Color.orange.opacity(0.1))
}

// Coffee-themed elements
HStack {
    Image(systemName: "cup.and.saucer.fill")
        .foregroundColor(.brown)
    Text("Coffee Name")
}
```

## Button Patterns

### Primary Button
```swift
Button(action: {}) {
    HStack {
        Image(systemName: "play.fill")
            .font(.headline)
        Text("start_brewing".localized)
            .font(.headline)
            .fontWeight(.semibold)
    }
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .frame(height: 44)
    .background(Color.orange)
    .cornerRadius(10)
}
```

### Secondary Button
```swift
Button(action: {}) {
    Text("reset".localized)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color(.systemGray5))
        .cornerRadius(10)
}
```

### Icon Button
```swift
Button(action: {}) {
    Image(systemName: "heart.fill")
        .font(.title2)
        .foregroundColor(isFavorite ? .orange : .gray)
        .frame(width: 44, height: 44)
}
```

## Card Patterns

### Section Card (FeedbackScreen pattern)
```swift
VStack(alignment: .leading, spacing: 16) {
    Text("Section Title")
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundColor(.primary)
    
    // Content
    VStack(spacing: 20) {
        // Form fields, questions, etc.
    }
}
.padding(20)
.background(Color(.systemGray6))
.cornerRadius(12)
```

### Method Card (HomeScreen pattern)
```swift
Button(action: {}) {
    VStack(spacing: 12) {
        Image(systemName: "drop.fill")
            .font(.system(size: 40))
            .foregroundColor(isSelected ? .orange : .gray)
        
        Text("V60")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(isSelected ? .primary : .secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Color.orange.opacity(0.2) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    )
}
.buttonStyle(PlainButtonStyle())
.scaleEffect(isSelected ? 1.02 : 1.0)
.animation(.easeInOut(duration: 0.2), value: isSelected)
```

## Progress Indicators

### Progress Dots (PreferenceQuestionnaireView pattern)
```swift
HStack(spacing: 8) {
    ForEach(0..<totalSteps, id: \.self) { index in
        Circle()
            .fill(index < completedSteps ? Color.orange : Color.gray.opacity(0.3))
            .frame(width: 8, height: 8)
            .animation(.easeInOut(duration: 0.2), value: completedSteps)
    }
}

Text("Step \(completedSteps) of \(totalSteps)")
    .font(.caption)
    .foregroundColor(.secondary)
```

### Progress Bar
```swift
GeometryReader { geometry in
    ZStack(alignment: .leading) {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
        
        Rectangle()
            .fill(Color.orange)
            .frame(width: geometry.size.width * progress)
    }
}
.frame(height: 4)
.cornerRadius(2)
```

## Form Components

### Preference Chip (PreferenceQuestionnaireView pattern)
```swift
Button(action: action) {
    Text(title)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(isSelected ? .white : .primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isSelected ? Color.orange : Color.gray.opacity(0.2))
        .cornerRadius(12)
}
.buttonStyle(PlainButtonStyle()) // Important for Forms
```

### Multiple Choice Question (FeedbackScreen pattern)
```swift
VStack(alignment: .leading, spacing: 12) {
    Text(label)
        .font(.headline)
        .foregroundColor(.primary)
    
    VStack(spacing: 8) {
        ForEach(options, id: \.self) { option in
            Button(action: {
                selection = option
            }) {
                HStack {
                    Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selection == option ? .orange : .gray)
                    Text(option)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(12)
                .background(selection == option ? Color.orange.opacity(0.1) : Color(.systemGray5))
                .cornerRadius(8)
            }
        }
    }
}
```

### Star Rating (FeedbackScreen pattern)
```swift
HStack(spacing: 8) {
    ForEach(1...5, id: \.self) { star in
        Button(action: {
            rating = Double(star)
        }) {
            Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                .font(.title2)
                .foregroundColor(star <= Int(rating) ? .orange : .gray)
        }
    }
}
```

## Navigation Patterns

### Tab Navigation (MainTabView pattern)
```swift
TabView(selection: $selectedTab) {
    NavigationStack {
        HomeScreen()
    }
    .tabItem {
        Image(systemName: "house.fill")
        Text("home".localized)
    }
    .tag(0)
}
.accentColor(.orange)
```

### Navigation with Large Title
```swift
NavigationStack {
    ContentView()
        .navigationTitle("title".localized)
        .navigationBarTitleDisplayMode(.large)
}
```

### Navigation with Inline Title
```swift
NavigationStack {
    ContentView()
        .navigationTitle("title".localized)
        .navigationBarTitleDisplayMode(.inline)
}
```

## Coffee Context Patterns

### Coffee Selection Card
```swift
VStack(spacing: 12) {
    if let coffee = selectedCoffee {
        HStack {
            Image(systemName: "cup.and.saucer.fill")
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(coffee.name)
                    .font(.headline)
                Text("\(coffee.roastLevel.rawValue) • \(coffee.process.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Change") {
                showSelection = true
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    } else {
        // Prompt to select coffee
    }
}
```

## Animation Patterns

### Selection Animation
```swift
withAnimation(.easeInOut(duration: 0.2)) {
    isSelected = true
}

.scaleEffect(isSelected ? 1.02 : 1.0)
.animation(.easeInOut(duration: 0.2), value: isSelected)
```

### Transition Animation
```swift
if showContent {
    ContentView()
        .transition(.opacity.combined(with: .move(edge: .top)))
}
```

## Localization Pattern

### Always Use Localized Strings
```swift
// ✅ Correct: Use .localized extension
Text("home".localized)
Button("start_brewing".localized) {}

// ❌ Never: Hardcode English strings
Text("Home") // ❌
Button("Start Brewing") {} // ❌
```

### Localized with Context
```swift
// In LocalizationManager
"home": "Home" // English
"home": "Inicio" // Spanish

// Usage
Text("home".localized) // Automatically uses correct language
```

## Spacing System

### Standard Spacing
- **Tight**: 4-8pt (related elements)
- **Standard**: 12-16pt (sections)
- **Loose**: 20-24pt (major sections)
- **Extra**: 30-32pt (screen sections)

### Padding Patterns
```swift
// Screen padding
.padding(.horizontal, 20)

// Section padding
.padding(20)

// Card padding
.padding(16)

// Button padding
.padding(.vertical, 12)
.padding(.horizontal, 16)
```

## Typography Scale

### Headings
- **Large Title**: `.largeTitle` - Main screen titles
- **Title**: `.title` - Section headers
- **Title 2**: `.title2` - Subsection headers
- **Title 3**: `.title3` - Card titles

### Body Text
- **Headline**: `.headline` - Emphasis, button text
- **Body**: `.body` - Primary content
- **Subheadline**: `.subheadline` - Secondary content
- **Caption**: `.caption` - Labels, hints

### Usage
```swift
Text("perfect_brew".localized)
    .font(.largeTitle)
    .fontWeight(.bold)

Text("craft_perfect_cup".localized)
    .font(.title3)
    .foregroundColor(.secondary)
```

## Common Patterns Summary

1. **Primary Actions**: Orange background, white text, 44pt height
2. **Secondary Actions**: Gray background, primary text, 44pt height
3. **Cards**: systemGray6 background, 12pt corner radius, 20pt padding
4. **Sections**: VStack with title, content, systemGray6 background
5. **Progress**: Orange dots or bars with smooth animations
6. **Forms**: PlainButtonStyle for custom buttons, proper labels
7. **Navigation**: NavigationStack, orange accent, localized titles
8. **Localization**: Always use `.localized` extension
9. **Spacing**: 8pt grid system (8, 16, 20, 24, 32)
10. **Typography**: Semantic fonts, adapts to Dynamic Type
