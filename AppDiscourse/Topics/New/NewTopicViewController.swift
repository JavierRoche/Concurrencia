//
//  NewTopicViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 05/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class NewTopicViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var postTextField: UITextView!
    @IBOutlet weak var submitPostButton: UIButton!
    
    weak var delegate: TopicComunicationDelegate?
    
    convenience init() {
        self.init(nibName: "NewTopicViewController", bundle: nil)
        self.title = "Create Topic"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Creacion del boton de la barra de navegacion para ir hacia atras
        let closeRightBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(closeViewRightBarButtonItemTapped))
        closeRightBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = closeRightBarButtonItem
        
        titleTextField?.delegate = self
        titleTextField?.keyboardType = UIKeyboardType.alphabet
        titleTextField?.keyboardAppearance = UIKeyboardAppearance.default
        titleTextField?.returnKeyType = .done
        postTextField?.delegate = self
        postTextField?.keyboardType = UIKeyboardType.alphabet
        postTextField?.keyboardAppearance = UIKeyboardAppearance.default
        postTextField?.returnKeyType = .send
        postTextField?.layer.borderColor = CGColor.init(srgbRed: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 0.75)
        postTextField?.layer.borderWidth = 1.0;
        postTextField?.layer.cornerRadius = 5.0;
    }
    
    
    // MARK: IBActions
    @IBAction func submitNewTopicTapped(_ sender: Any) {
        self.newTopicAPIDiscourseRequest { [weak self] (result) in
            switch result {
            case .success(let topic):
                /// Creacion correcta del topic avisamos al TopicViewController para que repinte la tabla
                guard let title: String = self?.titleTextField.text else { return }
                let details: Detail = Detail(canDelete: false)
                let newTopic: Topic = Topic(id: topic.topicID!, title: title, postCount: 1, topicID: topic.topicID, topicSlug: topic.topicSlug, details: details)
                self?.delegate?.updateTableAfterCreate(createdTopic: newTopic)
                /// Cerramos el NewTopicViewController presentado
                self?.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    if let errorType = error as? ErrorTypes {
                        switch errorType {
                        case .malformedURL, .malformedData, .statusCode:
                            self?.showAlert(title: "Error", message: errorType.description)
                        }
                    } else if let errorType = error as? DiscourseAPIError {
                        let message: String = (errorType.errors?.joined(separator: "\n"))!
                        self?.showAlert(title: String(errorType.action ?? "Error"), message: message)
                    } else {
                        self?.showAlert(title: "Server Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc func closeViewRightBarButtonItemTapped() {
        print("TopicsViewController: closeViewRightBarButtonItemTapped")
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: Delegate (Hiding Keyboard)
extension NewTopicViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}


// MARK: API Request
extension NewTopicViewController {
    func newTopicAPIDiscourseRequest(completion: @escaping (Result<Topic, Error>) -> Void) {
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let discourseURL: URL = URL.init(string: "https://mdiscourse.keepcoding.io/posts.json") else {
            DispatchQueue.main.async {
                completion(.failure(ErrorTypes.malformedURL))
            }
            return
        }
        /// Esta request POST necesita de un body que se incluye en la request serializado
        guard let titleText: String = titleTextField?.text, let postText: String = postTextField?.text else { return }
        let body: [String: String] = [
            "title": titleText,
            "raw": postText
        ]
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest(url: discourseURL)
        guard let dataBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = dataBody
        request.httpMethod = "POST"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession.init(configuration: configuration)
        
        /// La session lanza su URLSessionDataTask con la request. Esta bloquea el hilo principal por el acceso a la red
        DispatchQueue.global(qos: .utility).async {
            let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    /// Devolvemos el tipo Error con los errores de servicio API
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
                if let response = response as? HTTPURLResponse, let data = data {
                    print("New Topic Status Code: \(response.statusCode)")
                    if response.statusCode > 400 {
                        /// Tenemos una estructura para decodificar la respuesta a mostrar
                        do {
                            let errorResponse = try JSONDecoder().decode(DiscourseAPIError.self, from: data)
                            DispatchQueue.main.async {
                                completion(.failure(errorResponse))
                            }
                        /// Devolvemos el tipo Error para la no decodificacion de la response
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(ErrorTypes.malformedData))
                            }
                        }
                    } else {
                        /// Devolvemos el topic recien creado
                        do {
                            let response = try JSONDecoder().decode(Topic.self, from: data)
                            DispatchQueue.main.async {
                                completion(.success(response))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(ErrorTypes.malformedData))
                            }
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
}
