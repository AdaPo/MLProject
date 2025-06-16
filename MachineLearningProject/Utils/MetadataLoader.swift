//
//  MetadataLoader.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 15.06.2025.
//

import Foundation

struct ScalerParams: Codable {
    let mean: [Float]
    let scale: [Float]
    let numeric_cols: [String]
}

class MetadataLoader {
    static func loadFeatureColumns() -> [String] {
        guard let url = Bundle.main.url(forResource: "feature_columns", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let columns = try? JSONDecoder().decode([String].self, from: data) else {
            fatalError("Could not load feature_columns.json")
        }
        return columns
    }

    static func loadScalerParams() -> ScalerParams {
        guard let url = Bundle.main.url(forResource: "scaler_params", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let params = try? JSONDecoder().decode(ScalerParams.self, from: data) else {
            fatalError("Could not load scaler_params.json")
        }
        return params
    }
}
