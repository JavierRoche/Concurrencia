//
//  TopicDetailViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 01/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

// MARK: Protocolo de comunicacion
protocol TopicDetailViewControllerDelegate: class {
    func changes()
}

class TopicDetailViewController: UIViewController {
    @IBOutlet weak var idTopicLabel: UILabel!
    @IBOutlet weak var titleTopicLabel: UILabel!
    @IBOutlet weak var postNumberTopicLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    let cn200: Int = 200
    private var topic: Topic?
    weak var delegate: TopicDetailViewControllerDelegate?
    
    convenience init(topic: Topic) {
        print("TopicDetailViewController: func init")
        self.init(nibName: "TopicDetailViewController", bundle: nil)
        self.topic = topic
    }
    
    override func viewDidLoad() {
        print("TopicDetailViewController: func viewDidLoad")
        super.viewDidLoad()
        self.setupUI()
        self.setupData { [weak self] (result) in
            switch result {
            case .success(let topic):
                print("resul pattern - success")
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
                    }
                } else {
                    self?.showAlert(title: "Server Error", message: error.localizedDescription)
                }
            }
        }
    }


    // MARK: Funciones
    func setupUI() {
        print("TopicDetailViewController: func setupUI")
        self.title = "Topic"
        idTopicLabel.text = "Topic ID:\(topic?.id ?? 0)"
        titleTopicLabel.text = topic?.title
        postNumberTopicLabel.text = "Nº post: \(topic?.postCount ?? 0)"
    }
    
    func setupData(completion: @escaping (Result<Topic, Error>) -> Void) {
        print("TopicDetailViewController: func setupData")
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let topicID = self.topic?.id, let discourseURL = URL(string: "https://mdiscourse.keepcoding.io/t/\(topicID).json") else {
            completion(.failure(ErrorTypes.malformedURL))
            return
        }
        /// Creamos la request y le asignamos los valores necesarios del API
        var request = URLRequest(url: discourseURL)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe2", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration = URLSessionConfiguration.default
        let session = URLSession.init(configuration: configuration)
        /// La session lanza su datatask con la request
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            /// El parametro error tiene errores de servicio con el servidor
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
            if let response = response as? HTTPURLResponse, let data = data {
                print("Topic Status Code: \(response.statusCode)")
                if response.statusCode == self.cn200 {
                    do {
                        let response = try JSONDecoder().decode(SingleTopicResponse.self, from: data)
                        print("\(response.id)\n\(response.title)\n\(response.postCount)")
                        /// Permitiremos borrar el topic solo si el parametro can_delete existe y es true
                        let canDelete: Bool = response.details.canDelete ?? false
                        let image: String = canDelete ? "trash.fill" : "trash.slash.fill"
                        let trashType = UIImage.init(systemName: image)
                        DispatchQueue.main.async {
                            self.deleteButton.setBackgroundImage(trashType, for: .normal)
                            self.deleteButton.isEnabled = canDelete
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
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        print("deleteButtonTapped")
        delegate?.changes()
    }
}
