//
//  TopicDetailViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 01/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class TopicDetailViewController: UIViewController {
    @IBOutlet weak var idTopicLabel: UILabel!
    @IBOutlet weak var titleTopicLabel: UILabel!
    @IBOutlet weak var postNumberTopicLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var titleTopicTextView: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
    private var topic: Topic?
    weak var delegate: TopicComunicationDelegate?
    
    convenience init(topic: Topic) {
        self.init(nibName: "TopicDetailViewController", bundle: nil)
        self.topic = topic
        self.title = "Topic"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            self?.titleTopicTextView?.delegate = self
            self?.titleTopicTextView?.keyboardType = UIKeyboardType.alphabet
            self?.titleTopicTextView?.keyboardAppearance = UIKeyboardAppearance.default
            self?.titleTopicTextView?.returnKeyType = .done
            self?.titleTopicTextView?.layer.borderColor = CGColor.init(srgbRed: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 0.75)
            self?.titleTopicTextView?.layer.borderWidth = 1.0;
            self?.titleTopicTextView?.layer.cornerRadius = 5.0;
        }
        
        self.singleTopicAPIDiscourseRequest { [weak self] (result) in
            switch result {
            case .success(let topic):
                self?.topic = topic
                
            case .failure(let error):
                if let errorType = error as? ErrorTypes {
                    switch errorType {
                    case .malformedURL, .malformedData, .statusCode:
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Error", message: errorType.description)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Server Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: Functions
    func configureUI(topic: Topic) {
        DispatchQueue.main.async { [weak self] in
            self?.idTopicLabel.text = "Topic ID: \(topic.id)"
            self?.titleTopicLabel.text = topic.title
            self?.titleTopicTextView.text = topic.title
            self?.postNumberTopicLabel.text = "Nº posts: \(topic.postCount ?? 0)"
        }
        
        /// En el caso de que no se haya recuperado canDelete no permite borrar
        if topic.details?.canDelete ?? false {
            /// Permitiremos borrar el topic solo si el parametro can_delete existe y es true
            guard let canDelete: Bool = topic.details?.canDelete else { return }
            let image: String = canDelete ? "trash.fill" : "trash.slash.fill"
            let trashType = UIImage.init(systemName: image)
            DispatchQueue.main.async { [weak self] in
                self?.deleteButton.setBackgroundImage(trashType, for: .normal)
                self?.deleteButton.isEnabled = canDelete
            }
            
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.deleteButton.setBackgroundImage(UIImage.init(systemName: "trash.slash.fill"), for: .normal)
                self?.deleteButton.isEnabled = false
            }
        }
        
        /// En el caso de que no se haya recuperado canEdit no permite editar
        if topic.details?.canEdit ?? false {
            /// Permitiremos editar el topic solo si el parametro can_edit existe y es true
            guard let canEdit: Bool = topic.details?.canEdit else { return }
            let image: String = canEdit ? "pencil" : "pencil.slash"
            let pencilType = UIImage.init(systemName: image)
            DispatchQueue.main.async { [weak self] in
                self?.updateButton.setBackgroundImage(pencilType, for: .normal)
                self?.updateButton.isEnabled = canEdit
                self?.titleTopicLabel.isHidden = canEdit
                self?.titleTopicTextView.isHidden = !canEdit
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.updateButton.setBackgroundImage(UIImage.init(systemName: "pencil.slash"), for: .normal)
                self?.updateButton.isEnabled = false
                self?.titleTopicLabel.isHidden = false
                self?.titleTopicTextView.isHidden = true
            }
        }
    }
}


// MARK: Delegate (Hiding Keyboard)
extension TopicDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}


// MARK: API Request
extension TopicDetailViewController {
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
        request.addValue("Tushe", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession.init(configuration: configuration)
        
        /// La session lanza su URLSessionDataTask con la request. Esta bloquea el hilo principal por el acceso a la red
        DispatchQueue.global(qos: .utility).async { [weak self] in
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
                            self?.configureUI(topic: response)
                            
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
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let topicID: Int = self.topic?.id, let discourseURL: URL = URL(string: "https://mdiscourse.keepcoding.io/t/-/\(topicID).json") else {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(title: "Error", message: ErrorTypes.malformedURL.description)
            }
            return
        }
        /// Esta request POST necesita de un body que se incluye en la request serializado
        guard let titleText: String = titleTopicTextView?.text else { return }
        let body: [String: Any] = [
            "title": titleText,
            "category_id": 0
        ]
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest(url: discourseURL)
        guard let dataBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = dataBody
        request.httpMethod = "PUT"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession.init(configuration: configuration)

        /// La session lanza su URLSessionDataTask con la request. Esta bloquea el hilo principal por el acceso a la red
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                /// El parametro error tiene errores de servicio con el servidor
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                    return
                }
                /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        /// Comunicamos con TopicsViewController para que repinte la tabla
                        self?.topic?.title = titleText
                        guard let modifiedTopic: Topic = self?.topic else { return }
                        self?.delegate?.updateTableAfterUpdate(updatedTopic: modifiedTopic)
                        DispatchQueue.main.async {
                            self?.titleTopicLabel.text = titleText
                            self?.titleTopicLabel.isHidden = false
                            self?.titleTopicTextView.isHidden = true
                            self?.updateButton.isEnabled = false
                            self?.showAlert(title: "Success", message: "Topic's name modified!")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Statuscode \(response.statusCode)", message: response.description)
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let topicID: Int = self.topic?.id, let discourseURL: URL = URL(string: "https://mdiscourse.keepcoding.io/t/\(topicID).json") else {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(title: "Error", message: ErrorTypes.malformedURL.description)
            }
            return
        }
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest.init(url: discourseURL)
        request.httpMethod = "DELETE"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession.init(configuration: configuration)
        
        /// La session lanza su URLSessionDataTask con la request. Esta bloquea el hilo principal por el acceso a la red
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
                /// El parametro error tiene errores de servicio con el servidor
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                    return
                }
                /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        /// Comunicamos con TopicsViewController para que repinte la tabla
                        guard let deletedTopic: Topic = self?.topic else { return }
                        self?.delegate?.updateTableAfterDelete(deletedTopic: deletedTopic)
                        /// Desabilitamos el boton para uso obligado del boton de navegacion
                        DispatchQueue.main.async {
                            self?.deleteButton.setBackgroundImage(UIImage.init(systemName: "trash.slash.fill"), for: .normal)
                            self?.deleteButton.isEnabled = false
                            self?.showAlert(title: "Success", message: "Topic deleted!")
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "StatusCode \(response.statusCode)", message: "Couldn't delete the topic")
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
}

