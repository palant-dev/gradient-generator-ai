//
//  GradientGenerator.swift
//  GradientGeneratorAI
//
//  Created by Antonio Palomba on 24/06/25.
//

import SwiftUI
import FoundationModels

struct GradientGenerator: View {
    @State private var isGenerating: Bool = false
    @State private var generationLimit: Int = 3
    @State private var userPrompt: String = ""

    @State private var isStopped: Bool = false
    @State private var palettes: [Palette] = []
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Gradient Generator")
                .font(.largeTitle.bold())

            ScrollView(palettes.isEmpty ? .vertical : .horizontal) {
                HStack(spacing: 12) {
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

            TextField("Gradient Prompt", text: $userPrompt)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .glassEffect()

            Stepper("Generation Limit: **\(generationLimit)**", value: $generationLimit, in: 1...10)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .glassEffect()
            Button {
                if isGenerating {
                    isStopped = true
                } else {
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

        }
        .safeAreaPadding(15)
        .glassEffect(.regular, in: .rect(cornerRadius: 20, style: .continuous))
    }

    private func generatePalettes() {
        Task {
            do {
                let instructions: String = """
                    Generate a smooth gradient color palette based on the user's prompt. The gradient should transition between two or more colors relevant to the theme, mood, or elements described in the prompt. Limit the result to only 5 palettes.
                    """

                let session = LanguageModelSession {
                    instructions
                }

                let response = session.streamResponse(to: userPrompt, generating: [Palette].self)
                ///TO-DO: START HERE
            } catch {
                print(error.localizedDescription)
                isGenerating = false
                isStopped = false
            }
        }
    }
}

#Preview {
    GradientGenerator()
        .padding()
}

@Generable
struct Palette: Identifiable {
    var id: Int
    @Guide(description: "Gradient Name")
    var name: String
    @Guide(description: "Hex Color Codes")
    var colors: [String]
}

