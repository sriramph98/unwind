import SwiftUI

struct SettingsView: View {
    @AppStorage("playSound") private var playSound = true
    @AppStorage("showOverlay") private var showOverlay = true
    @State private var launchAtLogin = false
    @State private var showQuitAlert = false
    let onClose: () -> Void
    @State private var isAppearing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with close button
            HStack {
                Text("Settings")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: dismissSettings) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
                .frame(width: 32, height: 32)
            }
            
            // Settings List
            VStack(alignment: .leading, spacing: 24) {
                // Launch Setting
                SettingRow(
                    title: "Open at login",
                    description: "Launch Mellow automatically when you log in.",
                    isEnabled: $launchAtLogin
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Sound Setting
                SettingRow(
                    title: "Sounds",
                    description: "Play sounds to signal the start and end of breaks.",
                    isEnabled: $playSound
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Overlay Setting
                SettingRow(
                    title: "Countdown Overlay",
                    description: "Show a 10-second countdown overlay before the break starts.",
                    isEnabled: $showOverlay
                )
            }
            
            Spacer(minLength: 16)
            
            // Quit Button
            Button(action: { showQuitAlert = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "power")
                        .font(.system(size: 13))
                    Text("Quit Mellow")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(PillButtonStyle())
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(width: 360)  // Fixed width for window-like appearance
        .background(
            ZStack {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                Color(.windowBackgroundColor).opacity(0.3)  // Reduced opacity to let blur show through
            }
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .opacity(isAppearing ? 1 : 0)
        .scaleEffect(isAppearing ? 1 : 0.98)
        .offset(y: isAppearing ? 0 : -10)
        .alert("Quit Mellow?", isPresented: $showQuitAlert) {
            Button("Cancel", role: .cancel) { }
                .keyboardShortcut(.escape)
            Button("Quit", role: .destructive) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Are you sure you want to quit Mellow? You'll need to manually restart the app to use it again.")
        }
        .onAppear {
            withAnimation(
                .spring(
                    response: 0.3,
                    dampingFraction: 0.65,
                    blendDuration: 0
                )
            ) {
                isAppearing = true
            }
            launchAtLogin = getLaunchAtLoginStatus()
        }
        .onChange(of: launchAtLogin) { oldValue, newValue in
            setLaunchAtLogin(newValue)
        }
    }
    
    private func dismissSettings() {
        withAnimation(
            .spring(
                response: 0.3,
                dampingFraction: 0.65,
                blendDuration: 0
            )
        ) {
            isAppearing = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onClose()
        }
    }
    
    private func getLaunchAtLoginStatus() -> Bool {
        return LaunchAtLogin.isEnabled()
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        LaunchAtLogin.setEnabled(enabled)
    }
}

struct SettingRow: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    private let accentColor = Color(red: 0/255, green: 122/255, blue: 255/255)  // #007AFF
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .toggleStyle(.switch)
                    .scaleEffect(0.8)
                    .tint(accentColor)
                    .padding(.leading, 48)
                    .environment(\.colorScheme, .dark)
            }
            
            Text(description)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
        }
    }
}
