//
//  BigMLConnector+IncomeExtension.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 08.05.2023.
//

import Foundation

struct IncomeModel {
    var age: Int //"000000"
    var workClass: String //"000001"
    var education: String //"000003"
    var maritalStatus: String //"000005"
    var occupation: String //"000006"
    var relationship: String //"000007"
    var race: String //"000008"
    var sex: String //"000009"
    var capitalGain: Int //"00000a"
    var capitalLoss: Int //"00000b"
    var hoursPerWeek: Int //"00000c"
}

struct BigMLIncomeResponse: Decodable {
    var prediction: Prediction
}

struct Prediction: Codable {
    let the00000E: String

    enum CodingKeys: String, CodingKey {
        case the00000E = "00000e"
    }
}

extension BigMLConnector {
    func makePredictionIncome(incomeModel: IncomeModel, finished: @escaping((String)->Void)) {
        guard let url = URL(string: URL_STRING+BIGML_AUTH) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        //        '{"model": "model/4f52e5ad03ce898798000000", "input_data": {"000000": 5, "000001": 3}}'
        let body: [String: Any] = [
            "model": "deepnet/645934d668671c620cd5fa26",
            "input_data": [
                "000000": incomeModel.age,
                "000001": incomeModel.workClass,
                "000003": incomeModel.education,
                "000005": incomeModel.maritalStatus,
                "000006": incomeModel.occupation,
                "000007": incomeModel.relationship,
                "000008": incomeModel.race,
                "000009": incomeModel.sex,
                "00000a": incomeModel.capitalGain,
                "00000b": incomeModel.capitalLoss,
                "00000c": incomeModel.hoursPerWeek
            ] as [String : Any]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        var resultString: String = ""
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("No data")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(BigMLIncomeResponse.self, from: data)
                resultString = result.prediction.the00000E
                print(result)
                finished(resultString)
            } catch {
                print("no response")
            }
        }
        task.resume()
     }
}
