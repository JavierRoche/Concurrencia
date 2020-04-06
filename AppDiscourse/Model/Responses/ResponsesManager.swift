//
//  ResponsesManager.swift
//  AppDiscourse
//
//  Created by APPLE on 05/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

// MARK: Topic Error Responses Model
/// Modelo personalizado de respuesta erronea del API
struct DiscourseAPIError: Codable {
    let action: String?
    let errors: [String]?
}

enum ErrorTypes: Error {
    case statusCode
    case malformedURL
    case malformedData
    case charsNumber
    var description: String {
        switch self {
        case .statusCode: return "Status code failure"
        case .malformedURL: return "Malformed URL"
        case .malformedData: return "Couldn't decodable API response"
        case .charsNumber: return "Title and body must have 15 characters at less"
        }
    }
}

// MARK: UIViewController Personal Utilities
extension UIViewController {
    /// Funcion para la generacion de mensajes de alerta
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

//        print("TABLA ANTES DE INSERTAR")
//        var tabla1: [String] = topics.map { (topic) -> String in
//            return String(topic.id)
//        }
//        print(tabla1)
