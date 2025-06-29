//
//  WallpaperView.swift
//  GradientGeneratorAI
//
//  Created by Antonio Palomba on 27/06/25.
//

import SwiftUI

struct WallpaperView: View {
    @State private var generatorViewModel = GradientGeneratorViewModel()
    
    /// The set of colors to use for the background gradient, based on the selected palette.
    private var gradientColors: [Color] {
        guard
            !generatorViewModel.palettes.isEmpty,
            let selected = generatorViewModel.selectedColor,
            selected >= 0,
            selected < generatorViewModel.palettes.count
        else {
            return [Color.black]
        }
        return generatorViewModel.palettes[selected].swiftUIColors
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: self.gradientColors, startPoint: .top, endPoint: .bottom)
            Image("hello")
                .foregroundStyle(generatorViewModel.isHelloDarkMode ? Color.white : Color.black)
            VStack {
                Spacer()
                GradientGeneratorView(viewModel: generatorViewModel, onTap: { _ in })
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
