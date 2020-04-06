//
//  TopicDetailViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 01/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

// MARK: Protocolo de comunicacion
protocol TopicComunicationDelegate: class {
    func updateTableAfterDelete(deletedTopic: Topic)
    func updateTableAfterCreate(createdTopic: Topic)
}

class TopicDetailViewController: UIViewController {
    @IBOutlet weak var idTopicLabel: UILabel!
    @IBOutlet weak var titleTopicLabel: UILabel!
    @IBOutlet weak var postNumberTopicLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var topic: Topic?
    weak var delegate: TopicComunicationDelegate?
    
    convenience init(topic: Topic) {
        self.init(nibName: "TopicDetailViewController", bundle: nil)
        self.topic = topic
        self.title = "Topic"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.singleTopicAPIDiscourseRequest { [weak self] (result) in
            switch result {
            case .success(let topic):
                self?.topic = topic
                
            case .failure(let error):
                if let errorType = error as? ErrorTypes {
                    switch errorType {
                    case .malformedURL:
                        self?.showAlert(title: "Error", message: errorType.description)
                    case .malformedData:
                        self?.showAlert(title: "Error", message: errorType.description)
                    case .statusCode:
                        self?.showAlert(title: "Error", message: errorType.description)
                    case .charsNumber:
                        self?.showAlert(title: "Error", message: errorType.description)
                    }
                } else {
                    self?.showAlert(title: "Server Error", message: error.localizedDescription)
                }
            }
        }
    }


    // MARK: Functions
    func singleTopicAPIDiscourseRequest(completion: @escaping (Result<Topic, Error>) -> Void) {
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let topicID: Int = self.topic?.id, let discourseURL: URL = URL(string: "https://mdiscourse.keepcoding.io/t/\(topicID).json") else {
            completion(.failure(ErrorTypes.malformedURL))
            return
        }
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest(url: discourseURL)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe2", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession.init(configuration: configuration)
        /// La session lanza su datatask con la request
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            /// El parametro error tiene errores de servicio con el servidor
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
            if let response = response as? HTTPURLResponse, let data = data {
                print("Sigle Topic Status Code: \(response.statusCode)")
                if response.statusCode == 200 {
                    do {
                        let response = try JSONDecoder().decode(Topic.self, from: data)
                        /// En el caso de que no se haya recuperado canDelete y sea nil le damos valor false
                        if (response.details?.canDelete ?? false) {
                            /// Permitiremos borrar el topic solo si el parametro can_delete existe y es true
                            guard let canDelete: Bool = response.details?.canDelete else { return }
                            let image: String = canDelete ? "trash.fill" : "trash.slash.fill"
                            let trashType = UIImage.init(systemName: image)
                            DispatchQueue.main.async { [weak self] in
                                self?.deleteButton.setBackgroundImage(trashType, for: .normal)
                                self?.deleteButton.isEnabled = canDelete
                                self?.idTopicLabel.text = "Topic ID:\(response.id)"
                                self?.titleTopicLabel.text = response.title
                                self?.postNumberTopicLabel.text = "Nº post: \(response.postCount ?? 0)"
                            }
                            
                        } else {
                            DispatchQueue.main.async { [weak self] in
                                self?.deleteButton.setBackgroundImage(UIImage.init(systemName: "trash.slash.fill"), for: .normal)
                                self?.deleteButton.isEnabled = false
                                self?.idTopicLabel.text = "Topic ID:\(response.id)"
                                self?.titleTopicLabel.text = response.title
                                self?.postNumberTopicLabel.text = "Nº post: \(response.postCount ?? 0)"
                            }
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
    
    
    // MARK: IBActions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        print("TopicDetailViewController: deleteButtonTapped")
        guard let topicID: Int = self.topic?.id, let urlDiscourse: URL = URL(string: "https://mdiscourse.keepcoding.io/t/\(topicID).json") else {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(title: "Error", message: "")
            }
            return
        }
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest.init(url: urlDiscourse)
        request.httpMethod = "DELETE"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe2", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession.init(configuration: configuration)
        /// La session lanza su datatask con la request
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            /// El parametro error tiene errores de servicio con el servidor
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
                return
            }
            /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    DispatchQueue.main.async { [weak self] in
                        self?.deleteButton.setBackgroundImage(UIImage.init(systemName: "trash.slash.fill"), for: .normal)
                        self?.deleteButton.isEnabled = false
                        self?.showAlert(title: "Success", message: "Topic deleted")
                        /// Comunicamos con TopicsViewController para que repinte la tabla
                        guard let deletedTopic: Topic = self?.topic else { return }
                        self?.delegate?.updateTableAfterDelete(deletedTopic: deletedTopic)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showAlert(title: "StatusCode \(response.statusCode)", message: "Couldn't delete the topic")
                    }
                }
            }
        }
        dataTask.resume()
    }
}

