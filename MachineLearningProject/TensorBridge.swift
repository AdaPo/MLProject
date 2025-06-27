//
//  TensorBridge.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 15.06.2025.
//

import Foundation
import TensorFlowLite

typealias Inference = (label: String, confidence: Float)

class TensorBridge {
    let interpreter: Interpreter
    let labelsPets = ["cat", "dog", "snake"]
    let labelsIris = ["0", "1", "2"] // setosa -> 0, versicolor -> 1, virginica -> 2)
    let labelAdult = ["0", "1"]
    var inferences: [Inference] = []

     init () {
         var modelToBeLoaded: String {
             switch Config.shared.dataset {
             case .iris:
                 return "irisClassifierTFLite"
             case .pet:
                 return "animalClassifierTFLite"
             case .adult:
                 return "adult_income_model"
             }
         }
         
         guard let modelPath = Bundle.main.path(forResource: modelToBeLoaded, ofType: "tflite") else {
             fatalError("Couldn't find animalClassifierTFLite")
         }
         
         do {
             self.interpreter = try Interpreter(modelPath: modelPath)
         } catch {
             fatalError("Couldnt load model")
         }
     }
    
    func makePredictionPet(image: UIImage) throws -> Inference {
        let inputWidth = 224
        let inputHeigh = 224
        
        let pixelBuffer = ImageUtils.pixelBufferCreate(image: image)
        
        let scaledPixelBuffer = ImageUtils.pixelBufferCreateWith(pixelBuffer: pixelBuffer!, resizedTo: CGSize(width: inputWidth, height: inputWidth))
        
        let rgbData = ImageUtils.pixelBufferCreateRGBData(pixelBuffer: scaledPixelBuffer!, byteCount: inputWidth * inputHeigh * 3)
        
        do {
            try self.interpreter.allocateTensors()
            try self.interpreter.copy(rgbData!, toInputAt: 0)
            try self.interpreter.invoke()
        } catch {
            print("Failed: \(error)")
            fatalError("Failuer")
        }
        
        let outputTensor = try interpreter.output(at: 0)
        let results: [Float] = outputTensor.data.withUnsafeBytes {
            Array($0.bindMemory(to: Float.self))
        }
        
        self.inferences = zip(labelsPets.indices, results)
            .sorted { $0.1 > $1.1}
            .map { (label: labelsPets[$0.0], confidence: $0.1) }
        
        return inferences.first ?? Inference(label: "missing", confidence: 0)
    }
    
    func makePredictionIris(values: [Float32]) throws -> Inference {
        let mean: [Float32] = [5.84, 3.06, 3.76, 1.20]
        let std: [Float32] = [0.83, 0.44, 1.77, 0.76]
        
        let normalized = values.enumerated().map { (i, x) in
            return (x - mean[i]) / std[i]
        }
        
        do {
            try self.interpreter.allocateTensors()
            let inputBuffer = normalized.withUnsafeBufferPointer { Data(buffer: $0) }
            try interpreter.copy(inputBuffer, toInputAt: 0)
            try interpreter.invoke()
        } catch {
            print("Failed: \(error)")
            fatalError("Failuer")
        }
        
        let output = try self.interpreter.output(at: 0)
        let results: [Float] = output.data.withUnsafeBytes {
            Array($0.bindMemory(to: Float.self))
        }
        
        self.inferences = zip(labelsIris.indices, results)
            .sorted { $0.1 > $1.1}
            .map { (label: labelsIris[$0.0], confidence: $0.1) }
        
        return inferences.first ?? Inference(label: "missing", confidence: 0)
    }
    
    func makePredictionAdult(data: Data) throws -> Inference {
        do {
            try self.interpreter.allocateTensors()
            try interpreter.copy(data, toInputAt: 0)
            try interpreter.invoke()
        } catch {
            print("Failed: \(error)")
            fatalError("Failuer")
        }
        
        let output = try self.interpreter.output(at: 0)
        let results: [Float] = output.data.withUnsafeBytes {
            Array($0.bindMemory(to: Float.self))
        }
        
        self.inferences = zip(labelAdult.indices, results)
            .sorted { $0.1 > $1.1}
            .map { (label: labelAdult[$0.0], confidence: $0.1) }

        return inferences.first ?? Inference(label: "missing", confidence: 0)
    }
}
