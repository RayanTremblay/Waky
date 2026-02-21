import SwiftUI

/// App mascot: candle with flame. Uses "CandleAvatar" from Assets if present, otherwise a simple drawn placeholder.
struct CandleMascotView: View {
    var body: some View {
        if let img = UIImage(named: "CandleAvatar") {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            CandlePlaceholderView()
        }
    }
}

/// Simple candle + flame shape matching the inspo (white body, orange/yellow flame, dark outline).
struct CandlePlaceholderView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(WakyTheme.textPrimary.opacity(0.4), lineWidth: 2)
                )
            
            VStack(spacing: 2) {
                // Flame
                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [WakyTheme.accent, Color.orange, Color.yellow],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                
                // Wick
                Rectangle()
                    .fill(WakyTheme.textPrimary)
                    .frame(width: 2, height: 6)
                
                // Eyes
                HStack(spacing: 8) {
                    Circle().fill(WakyTheme.textPrimary).frame(width: 6, height: 6)
                    Circle().fill(WakyTheme.textPrimary).frame(width: 6, height: 6)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        WakyTheme.background.ignoresSafeArea()
        CandleMascotView()
            .frame(width: 80, height: 80)
    }
}
