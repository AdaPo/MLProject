//
//  IrisClassificationView.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 11.04.2023.
//

import SwiftUI
import CoreML

struct IrisClassificationView: View {

    @State var sepalW: Double = Double()
    @State var sepalL: Double = Double()
    @State var petalW: Double = Double()
    @State var petalL: Double = Double()

    @State private var result: String = ""
    @State var modelSource: ModelSource = .coreMl

    var model: IrisViewModel
//    var model: IrisViewModel
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Form {
                    HStack() {
                        Text("Sepal width")
                        Spacer()
                        TextField("", value: $sepalW, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                        
                    }
                    HStack() {
                        Text("Sepal length")
                        Spacer()
                        TextField("", value: $sepalL, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                    }
                    HStack() {
                        Text("Petal width")
                        Spacer()
                        TextField("", value: $petalW, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                    }
                    HStack() {
                        Text("Petal Length")
                        Spacer()
                        TextField("", value: $petalL, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                    }
                    VStack {
                        Text("Selected the source of ML Model")
                        Picker("Select model source", selection: $modelSource) {
                            ForEach(ModelSource.allCases, id: \.self) { value in
                                Text(value.rawValue)
                            }
                        }
                        .padding(.horizontal, 20)
                        .pickerStyle(.segmented)
                    }
                    
                    Text("Classified Iris type: \(result)")

                    Section {
                        EmptyView()
                    } footer: {
                        Button {
                            classifyIris()
                            model.predictWith(modelSource)
                        } label: {
                            Text("Classify")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                        .padding(30)
                        .background(.gray)
                        .cornerRadius(8)
                        
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func classifyIris() {
        switch modelSource {
        case .coreMl:
            print("coreML")
            do {
                let config = MLModelConfiguration()
                let model = try IrisClassification(configuration: config)

                let prediction = try model.prediction(
                    sepalLenthg: sepalL,
                    sepalWidth: sepalW,
                    petalLength: petalL,
                    petalWidth: petalW
                )

                let result = prediction.Target
                self.result = result
            } catch {
                print("Error happened.")
            }
        case .bigMl:
            print("bigML")
            BigMLConnector().makePredictionIris(sepalL: sepalL, sepalW: sepalW, petalL: petalL, petalW: petalW) { result in
                self.result = result
            }
        case .tensor:
            let predictor = TensorBridge()
            do {
                let result = try predictor.makePredictionIris(values: [Float32(sepalL), Float32(sepalW), Float32(petalL), Float32(petalW)])
                print("Result from Tensor: \(result.label) conf \(result.confidence)")
                self.result = "\(result.label) with \(result.confidence * 100)% confidence"
            } catch {
                print("Tensor unable to make prediction: \(error)")
            }
        }
    }
}

struct IrisClassificationView_Previews: PreviewProvider {
    static var previews: some View {
        IrisClassificationView(model: IrisViewModel(predictWith: {_ in }))
    }
}
