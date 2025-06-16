//
//  ImageClassificationViewModel.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 10.04.2023.
//

import Foundation
import SwiftUI
class ImageClassificationViewModel: ObservableObject {
    @Published var image: UIImage = UIImage(imageLiteralResourceName: "dog.jpg")
    @Published var result: String = ""
    @Published var source: ModelSource = .coreMl
    @Published var showProgress: Bool = false 
}
