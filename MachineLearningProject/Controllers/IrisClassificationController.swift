//
//  IrisClassificationController.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 11.04.2023.
//

import Foundation
import UIKit

class IrisClassificationController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createRootView()
    }
    
    func createRootView() {
        let model = IrisViewModel(predictWith: self.predictWith)
        let rootView = IrisClassificationView(model: model)
        self.embedInHostingViewController(rootView: rootView)
    }
    
    func predictWith(source: ModelSource) {
//        switch source {
//        case .coreMl:
//
//        case .bigMl:
//
//        }
    }
}
