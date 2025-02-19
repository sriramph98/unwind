import SwiftUI

struct PresetCard: View {
    let title: String
    let isSelected: Bool
    let description: String
    let action: () -> Void
    let isCustom: Bool
    let onModify: (() -> Void)?
    let isDisabled: Bool
    let namespace: Namespace.ID
    let timerState: TimerState
    let isRunning: Bool
    let onStartStop: () -> Void
    let onPauseResume: () -> Void
    @State private var isHovering = false
    
    init(
        title: String,
        isSelected: Bool,
        description: String,
        action: @escaping () -> Void,
        isCustom: Bool = false,
        onModify: (() -> Void)? = nil,
        isDisabled: Bool = false,
        namespace: Namespace.ID,
        timerState: TimerState,
        isRunning: Bool,
        onStartStop: @escaping () -> Void,
        onPauseResume: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.description = description
        self.action = action
        self.isCustom = isCustom
        self.onModify = onModify
        self.isDisabled = isDisabled
        self.namespace = namespace
        self.timerState = timerState
        self.isRunning = isRunning
        self.onStartStop = onStartStop
        self.onPauseResume = onPauseResume
    }
    
    private var sfSymbol: (normal: String, selected: String) {
        switch title {
        case "20-20-20 Rule":
            return ("eyes.inverse", "eyes")  // Eye symbol for 20-20-20 rule
        case "Pomodoro Technique":
            return ("clock", "clock.fill")  // Timer for Pomodoro
        case "Custom":
            return ("slider.horizontal.below.square.filled.and.square", "slider.horizontal.below.square.and.square.filled")  // Slider for custom settings
        default:
            return ("clock", "clock.fill")
        }
    }
    
