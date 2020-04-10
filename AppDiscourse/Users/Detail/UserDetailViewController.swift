//
//  UserDetailViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 07/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {
    @IBOutlet weak var idUserLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var updateNameButton: UIButton!
    
    private var user: User?
    weak var delegate: UsersComunicationDelegate?
    
    convenience init(user: User) {
        self.init(nibName: "UserDetailViewController", bundle: nil)
        self.user = user
        self.title = "User"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { [weak self] in
            self?.nameTextField.delegate = self
            self?.nameTextField.keyboardType = UIKeyboardType.alphabet
            self?.nameTextField.keyboardAppearance = UIKeyboardAppearance.default
            self?.nameTextField.returnKeyType = .done
        }
        
        self.singleUserAPIDiscourseRequest { [weak self] (result) in
            switch result {
            case .success(let user):
                self?.user = user
                
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
    func configureUI(users: Users) {
        /// En el caso de que no se haya recuperado canDelete y sea nil le damos valor false
        if users.user.canEditName ?? false {
            /// Permitiremos borrar el topic solo si el parametro can_delete existe y es true
            guard let canUpdate: Bool = users.user.canEditName else { return }
            DispatchQueue.main.async { [weak self] in
                self?.updateNameButton.isEnabled = canUpdate
                self?.nameLabel.isHidden = canUpdate
                self?.nameTextField.isHidden = !canUpdate
                
                self?.idUserLabel.text = "User ID:\(users.user.id)"
                self?.userNameLabel.text = "Username: \(users.user.username)"
                self?.nameTextField.text = users.user.name
            }
            
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.updateNameButton.isEnabled = false
                self?.nameLabel.isHidden = false
                self?.nameTextField.isHidden = true
                
                self?.idUserLabel.text = "User ID :\(users.user.id)"
                self?.userNameLabel.text = "Username: \(users.user.username)"
                self?.nameLabel.text = users.user.name
            }
        }
    }
}


// MARK: Delegate (Hiding Keyboard)
extension UserDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: API Request
extension UserDetailViewController {
    func singleUserAPIDiscourseRequest(completion: @escaping (Result<User, Error>) -> Void) {
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let discourseURL: URL = URL(string: "https://mdiscourse.keepcoding.io/users/\(self.user?.username ?? "keepcoding").json") else {
            DispatchQueue.main.async {
                completion(.failure(ErrorTypes.malformedURL))
            }
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
                    if response.statusCode == 200 {
                        do {
                            let response = try JSONDecoder().decode(Users.self, from: data)
                            self?.configureUI(users: response)
                            
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
        guard let username: String = self.user?.username, let discourseURL: URL = URL(string: "https://mdiscourse.keepcoding.io/users/\(username).json") else {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(title: "Error", message: ErrorTypes.malformedURL.description)
            }
            return
        }
        /// Esta request POST necesita de un body que se incluye en la request serializado
        guard let nameText: String = nameTextField?.text else { return }
        let body: [String: String] = [
            "name": "\(nameText)"
        ]
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest(url: discourseURL)
        guard let dataBody = try? JSONSerialization.data(withJSONObject: body) else {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(title: "Error", message: ErrorTypes.malformedData.description)
            }
            return
        }
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
                        guard let updatedUser: User = self?.user else { return }
                        self?.delegate?.updateTableAfterDelete(modifiedUser: updatedUser)
                        DispatchQueue.main.async {
                            self?.nameLabel.text = self?.nameTextField.text
                            self?.nameLabel.isHidden = false
                            self?.nameTextField.isHidden = true
                            self?.updateNameButton.isEnabled = false
                            self?.showAlert(title: "Success", message: "User's name updated")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showAlert(title: "StatusCode \(response.statusCode)", message: "Couldn't update the user")
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }
}
