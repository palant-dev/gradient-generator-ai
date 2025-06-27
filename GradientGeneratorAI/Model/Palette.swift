//
//  Palette.swift
//  GradientGeneratorAI
//
//  Created by Antonio Palomba on 27/06/25.
//

import Foundation
import FoundationModels

/// Represents a color palette for a gradient, including its name and colors.
@Generable
struct Palette: Identifiable {
    var id: Int
    @Guide(description: "Gradient Name")
    var name: String
    @Guide(description: "Hex Color Codes")
    var colors: [String]
}
