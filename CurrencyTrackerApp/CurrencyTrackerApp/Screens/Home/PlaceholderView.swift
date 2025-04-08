//
//  PlaceholderView.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//
import SwiftUI

struct PlaceholderView: View {
    let text: String
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(text)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.body)
                .padding(.horizontal, 24)

            NavigationLink(destination: AddAssetView()) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), .cyan.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1).repeatForever(autoreverses: true),
                            value: isAnimating
                        )

                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .onAppear {
            // Delay slightly to make animation feel more natural
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
    }
}
