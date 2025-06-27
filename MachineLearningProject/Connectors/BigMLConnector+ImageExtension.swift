//
//  BigMLConnector+ImageExtension.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 08.05.2023.
//

import Foundation
import UIKit
extension BigMLConnector {
    
     func uploadResource(imageName: String, image: UIImage) async throws -> String {
         // Set your private information
         let USER = "poua02"
         let API_KEY = "3e91272ebb8dd9e23a3108c4a223bf9ae3c5cce2"

         // Set the image data you want to upload
         let imageData = image.jpegData(compressionQuality: 1.0)

         // Set the URL for the API endpoint and create the request object
         let urlString = "https://bigml.io/source"
         let url = URL(string: urlString)!
         var request = URLRequest(url: url)
         request.httpMethod = "POST"

         // Set the request headers
         let boundary = UUID().uuidString
         request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         request.addValue("text/plain", forHTTPHeaderField: "Accept")

         // Set the request body
         let parameters = [
             "username": USER,
             "api_key": API_KEY
         ]
         let httpBody = NSMutableData()

         // Add the parameters to the request body
         for (key, value) in parameters {
             httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
             httpBody.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
             httpBody.append("\(value)\r\n".data(using: .utf8)!)
         }

         // Add the image data to the request body
         httpBody.append("--\(boundary)\r\n".data(using: .utf8)!)
         httpBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
         httpBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
         httpBody.append(imageData!)
         httpBody.append("\r\n".data(using: .utf8)!)
         httpBody.append("--\(boundary)--\r\n".data(using: .utf8)!)

         request.httpBody = httpBody as Data

         var retStr = ""
         // Create the URL session and task for the request
         let session = URLSession.shared
         let (data, response) = try await session.data(for: request)
         
         print("Response: \(response)")
         print("Response body: \(String(data: data, encoding: .utf8) ?? "")")
         retStr = try! JSONDecoder().decode(BigMLUploadImageModel.self, from: data).resource
        
         return retStr
     }
     
     func makePredictionForResource(resourceId: String) -> String {
         guard let url = URL(string: URL_STRING+BIGML_AUTH) else { return "" }
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.allHTTPHeaderFields = ["Content-Type": "application/json"]
         
         let body: [String: AnyHashable] = [
             "deepnet": "deepnet/684efee38baab6a917b8dfd2",
             "input_data": [
                 "000000": resourceId
             ]
         ]
         request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
         
         var responseString = ""
         
         let task = URLSession.shared.dataTask(with: request) { data, _, error in
             guard let data = data, error == nil else {
                 print("No data")
                 return
             }
             
             do {
                 let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                 //                responseString = response as! String
                 responseString = self.parseResponse(response: response)
                 print(responseString)
             } catch {
                 print("no response")
    }
         }
         task.resume()
         return responseString
     }
    
    func makePredictionForResource(resourceId: String) async throws  -> String {
        guard let url = URL(string: URL_STRING+BIGML_AUTH) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        let body: [String: AnyHashable] = [
            "deepnet": "deepnet/684efee38baab6a917b8dfd2",
            "input_data": [
                "000000": resourceId
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        
        let (data, _) = try await URLSession.shared.data(for: request)
        var responseString: String
        do {
            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            //                responseString = response as! String
            responseString = self.parseResponse(response: response)
        } catch {
            return "no response"
        }
        
        return responseString
    }

    func parseResponse(response root: [String: Any]) -> String {

        // Assume this is the JSON you get from the backend

        do {
            if let probabilities = root["probabilities"] as? [[Any]] {

                // Convert into a dictionary: [Label: Confidence]
                var predictions: [String: Double] = [:]

                for entry in probabilities {
                    if entry.count == 2,
                       let label = entry[0] as? String,
                       let confidence = entry[1] as? Double {
                        predictions[label] = confidence
                    }
                }

                // Optional: Sort by highest probability
                let sortedPredictions = predictions.sorted { $0.value > $1.value }

                // Print top prediction
                if let top = sortedPredictions.first {
                    print("Top prediction: \(top.key) with confidence \(top.value)")
                }

                var retString = ""
                // Print all predictions
                for (label, confidence) in sortedPredictions {
                    retString += "Class: \(label), Confidence: \(confidence)\n"
                }
                return retString

            } else {
                return "invalid"
            }
        } catch {
            return "issue parsin"
            print("Error parsing JSON: \(error)")
        }

    }
}
