# SwiftUI Patterns for PerfectBrew

## Navigation Patterns

### NavigationStack (iOS 16+)
```swift
// ✅ Correct: Use NavigationStack
NavigationStack {
    HomeScreen()
}

// Navigation with path
@State private var navigationPath = NavigationPath()

NavigationStack(path: $navigationPath) {
    List {
        NavigationLink("Detail", value: "detail")
    }
    .navigationDestination(for: String.self) { value in
        DetailScreen()
    }
}
```

### Tab Navigation
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
.accentColor(.orange) // PerfectBrew accent
```

### Modal Presentation
```swift
// Sheet
.sheet(isPresented: $showSheet) {
    SheetContent()
        .presentationDetents([.medium, .large])
}

// Full screen cover
.fullScreenCover(isPresented: $showFullScreen) {
    FullScreenContent()
}
```

## State Management

### View Models
```swift
// ✅ Correct: @StateObject for owned view models
@StateObject private var viewModel = BrewingGuideViewModel()

// ✅ Correct: @ObservedObject for passed view models
@ObservedObject var viewModel: BrewingGuideViewModel

// ❌ Avoid: Creating in body
var body: some View {
    let vm = ViewModel() // ❌ New instance each render
}
```

### State Updates
```swift
// ✅ Correct: Use @Published in ObservableObject
class ViewModel: ObservableObject {
    @Published var isRunning = false
}

// ✅ Correct: Update on main thread
DispatchQueue.main.async {
    self.isRunning = true
}
```

### Binding Patterns
```swift
// Two-way binding
@State private var text = ""
TextField("Enter text", text: $text)

// Binding to computed property
var binding: Binding<String> {
    Binding(
        get: { computedValue },
        set: { newValue in updateValue(newValue) }
    )
}
```

## List Patterns

### Lazy Loading
```swift
// ✅ Correct: Use LazyVStack/LazyVGrid for large lists
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

// ✅ Correct: Use LazyVGrid for grids
LazyVGrid(columns: [GridItem(.flexible())]) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
```

### List with Sections
```swift
List {
    Section(header: Text("Header")) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    
    Section(footer: Text("Footer")) {
        // More items
    }
}
.listStyle(.insetGrouped)
```

## Form Patterns

### Form Structure
```swift
Form {
    Section(header: Text("Settings")) {
        Toggle("Haptic Feedback", isOn: $hapticEnabled)
        
        Picker("Language", selection: $language) {
            ForEach(Language.allCases) { lang in
                Text(lang.rawValue).tag(lang)
            }
        }
    }
}
```

### Custom Buttons in Forms
```swift
// ✅ Correct: Use PlainButtonStyle to prevent Form hijacking
Form {
    Section {
        Button(action: {}) {
            Text("Custom Action")
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

## Animation Patterns

### State-Based Animations
```swift
// Animate state changes
withAnimation(.easeInOut(duration: 0.2)) {
    isSelected = true
}

// Animate value changes
.animation(.spring(), value: isExpanded)

// Conditional animation
.animation(isEnabled ? .default : nil, value: value)
```

### Transitions
```swift
// Show/hide with transition
if showContent {
    ContentView()
        .transition(.opacity.combined(with: .move(edge: .top)))
}

// Custom transition
.transition(.asymmetric(
    insertion: .scale.combined(with: .opacity),
    removal: .opacity
))
```

## View Composition

### View Builders
```swift
// ✅ Correct: Use @ViewBuilder for complex views
@ViewBuilder
private func contentView() -> some View {
    if condition {
        ViewA()
    } else {
        ViewB()
    }
}

// ✅ Correct: Extract complex views
private var headerView: some View {
    VStack {
        // Header content
    }
}
```

### Reusable Components
```swift
// ✅ Correct: Create reusable view components
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.orange)
                .cornerRadius(10)
        }
    }
}
```

## Performance Patterns

### View Updates
```swift
// ✅ Correct: Minimize view updates
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        // Only re-render when viewModel changes
        Text(viewModel.text)
    }
}

// ❌ Avoid: Computations in body
var body: some View {
    Text(expensiveComputation()) // ❌ Runs every render
}
```

### Image Loading
```swift
// ✅ Correct: Use AsyncImage for remote images
AsyncImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fit)
} placeholder: {
    ProgressView()
}

// ✅ Correct: Cache local images
Image("local_image")
    .resizable()
    .renderingMode(.template) // For SF Symbols
```

## Error Handling

### Error States
```swift
enum LoadingState {
    case loading
    case loaded(Data)
    case error(Error)
}

@State private var state: LoadingState = .loading

var body: some View {
    switch state {
    case .loading:
        ProgressView()
    case .loaded(let data):
        ContentView(data: data)
    case .error(let error):
        ErrorView(error: error) {
            retry()
        }
    }
}
```

## Localization Patterns

### String Localization
```swift
// ✅ Correct: Use .localized extension
Text("home".localized)

// ✅ Correct: Localized with parameters
Text("welcome_message".localized, args: userName)

// Extension (in LocalizationManager)
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(for: self)
    }
}
```

## Accessibility Patterns

### Accessibility Labels
```swift
// ✅ Correct: Add accessibility labels
Button(action: {}) {
    Image(systemName: "star.fill")
}
.accessibilityLabel("Favorite")
.accessibilityHint("Double tap to add to favorites")

// ✅ Correct: Hide decorative elements
Image("decoration")
    .accessibilityHidden(true)
```

### Dynamic Type
```swift
// ✅ Correct: Use semantic fonts
Text("Title")
    .font(.title)

// ✅ Correct: Scale with Dynamic Type
.font(.system(size: 16, weight: .semibold))
.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
```

## Common Anti-Patterns

### ❌ Creating View Models in Body
```swift
// ❌ Bad
var body: some View {
    let vm = ViewModel() // New instance each render
    ContentView(viewModel: vm)
}

// ✅ Good
@StateObject private var viewModel = ViewModel()
```

### ❌ Ignoring Safe Areas
```swift
// ❌ Bad
.ignoresSafeArea() // May cause content under notch

// ✅ Good
.ignoresSafeArea(.keyboard, edges: .bottom) // Only ignore keyboard
```

### ❌ Fixed Sizes
```swift
// ❌ Bad
.font(.system(size: 16)) // Doesn't adapt to user preferences

// ✅ Good
.font(.body) // Adapts to Dynamic Type
```

### ❌ Heavy Computations in Body
```swift
// ❌ Bad
var body: some View {
    Text(expensiveComputation()) // Runs every render
}

// ✅ Good
@State private var computedValue = ""
var body: some View {
    Text(computedValue)
}
.onAppear {
    computedValue = expensiveComputation()
}
```
