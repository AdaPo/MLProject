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
    
    static func encodeInput(_ input: [String: Any],
                    featureColumns: [String],
                    scalerParams: ScalerParams) -> [Float] {
       
       var inputVector = [Float](repeating: 0.0, count: featureColumns.count)

       for (key, value) in input {
           // Numeric columns: scale and insert
           if let index = featureColumns.firstIndex(of: key),
              let floatVal = (value as? NSNumber)?.floatValue,
              let scaleIndex = scalerParams.numeric_cols.firstIndex(of: key) {
               let mean = scalerParams.mean[scaleIndex]
               let scale = scalerParams.scale[scaleIndex]
               inputVector[index] = (floatVal - mean) / scale
           }

           // Categorical one-hot: set corresponding column
           else if let strValue = value as? String {
               let colName = "\(key)_\(strValue)"
               if let catIndex = featureColumns.firstIndex(of: colName) {
                   inputVector[catIndex] = 1.0
               }
           }
       }

       return inputVector
   }

}
