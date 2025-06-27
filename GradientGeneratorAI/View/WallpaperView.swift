//
//  WallpaperView.swift
//  GradientGeneratorAI
//
//  Created by Antonio Palomba on 27/06/25.
//

import SwiftUI

struct WallpaperView: View {
    @State private var palettes: [Palette] = []
    @State private var selectedPaletteIndex: Int? = nil
    @State private var isHelloDarkMode: Bool = true

    private var gradientColors: [Color] {
        if palettes.isEmpty || selectedPaletteIndex == nil || selectedPaletteIndex! < 0 || selectedPaletteIndex! >= palettes.count {
            return [Color.black]
        } else {
            return palettes[selectedPaletteIndex!].swiftUIColors
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: self.gradientColors, startPoint: .top, endPoint: .bottom)
            Image("hello")
                .foregroundStyle(isHelloDarkMode ? Color.white : Color.black)
            VStack {
                Spacer()
                GradientGeneratorView(onTap: { _ in }, palettes: $palettes, selectedColor: $selectedPaletteIndex, isHelloDarkMode: $isHelloDarkMode)
                    .frame(maxWidth: 800)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()

    }
}

#Preview {
    WallpaperView()
}
