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
        createRootView()
        // Do any additional setup after loading the view.
    }
    

    func createRootView() {
        let root = IncomeClassificationView(classify: classify)
        
        embedInHostingViewController(rootView: root)
    }
    
    
    func classify() {
//        print("coreML")
//        do {
//            let config = MLModelConfiguration()
//            let model =  IncomeClassificationModel(configuration: config)
////            let prediction = try model.prediction(
////                sepalLenthg: sepalL,
////                sepalWidth: sepalW,
////                petalLength: petalL,
////                petalWidth: petalW
////            )
////
////            let result = prediction.Target
////            self.result = result
//            
//            let prediction = try model.pred
//        } catch {
//            print("Error happened.")
//        }

    }
}
