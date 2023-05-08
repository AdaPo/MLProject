//
//  ImageClassificationView.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 10.04.2023.
//

import SwiftUI

enum ModelSource: String, Equatable, CaseIterable {
    case coreMl = "Core ML"
    case bigMl = "BigML"
}

struct ImageClassificationView: View {
    @ObservedObject var model: ImageClassificationViewModel
    var actionClassify: ((UIImage)->Void)
    var actionOpenGallery: (()->Void)
    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 50) {
                    Image(uiImage: model.image)
                        .resizable()
                        .frame(width: 299, height: 299)
                    if model.showProgress {
                        ProgressView {
                            Text("Awaiting response")
                        }
                        .progressViewStyle(.circular)
                    }
                    VStack {
                        Text("Selected the source of ML Model")
                        Picker("Select model source", selection: $model.source) {
                            ForEach(ModelSource.allCases, id: \.self) { value in
                                Text(value.rawValue)
                            }
                        }
                        .padding(.horizontal, 20)
                        .pickerStyle(.segmented)
                    }
                    HStack {
                        Button {
                            actionOpenGallery()
                        } label: {
                            Text("Select image")
                        }
                        .foregroundColor(.white)
                        .padding(15)
                        .background(.gray)
                        .cornerRadius(8)
                        
                        Button {
                            actionClassify(model.image)
                        }
                        label : {
                            Text("Classify")
                        }
                        .foregroundColor(.white)
                        .padding(15)
                        .background(.gray)
                        .cornerRadius(8)
                        
                    }
                    Text("Classified as: \n \(model.result)")
                        .foregroundColor(.black)

                }
                Spacer()
            }
        }
    }
}

struct ImageClassificationView_Previews: PreviewProvider {
    static var previews: some View {
        ImageClassificationView(model: ImageClassificationViewModel(), actionClassify: {_ in}, actionOpenGallery: {})
    }
}
