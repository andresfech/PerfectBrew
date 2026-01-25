import SwiftUI

// MARK: - Taste Descriptor Map (Phase 2)

/// Maps (value, expected?) → (descriptor, explanation) for exertion-style taste UI. Value 1–5.
enum TasteDescriptorMap {
    static func descriptor(value: Double, expected: Double?, expectedLow: Double, expectedHigh: Double) -> (descriptor: String, explanation: String) {
        if expected != nil {
            if value < expectedLow {
                return ("below_expected".localized, "explanation_below_expected".localized)
            }
            if value > expectedHigh {
                return ("above_expected".localized, "explanation_above_expected".localized)
            }
            return ("within_expected".localized, "explanation_within_expected".localized)
        }
        if value < 2 { return ("taste_low".localized, "explanation_taste_low".localized) }
        if value > 4 { return ("taste_high".localized, "explanation_taste_high".localized) }
        return ("taste_medium".localized, "explanation_taste_medium".localized)
    }
}

// MARK: - Hatched Overlay Shape (Phase 2)

private struct HatchedOverlayShape: Shape {
    var spacing: CGFloat = 5
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        var x: CGFloat = -rect.height
        while x < rect.width + rect.height {
            p.move(to: CGPoint(x: x, y: 0))
            p.addLine(to: CGPoint(x: x + rect.height, y: rect.height))
            x += spacing
        }
        return p
    }
}

// MARK: - Exertion-Style Taste View (Phase 1 + 2)

/// Exertion-style taste dimension: gradient bar, custom scrubber, pill, big number, descriptor, hatched expected range. Value 1–5.
/// PRD: Taste 1–5, Acidity/Sweetness/Body only.
struct ExertionStyleTasteView: View {
    let id: String
    let dimension: String
    @Binding var value: Double
    /// Expected level 1–5 for this coffee; nil = no band, use Low/Medium/High pill.
    var expected: Double?
    
    private static let bandHalfWidth = 0.5
    private static let barHeight: CGFloat = 12
    private static let scrubberRadius: CGFloat = 14
    private static let pillHeight: CGFloat = 32
    
    private var expectedLow: Double {
        guard let e = expected else { return 1 }
        return max(1, e - Self.bandHalfWidth)
    }
    
    private var expectedHigh: Double {
        guard let e = expected else { return 5 }
        return min(5, e + Self.bandHalfWidth)
    }
    
    private var pillText: String {
        if expected != nil {
            if value < expectedLow { return "below_expected".localized }
            if value > expectedHigh { return "above_expected".localized }
            return "within_expected".localized
        }
        if value < 2 { return "taste_low".localized }
        if value > 4 { return "taste_high".localized }
        return "taste_medium".localized
    }
    
    private var descriptorPair: (descriptor: String, explanation: String) {
        TasteDescriptorMap.descriptor(value: value, expected: expected, expectedLow: expectedLow, expectedHigh: expectedHigh)
    }
    
    /// 1–5 display. Value stored 1–5.
    private var displayValue: Int {
        min(5, max(1, Int(round(value))))
    }
    
    private var pillColor: Color {
        if expected != nil {
            return (value >= expectedLow && value <= expectedHigh) ? .green : .orange
        }
        return (value < 2 || value > 4) ? .orange : .green
    }
    
    /// 1–5 → 0–1 for bar position.
    private var valueNorm: Double { (value - 1) / 4 }
    private var expectedLowNorm: Double { (expectedLow - 1) / 4 }
    private var expectedHighNorm: Double { (expectedHigh - 1) / 4 }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: 0.35, saturation: 0.6, brightness: 0.85),
                Color(hue: 0.12, saturation: 0.8, brightness: 1.0),
                Color(hue: 0.02, saturation: 0.85, brightness: 0.95)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerContent
            barSection
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(dimension), \(pillText)")
        .accessibilityValue("\(displayValue) out of 5, \(descriptorPair.explanation)")
        .accessibilityHint("Drag to rate, or use rotor to adjust. Swipe up to increase, down to decrease.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                value = min(5, value + 1)
            case .decrement:
                value = max(1, value - 1)
            @unknown default:
                break
            }
        }
    }
    
    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("compared_to_wanted_prefix".localized + dimension.lowercased() + "compared_to_wanted_suffix".localized)
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(displayValue)")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.primary)
            Text(descriptorPair.descriptor)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(pillColor)
            Text(descriptorPair.explanation)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    private var barSection: some View {
        GeometryReader { g in
            ExertionBarContent(
                width: g.size.width,
                value: $value,
                valueNorm: valueNorm,
                expectedLowNorm: expectedLowNorm,
                expectedHighNorm: expectedHighNorm,
                expected: expected,
                gradient: gradient,
                pillColor: pillColor,
                pillText: pillText,
                barHeight: Self.barHeight,
                scrubberRadius: Self.scrubberRadius,
                pillHeight: Self.pillHeight
            )
        }
        .frame(height: Self.pillHeight + 6 + max(Self.barHeight, 44) + (expected != nil ? 20 : 0))
    }
}

// MARK: - Bar content (extracted for type-checker)

private struct ExertionBarContent: View {
    let width: CGFloat
    @Binding var value: Double
    let valueNorm: Double
    let expectedLowNorm: Double
    let expectedHighNorm: Double
    let expected: Double?
    let gradient: LinearGradient
    let pillColor: Color
    let pillText: String
    let barHeight: CGFloat
    let scrubberRadius: CGFloat
    let pillHeight: CGFloat
    
    private var scrubberX: CGFloat { width * CGFloat(valueNorm) }
    private var segmentWidth: CGFloat { width * CGFloat(expectedHighNorm - expectedLowNorm) }
    private var segmentOffset: CGFloat { width * CGFloat(expectedLowNorm) }
    
    var body: some View {
        VStack(spacing: 6) {
            pillRow
            barRow
            if expected != nil {
                Text("expected_range".localized)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var pillRow: some View {
        ZStack(alignment: .leading) {
            Color.clear.frame(maxWidth: .infinity)
            Text(pillText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(pillColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(pillColor.opacity(0.15))
                .clipShape(Capsule())
                .fixedSize()
                .offset(x: max(0, min(width - 100, scrubberX - 50)))
        }
        .frame(height: pillHeight)
    }
    
    private var barRow: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(gradient)
                .frame(height: barHeight)
            if expected != nil, segmentWidth > 4 {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: segmentWidth, height: barHeight)
                    .overlay(
                        HatchedOverlayShape(spacing: 5)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                    )
                    .offset(x: segmentOffset)
            }
            Circle()
                .fill(.white)
                .overlay(Circle().stroke(pillColor, lineWidth: 3))
                .frame(width: scrubberRadius * 2, height: scrubberRadius * 2)
                .offset(x: scrubberX - scrubberRadius)
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { t in
                            let x = Double(t.location.x) / Double(width)
                            value = min(max(x * 4 + 1, 1), 5)
                        }
                )
        }
        .frame(height: max(barHeight, 44))
    }
}

#Preview("ExertionStyleTasteView") {
    struct PreviewWrapper: View {
        @State var value: Double = 3
        var body: some View {
            ExertionStyleTasteView(
                id: "sweetness",
                dimension: "Sweetness",
                value: $value,
                expected: 3.2
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
