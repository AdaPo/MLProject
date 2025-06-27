//
//  BigMLConnectr+IrisExtension.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 08.05.2023.
//

import Foundation
struct BigMLIrisResponse: Decodable {
    var prediction: IrisPrediction
}

struct IrisPrediction: Codable {
    let the000005: String

    enum CodingKeys: String, CodingKey {
        case the000005 = "000005"
    }
}
extension BigMLConnector {
    func makePredictionIris(sepalL: Double, sepalW: Double, petalL: Double, petalW: Double, finished: @escaping ((String)->Void)) {
        guard let url = URL(string: URL_STRING+BIGML_AUTH) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        let body: [String: AnyHashable] = [
            "model": "deepnet/6435a5807411b4139a34aec1",
            "input_data": [
                "000001": sepalL, // sepal length
                "000002": sepalW, // sepal width
                "000003": petalL, // petal length
                "000004": petalW  // petal width
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("No data")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(BigMLIrisResponse.self, from: data)
                finished(response.prediction.the000005)
            } catch {
                print("no response")
            }
        }
        task.resume()
    }
}
