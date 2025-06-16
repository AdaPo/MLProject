//
//  IncomeClassificationController.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 03.05.2023.
//

import UIKit
import CoreML

class IncomeClassificationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Config.shared.dataset = .adult

        createRootView()
        // Do any additional setup after loading the view.
    }
    

    func createRootView() {
        let root = IncomeClassificationView(classify: classify)
        
        embedInHostingViewController(rootView: root)
    }
    
    
    func classify() {
    }
}
