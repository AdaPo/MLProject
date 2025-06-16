//
//  BigMLConnector.swift
//  MachineLearningProject
//
//  Created by Adam Poustka on 11.04.2023.
//

import Foundation
import UIKit
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import TensorFlowLite

enum BigMLConnectorError: Error {
    case noUrl
    case noImage
}

struct BigMLUploadImageModel: Decodable {
    var resource: String
}

class BigMLConnector {
    private let BIGML_USERNAME = "poua02"
    private let BIGML_API_KEY = "3e91272ebb8dd9e23a3108c4a223bf9ae3c5cce2"
    let BIGML_AUTH: String
    let URL_STRING = "https://bigml.io/andromeda/prediction?"
    let boundary: String = "--\(UUID().uuidString)"
    var resourceId: String = ""
    
    init() {
        self.BIGML_AUTH = "username=\(BIGML_USERNAME);api_key=\(BIGML_API_KEY)"
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}


