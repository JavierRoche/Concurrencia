//
//  TopicsViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 31/03/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

enum ErrorTypes: Error {
    case statusCode
    case malformedURL
    case malformedData
    var description: String {
        switch self {
        case .statusCode: return "Status code failure"
        case .malformedURL: return "Malformed URL"
        case .malformedData: return "Couldn't decodable API response"
        }
    }
}

class TopicsViewController: UIViewController {
    @IBOutlet weak var latestTopics: UITableView!
    
    let cn200: Int = 200
    var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupData { [weak self] (result) in
            switch result {
            case .success(let array):
                self?.topics = array
                self?.latestTopics.reloadData()
            case .failure(let error):
                if let errorType = error as? ErrorTypes {
                    switch errorType {
                    case .malformedURL:
                        self?.showAlert(title: "Error", message: errorType.description)
                    case .malformedData:
                        self?.showAlert(title: "Error", message: errorType.description)
                    case .statusCode:
                        self?.showAlert(title: "Error", message: errorType.description)
                    }
                } else {
                    self?.showAlert(title: "Server Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Funciones
    func setupUI() {
        print("TopicsViewController: func setupUI")
        /// Indicamos a la vista que ella controla el dataSource y el delegate
        latestTopics.dataSource = self
        latestTopics.delegate = self
        /// Configuraremos el UITableView para que reconozca la clase de la celda
        latestTopics.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setupData(completion: @escaping (Result<[Topic], Error>) -> Void) {
        print("TopicsViewController: func setupData")
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let topicsURL = URL(string: "https://mdiscourse.keepcoding.io/latest.json") else {
            completion(.failure(ErrorTypes.malformedURL))
            return
        }
        /// Creamos la request y le asignamos los valores necesarios del API
        var request = URLRequest(url: topicsURL)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe2", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        /// La session lanza su datatask con la request
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                /// Devolvemos el tipo Error con los errores de servicio API
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
            if let response = response as? HTTPURLResponse, let data = data {
                print("Latest Topics Status Code: \(response.statusCode)")
                if response.statusCode == self.cn200 {
                    do {
                        let response = try JSONDecoder().decode(LatestTopicsResponse.self, from: data)
                        /// Devolvemos el array que contiene los topics recuperados
                        DispatchQueue.main.async {
                            completion(.success(response.topicList.topics))
                        }
                    } catch {
                        /// Devolvemos el tipo Error para la no decodificacion de la response
                        DispatchQueue.main.async {
                            completion(.failure(ErrorTypes.malformedData))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(ErrorTypes.statusCode))
                    }
                }
            }
        }
        dataTask.resume()
    }
}


// MARK: Delegate
extension TopicsViewController: UITableViewDelegate, TopicDetailViewControllerDelegate {
    /// Funcion delegada de comunicacion con TopicDetailViewControllerDelegate
    func changes() {
        print("TopicsViewController: func changes")
        latestTopics.reloadData()
    }
    /// Funcion delegada de UITableViewDelegate para seleccion de celda
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TopicsViewController: didSelectRowAt - pushViewController")
        let detail = TopicDetailViewController.init(topic: topics[indexPath.row])
        detail.delegate = self
        self.navigationController?.pushViewController(detail, animated: true)
        latestTopics.deselectRow(at: indexPath, animated: true)
    }
    /// Funcion delegada de UITableViewDelegate para altura de celda
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: DataSource
extension TopicsViewController: UITableViewDataSource {
    /// Funcion delegada de UITableViewDataSource para el numero de secciones de cada celda
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /// Funcion delegada de UITableViewDataSource para el numero de celdas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    /// Funcion delegada de UITableViewDataSource para el repintado de celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = latestTopics.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = topics[indexPath.row].title
        return cell
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