    private var cardStyle: (background: Color, opacity: Double, stroke: Color) {
        if isSelected {
            return (
                .black,
                0.3,  // Darker tint when selected
                .clear
            )
        } else if isHovering {
            return (
                .black,
                0.2,  // Darker hover state
                .clear
            )
        } else {
            return (
                .black,
                0.15,  // Darker base state
                .clear
            )
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    // Icon
                    Image(systemName: isSelected ? sfSymbol.selected : sfSymbol.normal)
                        .font(.system(size: 32))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isSelected ? .white : .white)
                        .opacity(isSelected ? 1 : 0.9)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(description)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Timer controls and settings button
                    if isSelected {
                        HStack(spacing: 8) {
                            Button(action: onStartStop) {
                                HStack(spacing: 8) {
                                    if isRunning {
                                        Image(systemName: "stop.circle.fill")
                                            .font(.system(size: 12, weight: .medium))
                                        Text(timerState.timeString)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .monospacedDigit()
                                    } else {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                }
                                .foregroundColor(.white)
                            }
                            .buttonStyle(PillButtonStyle(
                                customBackground: isRunning ? Color(red: 1, green: 0, blue: 0).opacity(0.8) : nil
                            ))
                            .animation(.smooth(duration: 0.3), value: timerState.timeString)
                            
                            if isRunning {
                                Button(action: onPauseResume) {
                                    HStack(spacing: 8) {
                                        Image(systemName: timerState.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                            .font(.system(size: 12, weight: .medium))
                                        Text(timerState.isPaused ? "Resume" : "Pause")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(PillButtonStyle(
                                    customBackground: Color(red: 0.3, green: 0.3, blue: 0.3).opacity(0.8)
                                ))
                                .animation(.smooth(duration: 0.3), value: timerState.isPaused)
                                .transition(.opacity.combined(with: .scale))
                            }
                            
                            if isCustom && !isRunning {
                                Button(action: { onModify?() }) {
                                    Image(systemName: "gearshape.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(PillButtonStyle(minWidth: 0))
                            }
                        }
                    }
                }
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardStyle.background.opacity(cardStyle.opacity))
                }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.smooth(duration: 0.3).delay(0.05), value: isSelected)
    }
}

struct HomeView: View {
    let timeInterval: TimeInterval
    let onTimeIntervalChange: (TimeInterval) -> Void
    @StateObject private var timerState: TimerState
    @State private var selectedPreset: String = "20-20-20 Rule"
    @State private var isRunning = false
    @State private var isFooterVisible = false
    @State private var isContentVisible = false
    @State private var isModalPresented = false
    @Namespace private var animation
    
    init(
        timeInterval: TimeInterval,
        timerState: TimerState,
        onTimeIntervalChange: @escaping (TimeInterval) -> Void
    ) {
        self.timeInterval = timeInterval
        self._timerState = StateObject(wrappedValue: timerState)
        self.onTimeIntervalChange = onTimeIntervalChange
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Main content group (everything except footer)
            VStack(spacing: 24) {
                // App Header
                HStack(spacing: 12) {
                    Image("MellowLogo")
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    Text("Mellow")
                        .font(Font.custom("SF Pro Rounded", size: 24).weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // Preset Cards with 16px spacing
                VStack(spacing: 16) {
                    PresetCard(
                        title: "20-20-20 Rule",
                        isSelected: selectedPreset == "20-20-20 Rule",
                        description: "Take a 20-second break every 20 minutes to look at something 20 feet away.",
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPreset = "20-20-20 Rule"
                                onTimeIntervalChange(1200)
                            }
                        },
                        isDisabled: isRunning && selectedPreset != "20-20-20 Rule",
                        namespace: animation,
                        timerState: timerState,
                        isRunning: isRunning && selectedPreset == "20-20-20 Rule",
                        onStartStop: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isRunning.toggle()
                            }
                            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                if isRunning {
                                    appDelegate.startSelectedTechnique(technique: selectedPreset)
                                } else {
                                    appDelegate.stopTimer()
                                }
                            }
                        },
                        onPauseResume: {
                            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                appDelegate.togglePauseTimer()
                            }
                        }
                    )
                    
                    PresetCard(
                        title: "Pomodoro Technique",
                        isSelected: selectedPreset == "Pomodoro Technique",
                        description: "Focus for 25 minutes, then take a 5-minute break to stay productive.",
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPreset = "Pomodoro Technique"
                                onTimeIntervalChange(1500)
                            }
                        },
                        isDisabled: isRunning && selectedPreset != "Pomodoro Technique",
                        namespace: animation,
                        timerState: timerState,
                        isRunning: isRunning && selectedPreset == "Pomodoro Technique",
                        onStartStop: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isRunning.toggle()
                            }
                            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                if isRunning {
                                    appDelegate.startSelectedTechnique(technique: selectedPreset)
                                } else {
                                    appDelegate.stopTimer()
                                }
                            }
                        },
                        onPauseResume: {
                            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                appDelegate.togglePauseTimer()
                            }
                        }
                    )
                    
                    PresetCard(
                        title: "Custom",
                        isSelected: selectedPreset == "Custom",
                        description: "Set your own rules to match your workflow.",
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPreset = "Custom"
                                if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                    onTimeIntervalChange(appDelegate.customInterval)
                                }
                            }
                        },
                        isCustom: true,
                        onModify: {
                            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                appDelegate.showCustomRuleSettings()
                            }
                        },
                        isDisabled: isRunning && selectedPreset != "Custom",
                        namespace: animation,
                        timerState: timerState,
                        isRunning: isRunning && selectedPreset == "Custom",
                        onStartStop: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isRunning.toggle()
                            }
                            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                if isRunning {
                                    appDelegate.startSelectedTechnique(technique: selectedPreset)
                                } else {
                                    appDelegate.stopTimer()
                                }
                            }
                        },
                        onPauseResume: {
                            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                                appDelegate.togglePauseTimer()
                            }
                        }
                    )
                }
                .padding(.horizontal, 24)
            }
            .blur(radius: isContentVisible ? 0 : 10)
            .opacity(isContentVisible ? 1 : 0)
            .scaleEffect(isContentVisible ? 1 : 0.8)
            
            // Footer section
            HStack {
                Spacer() // Add spacer at the start
                
                // Center - Menu bar info (moved from left)
                VStack(alignment: .center, spacing: 8) { // Changed alignment to .center
                    HStack(spacing: 8) {
                        Image(systemName: "menubar.arrow.up.rectangle")
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.6))
                        
                        Text("Mellow lives in the menu bar")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    Text("Click the icon in the menu to access Mellow")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                        .multilineTextAlignment(.center) // Added center text alignment
                }
                .frame(maxWidth: .infinity) // Make the VStack take up all available space
                
                // Right side - Settings icon (keep this on the right)
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17))
                    .foregroundColor(.black.opacity(0.5))
                    .onTapGesture {
                        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                            appDelegate.showSettings()
                        }
                    }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .offset(y: isFooterVisible ? 0 : 100)
            .opacity(isFooterVisible ? 1 : 0)
            .blur(radius: isFooterVisible ? 0 : 10)
        }
        .padding(.top, 24)
        .frame(minWidth: 640)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            ZStack {
                // Add a linear gradient with 100% opacity
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.75, blue: 1.0), Color.white]), // Using RGB values for #67BFFF
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
        .onAppear {
            // Animate content first, then footer
            withAnimation(
                .spring(
                    response: 0.6,         // Changed from 0.3 to 0.6
                    dampingFraction: 0.8,  // Changed from 0.5 to 0.8
                    blendDuration: 0
                )
            ) {
                isContentVisible = true
            }
            
            // Slight delay for footer animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(
                    .spring(
                        response: 0.6,     // Changed from 0.3 to 0.6
                        dampingFraction: 0.8,  // Changed from 0.5 to 0.8
                        blendDuration: 0
                    )
                ) {
                    isFooterVisible = true
                }
            }
        }
        .allowsHitTesting(!isModalPresented)
        .onChange(of: isModalPresented) { oldValue, newValue in
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                appDelegate.homeWindowInteractionDisabled = newValue
            }
        }
    }
}

#Preview {
    HomeView(
        timeInterval: 1200,
        timerState: TimerState(),
        onTimeIntervalChange: { _ in }
    )
    .frame(width: 800, height: 600)
}

struct PresetCardPreview: View {
    @Namespace private var namespace
    
    var body: some View {
        PresetCard(
            title: "20-20-20 Rule",
            isSelected: true,
            description: "Every 20 minutes, look 20 feet away for 20 seconds.",
            action: {},
            namespace: namespace,
            timerState: TimerState(),
            isRunning: true,
            onStartStop: {},
            onPauseResume: {}
        )
        .frame(width: 250)
        .background(Color.black.opacity(0.8))
        .padding()
    }
}

#Preview("Preset Card") {
    PresetCardPreview()
} 
