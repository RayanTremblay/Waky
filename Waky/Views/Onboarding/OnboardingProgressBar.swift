import SwiftUI

/// Small progress bar for onboarding (currentStep 0-based, totalSteps e.g. 2).
struct OnboardingProgressBar: View {
    var currentStep: Int
    var totalSteps: Int

    private var progress: CGFloat {
        guard totalSteps > 0 else { return 0 }
        return CGFloat(currentStep + 1) / CGFloat(totalSteps)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(WakyTheme.textSecondary.opacity(0.2))
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 2)
                    .fill(WakyTheme.accent)
                    .frame(width: max(0, geo.size.width * progress), height: 4)
            }
        }
        .frame(height: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 0, totalSteps: 2)
        OnboardingProgressBar(currentStep: 1, totalSteps: 2)
    }
    .padding()
    .background(WakyTheme.background)
}
