//
//  GradientGenerator.swift
//  GradientGeneratorAI
//
//  Created by Antonio Palomba on 24/06/25.
//

import SwiftUI
import FoundationModels

struct GradientGeneratorView: View {
    @Bindable var viewModel: GradientGeneratorViewModel

    var onTap: (Palette) -> ()


    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            ScrollView(viewModel.palettes.isEmpty ? .vertical : .horizontal) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.palettes.enumerated()), id: \.1.id) { index, palette in

                        VStack(spacing: 6) {
                            LinearGradient(colors: palette.swiftUIColors, startPoint: .top, endPoint: .bottom)
                                .clipShape(.circle)
                                .overlay(alignment: .center) {
                                    if viewModel.selectedColor == index {
                                        ZStack {
                                            Color.black.opacity(0.3)
                                                .clipShape(.circle)
                                            Image(systemName: "checkmark.circle.fill")
                                                .resizable()
                                                .frame(width: 28, height: 28)
                                                .foregroundColor(.white)
                                                .shadow(radius: 2)
                                        }
                                    }
                                }

                            Text(palette.name)
                                .font(.caption)
                                .foregroundStyle(.gray)

                        }
                        .frame(maxHeight: .infinity)
                        .contentShape(.rect)
                        .onTapGesture {
                            print(palette)
                            viewModel.selectedColor = index
                            onTap(palette)
                        }
                    }
                    
                    if viewModel.isGenerating || viewModel.palettes.isEmpty {
                        VStack(spacing: 6) {
                            KeyframeAnimator(initialValue: 0.0, repeating: true) { rotation in
                                Image(systemName: "apple.intelligence")
                                    .font(.largeTitle)
                                    .rotationEffect(.init(degrees: rotation))
                            } keyframes: { _e in
                                LinearKeyframe(0, duration: 0)
                                LinearKeyframe(360, duration: 5)
                            }
                            
                            
                            if viewModel.palettes.isEmpty {
                                Text("Start crafting your gradient....")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding(15)
            }
            .frame(height: 100)
            .defaultScrollAnchor(.trailing, for: .sizeChanges)
            .disabled(viewModel.isGenerating)
            
            TextField("Gradient Prompt", text: $viewModel.userPrompt)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .glassEffect()
                .disableWithOpacity(viewModel.isGenerating)

            HStack {
                Stepper("Generation Limit: **\(viewModel.generationLimit)**", value: $viewModel.generationLimit, in: 1...10)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .glassEffect()
                    .disableWithOpacity(viewModel.isGenerating)
                    .padding(.trailing, 12)

                Toggle("Hello Light Mode", isOn: $viewModel.isHelloDarkMode)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .glassEffect()
                    .disableWithOpacity(viewModel.isGenerating)
            }


            Button {
                if viewModel.isGenerating {
                    viewModel.isStopped = true
                } else {
                    viewModel.isStopped = false
                    viewModel.generatePalettes()
                }
            } label: {
                Text(viewModel.isGenerating ? "Stop Crafting" : "Craft Gradients")
                    .contentTransition(.numericText())
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.blue.gradient, in: .capsule)
            }
            .disableWithOpacity(viewModel.userPrompt.isEmpty)
            
        }
        .safeAreaPadding(15)
        .glassEffect(.regular, in: .rect(cornerRadius: 20, style: .continuous))
        .alert(isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
    }
    
}

extension Palette {
    var swiftUIColors: [Color] {
        colors.compactMap { Color(hex: $0) }
    }
}

extension View {

    /// Disables the view and reduces its opacity when the given condition is true.
    /// - Parameter status: A Boolean value that determines whether the view is disabled and faded. If true, the view is disabled and its opacity is reduced to 0.5.
    /// - Returns: A modified view that is disabled and semi-transparent when `status` is true, or fully opaque and enabled when false.
    func disableWithOpacity(_ status: Bool) -> some View {
        self.disabled(status).opacity(status ? 0.5 : 1)
    }
}

extension Color {

    /// Initializes a `Color` instance from a hexadecimal color string.
    /// - Parameter hex: A hex string representing a color (e.g., "#FFAA00" or "FFAA00").
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        /// Extracts the red component by masking the upper 8 bits and shifting right by 16, then normalizing to [0, 1].
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        /// Extracts the green component by masking the middle 8 bits and shifting right by 8, then normalizing to [0, 1].
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        /// Extracts the blue component by masking the lower 8 bits and normalizing to [0, 1].
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
