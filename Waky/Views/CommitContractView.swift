import SwiftUI
import Inject

struct CommitContractView: View {
    @ObserveInjection var inject
    @Binding var isPresented: Bool
    @Binding var username: String
    /// The "fall asleep by" time the user selected (used in contract text and must match what we commit).
    var bedtime: Date
    var onCommitted: (() -> Void)? = nil
    @State private var fingerprintFilled: Bool = false
    @State private var isPressingFingerprint: Bool = false
    @State private var committed: Bool = false
    
    private var commitTimeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: bedtime)
    }
    private var contractDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    private var signerName: String {
        username.isEmpty ? "the undersigned" : username
    }
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(WakyTheme.textSecondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Contract header (centered so it doesn’t overlap the Back button)
                    VStack(alignment: .center, spacing: 8) {
                        Text("SLEEP COMMITMENT")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.2)
                            .foregroundColor(WakyTheme.textSecondary)
                        
                        Text("Dated: \(contractDate)")
                            .font(.caption)
                            .foregroundColor(WakyTheme.textSecondary.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    
                    // Contract body — formal language, no name prompt
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("I, \(signerName), hereby commit to the best of my ability to be in bed by \(commitTimeText) this night, so that I may wake at an optimal time and feel rested.")
                                .font(.subheadline)
                                .foregroundColor(WakyTheme.textPrimary)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("I understand that Waky has blocked distracting apps and that I cannot use these apps in order to respect this sleep contract.")
                                .font(.subheadline)
                                .foregroundColor(WakyTheme.textPrimary)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("I understand that after signing this contract my sleep session starts and I close my phone.")
                                .font(.subheadline)
                                .foregroundColor(WakyTheme.textPrimary)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(WakyTheme.cardPadding)
                    .background(WakyTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                            .stroke(WakyTheme.textSecondary.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                    .padding(.bottom, 24)
                    
                    // Signature block — contract style
                    VStack(spacing: 20) {
                        Rectangle()
                            .fill(WakyTheme.textSecondary.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 8)
                        
                        Text("SIGNATURE")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1)
                            .foregroundColor(WakyTheme.textSecondary)
                        
                        ContractFingerprintView(
                            isFilled: $fingerprintFilled,
                            isPressing: $isPressingFingerprint
                        )
                        
                        Text("Press and hold to sign")
                            .font(.caption2)
                            .foregroundColor(WakyTheme.textSecondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .padding(.horizontal, WakyTheme.cardPadding)
                    .background(WakyTheme.cardBackground.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: WakyTheme.cornerRadius)
                            .stroke(WakyTheme.textSecondary.opacity(0.25), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadius))
                    
                    if committed {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(WakyTheme.accent)
                            Text("Signed")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(WakyTheme.accent)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(24)
            }
            
            // Done button
            Button(action: {
                if fingerprintFilled {
                    committed = true
                    onCommitted?()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isPresented = false
                    }
                } else {
                    isPresented = false
                }
            }) {
                Text(fingerprintFilled ? "Done" : "Cancel")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(fingerprintFilled ? WakyTheme.accent : WakyTheme.textSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: WakyTheme.cornerRadiusLarge))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WakyTheme.background)
        .enableInjection()
    }
}

// MARK: - Fingerprint that fills when user holds thumb on it
struct ContractFingerprintView: View {
    @Binding var isFilled: Bool
    @Binding var isPressing: Bool
    
    var body: some View {
        ZStack {
            // Outline fingerprint (always visible)
            Image(systemName: "touchid")
                .font(.system(size: 56))
                .foregroundStyle(
                    isFilled ? WakyTheme.accent : WakyTheme.textSecondary.opacity(0.4)
                )
            
            // Fill overlay - grows when pressing
            Image(systemName: "touchid")
                .font(.system(size: 56))
                .foregroundStyle(WakyTheme.accent)
                .scaleEffect(isFilled ? 1.0 : 0.3)
                .opacity(isFilled ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: isFilled)
        }
        .frame(width: 80, height: 80)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isFilled {
                        isPressing = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isFilled = true
                        }
                    }
                }
                .onEnded { _ in
                    isPressing = false
                }
        )
    }
}

#Preview {
    let sampleBedtime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date()
    return CommitContractView(isPresented: .constant(true), username: .constant("Alex"), bedtime: sampleBedtime, onCommitted: nil)
}
