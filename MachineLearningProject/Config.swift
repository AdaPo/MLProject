//
//  Config.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 15.06.2025.
//

import Foundation

enum Dataset {
    case iris
    case pet
    case adult
}

class Config {
    static let shared = Config()
    
    var dataset: Dataset = .iris
}
