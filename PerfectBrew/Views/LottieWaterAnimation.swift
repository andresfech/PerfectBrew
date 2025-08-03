import SwiftUI
import Lottie

struct LottieWaterAnimation: View {
    let animationName: String
    let isPlaying: Bool
    let loopMode: LottieLoopMode
    let speed: CGFloat
    @State private var isLoaded = false
    
    init(animationName: String, isPlaying: Bool = true, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.animationName = animationName
        self.isPlaying = isPlaying
        self.loopMode = loopMode
        self.speed = speed
    }
    
    var body: some View {
        ZStack {
            if isLoaded {
                LottieView(name: animationName, loopMode: loopMode, speed: speed, isPlaying: isPlaying)
                    .frame(width: 120, height: 120)
                    .onAppear {
                        // Small delay to ensure smooth transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isLoaded = true
                        }
                    }
            } else {
                // Placeholder while loading
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .onAppear {
                        // Load animation after a brief delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            isLoaded = true
                        }
                    }
            }
        }
    }
}

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let speed: CGFloat
    let isPlaying: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView()
        
        // Load animation synchronously to prevent initial glitches
        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = loopMode
            animationView.animationSpeed = speed
            
            // Set initial frame to prevent glitches
            animationView.currentProgress = 0
            
            if isPlaying {
                animationView.play()
            }
        } else {
            // Fallback if animation fails to load
            print("Warning: Failed to load animation '\(name)'")
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = uiView.subviews.first as? LottieAnimationView else { return }
        
        // Only update if animation is loaded
        if animationView.animation != nil {
            if isPlaying {
                animationView.play()
            } else {
                animationView.pause()
            }
        }
    }
}

// MARK: - Specific Animation Components

struct WaterPouringLottie: View {
    let isActive: Bool
    let progress: Double
    
    var body: some View {
        LottieWaterAnimation(
            animationName: "Water Bubble",
            isPlaying: isActive,
            loopMode: .loop,
            speed: 1.0
        )
        .scaleEffect(isActive ? 1.0 : 0.8)
        .opacity(isActive ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

struct SteamLottie: View {
    let isActive: Bool
    
    var body: some View {
        if isActive {
            LottieWaterAnimation(
                animationName: "Water Bubble",
                isPlaying: true,
                loopMode: .loop,
                speed: 0.8
            )
            .scaleEffect(0.4)
            .opacity(0.7)
            .offset(y: -30)
        }
    }
}

struct RippleLottie: View {
    let isActive: Bool
    
    var body: some View {
        if isActive {
            LottieWaterAnimation(
                animationName: "Water Bubble",
                isPlaying: true,
                loopMode: .loop,
                speed: 1.2
            )
            .scaleEffect(1.1)
            .opacity(0.5)
        }
    }
}

// MARK: - Preview
struct LottieWaterAnimation_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            WaterPouringLottie(isActive: true, progress: 0.5)
            SteamLottie(isActive: true)
            RippleLottie(isActive: true)
        }
        .padding()
    }
} 