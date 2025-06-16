//
//  Encoder.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 15.06.2025.
//
class Encoder {
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
