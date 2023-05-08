//
//  IrisClassificationView.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 11.04.2023.
//

import SwiftUI
import CoreML

struct IrisClassificationView: View {

    @State private var sepalW: Double = 0.0
    @State private var sepalL: Double = 0.0
    @State private var petalW: Double = 0.0
    @State private var petalL: Double = 0.0

    @State private var result: String = ""
    @State var modelSource: ModelSource = .coreMl

    var model: IrisViewModel
//    var model: IrisViewModel
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Form {
                    Stepper("Sepal width: \(sepalW.formatted())", value: $sepalW, in: 0...10, step: 0.1)
                    Stepper("Sepal Length: \(sepalL.formatted())", value: $sepalL, in: 0...10, step: 0.1)
                    Stepper("Petal width: \(petalW.formatted())", value: $petalW, in: 0...10, step: 0.1)
                    Stepper("Petal Length: \(petalL.formatted())", value: $petalL, in: 0...10, step: 0.1)
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
        if modelSource == .coreMl {
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
        } else if modelSource == .bigMl {
            print("bigML")
            BigMLConnector().makePredictionIris(sepalL: sepalL, sepalW: sepalW, petalL: petalL, petalW: petalW) { result in
                self.result = result
            }
        }
    }
}

struct IrisClassificationView_Previews: PreviewProvider {
    static var previews: some View {
        IrisClassificationView(model: IrisViewModel(predictWith: {_ in }))
    }
}
