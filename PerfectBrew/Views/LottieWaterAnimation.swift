import SwiftUI
import Lottie

struct LottieWaterAnimation: View {
    let animationName: String
    let isPlaying: Bool
    let loopMode: LottieLoopMode
    let speed: CGFloat
    
    init(animationName: String, isPlaying: Bool = true, loopMode: LottieLoopMode = .loop, speed: CGFloat = 1.0) {
        self.animationName = animationName
        self.isPlaying = isPlaying
        self.loopMode = loopMode
        self.speed = speed
    }
    
    var body: some View {
        LottieView(name: animationName, loopMode: loopMode, speed: speed, isPlaying: isPlaying)
            .frame(width: 120, height: 120)
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
        
        // Load animation asynchronously to prevent glitches
        DispatchQueue.main.async {
            animationView.animation = LottieAnimation.named(name)
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = loopMode
            animationView.animationSpeed = speed
            
            // Set initial frame to prevent glitches
            animationView.currentProgress = 0
            
            if isPlaying {
                animationView.play()
            }
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
        ZStack {
            // Water bubble animation (using your existing file)
            LottieWaterAnimation(
                animationName: "Water Bubble",
                isPlaying: isActive,
                loopMode: .loop,
                speed: 1.0
            )
            
            // Additional water effects when active
            if isActive {
                LottieWaterAnimation(
                    animationName: "Water Bubble",
                    isPlaying: true,
                    loopMode: .loop,
                    speed: 1.5
                )
                .offset(y: -20)
                .scaleEffect(0.6)
            }
        }
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
            .offset(y: -50)
            .scaleEffect(0.4)
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
            .scaleEffect(1.2)
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