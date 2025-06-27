//
//  GradientGenerator.swift
//  GradientGeneratorAI
//
//  Created by Antonio Palomba on 24/06/25.
//

import SwiftUI
import FoundationModels

struct GradientGeneratorView: View {
    @State private var isGenerating: Bool = false
    @State private var generationLimit: Int = 3
    var onTap: (Palette) -> ()
    
    @State private var userPrompt: String = ""
    
    @State private var isStopped: Bool = false
    @Binding var palettes: [Palette]
    @Binding var selectedColor: Int?
    @State private var errorMessage: String?
    @Binding var isHelloDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
//            Text("Let me create a background for you")
//                .font(.largeTitle.bold())
            
            ScrollView(palettes.isEmpty ? .vertical : .horizontal) {
                HStack(spacing: 12) {
                    ForEach(Array(palettes.enumerated()), id: \.1.id) { index, palette in

                        VStack(spacing: 6) {
                            LinearGradient(colors: palette.swiftUIColors, startPoint: .top, endPoint: .bottom)
                                .clipShape(.circle)
                                .overlay(alignment: .center) {
                                    if selectedColor == index {
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
                            selectedColor = index
                            onTap(palette)
                        }
                    }
                    
                    if isGenerating || palettes.isEmpty {
                        VStack(spacing: 6) {
                            KeyframeAnimator(initialValue: 0.0, repeating: true) { rotation in
                                Image(systemName: "apple.intelligence")
                                    .font(.largeTitle)
                                    .rotationEffect(.init(degrees: rotation))
                            } keyframes: { _e in
                                LinearKeyframe(0, duration: 0)
                                LinearKeyframe(360, duration: 5)
                            }
                            
                            
                            if palettes.isEmpty {
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
            .disabled(isGenerating)
            
            TextField("Gradient Prompt", text: $userPrompt)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .glassEffect()
                .disableWithOpacity(isGenerating)

            HStack {
                Stepper("Generation Limit: **\(generationLimit)**", value: $generationLimit, in: 1...10)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .glassEffect()
                    .disableWithOpacity(isGenerating)
                    .padding(.trailing, 12)

                Toggle("Hello Light Mode", isOn: $isHelloDarkMode)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .glassEffect()
                    .disableWithOpacity(isGenerating)
            }


            Button {
                if isGenerating {
                    isStopped = true
                } else {
                    isStopped = false
                    generatePalettes()
                }
            } label: {
                Text(isGenerating ? "Stop Crafting" : "Craft Gradients")
                    .contentTransition(.numericText())
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.blue.gradient, in: .capsule)
            }
            .disableWithOpacity(userPrompt.isEmpty)
            
        }
        .safeAreaPadding(15)
        .glassEffect(.regular, in: .rect(cornerRadius: 20, style: .continuous))
        .alert(isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func generatePalettes() {
        Task {
            do {
                isGenerating = true
                let instructions: String = """
                    Generate a smooth gradient color palette based on the user's prompt. The gradient should transition between two or more colors relevant to the theme, mood, or elements described in the prompt. Limit the result to only \(generationLimit) palettes.
                    """
                
                let session = LanguageModelSession {
                    instructions
                }
                
                let response = session.streamResponse(to: userPrompt, generating: [Palette].self)
                
                for try await partialResult in response {
                    let palettes = partialResult.compactMap {
                        if let id = $0.id,
                           let name = $0.name,
                           let colors = $0.colors?.compactMap({ $0 }),
                           colors.count > 2 {
                            return Palette(id: id, name: name, colors: colors)
                        }
                        return nil
                    }
                    withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                        self.palettes = palettes
                    }
                    
                    if isStopped {
                        print("User-Stopped")
                        isGenerating = false
                        return
                    }
                }
                
                isGenerating = false
            } catch {
                errorMessage = "(\(type(of: error))): \(error.localizedDescription)\n\(String(describing: error))"
                isGenerating = false
            }
        }
    }
}

//#Preview {
//    GradientGeneratorView()
//        .padding()
//}

@Generable
struct Palette: Identifiable {
    var id: Int
    @Guide(description: "Gradient Name")
    var name: String
    @Guide(description: "Hex Color Codes")
    var colors: [String]

    var swiftUIColors: [Color] {
        colors.compactMap({ .init(hex: $0) })
    }
}

extension View {
    func disableWithOpacity(_ status: Bool) -> some View {
        self.disabled(status).opacity(status ? 0.5 : 1)
    }
}

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

