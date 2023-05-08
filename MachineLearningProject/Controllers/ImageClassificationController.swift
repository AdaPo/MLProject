//
//  ImageClassificationController.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 10.04.2023.
//

import Foundation
import UIKit
import SwiftUI
import CoreML
import Vision

class ImageClassificationController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    var model = ImageClassificationViewModel()

    var imagePicker = UIImagePickerController()
    let imagePredictor = ImagePredictor()
    let predictionsToShow = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createRootView()
    }
    
    func createRootView() {
        let root = ImageClassificationView(model: model, actionClassify: classifyImage, actionOpenGallery: openGallery)
        
        embedInHostingViewController(rootView: root)
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        model.image = image
        dismiss(animated: true)
    }
    /// Updates the storyboard's prediction label.
    /// - Parameter message: A prediction or message string.
    /// - Tag: updatePredictionLabel
    func updatePredictionLabel(_ message: String) {
        self.model.result = message
    }
    
    func classifyImage(image: UIImage) {
        //       createSource(image: image)
        self.model.showProgress = true
        if model.source == .coreMl {
            do {
                try self.imagePredictor.makePredictions(for: image, completionHandler: imagePredictionHandler(_:))
            } catch {
                print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
            }
            self.model.showProgress = false

        } else {
            print("BigML")
            let resourceId = createSource(image: image)
            print("Resource id is: ",resourceId)
            let result = BigMLConnector().makePredictionForResource(resourceId: resourceId)
            print(result)
            self.model.showProgress = false
        }
        
    }
    
    func createSource(image: UIImage) -> String {
        guard let imageName = image.accessibilityIdentifier else { return ""}
        guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName) else {
            return ""
        }
        let urlString = imageURL.absoluteString
        
        return BigMLConnector().uploadResource(imageName: imageName, image: image)
    }
    
    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            updatePredictionLabel("No predictions. (Check console log.)")
            return
        }

        let formattedPredictions = formatPredictions(predictions)

        let predictionString = formattedPredictions.joined(separator: "\n")
        updatePredictionLabel(predictionString)
    }

    /// Converts a prediction's observations into human-readable strings.
    /// - Parameter observations: The classification observations from a Vision request.
    /// - Tag: formatPredictions
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)%"
        }

        return topPredictions
    }
}

extension UIViewController {
    func embedInHostingViewController<T:View>(rootView: T) {
        let childView = UIHostingController(rootView: rootView)
        addChild(childView)
        childView.view.frame = self.view.frame
        self.view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
}
