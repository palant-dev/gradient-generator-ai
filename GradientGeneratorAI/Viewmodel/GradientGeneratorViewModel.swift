//
//  GradientGeneratorViewModel.swift
//  GradientGeneratorAI
//
//  Created by Antonio Palomba on 28/06/25.
//

import Foundation
import SwiftUI
import FoundationModels

@Observable
final class GradientGeneratorViewModel {
    var palettes: [Palette] = []
    var selectedColor: Int?
    var isGenerating: Bool = false
    var userPrompt: String = ""
    var errorMessage: String?
    var isHelloDarkMode: Bool = true
    var generationLimit: Int = 3
    var isStopped: Bool = false
    var selectedPaletteIndex: Int? = nil


    // Generates gradient palettes asynchronously
    func generatePalettes() {
        isStopped = false
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

    func stopGeneration() {
        isStopped = true
    }

    func selectColor(at index: Int) {
        selectedColor = index
    }
}

