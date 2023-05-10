//
//  Camera.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 10.05.2023.
//

import Foundation
import UIKit

class Camera: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    override func viewDidLoad() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        present(vc,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
                print("No image found")
                return
            }

            // print out the image size as a test
            print(image.size)

    }
}
