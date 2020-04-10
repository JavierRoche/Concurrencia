//
//  UsersViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 01/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

// MARK: Views Comunication Protocol
protocol UsersComunicationDelegate: class {
    func updateTableAfterDelete(modifiedUser: User)
}


class UsersViewController: UIViewController {
    @IBOutlet weak var usersList: UITableView!
    
    var users: [Users] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.setupUI()
        self.setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupData()
    }
        
    
    // MARK: Functions
    func setupUI() {
        /// Registramos en el UITableView el tipo de celda que contendra
        let nib: UINib = UINib.init(nibName: "UsersTableViewCell", bundle: nil)
        self.usersList.register(nib, forCellReuseIdentifier: "UsersTableViewCell")
        
        self.title = "Users"
        /// Indicamos a la vista que ella controla el dataSource y el delegate
        usersList.dataSource = self
        usersList.delegate = self
        /// Configuraremos el UITableView para que reconozca la clase de la celda
        usersList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setupData() {
        self.userListAPIDiscourseRequest { [weak self] (result) in
            switch result {
            case .success(let array):
                self?.users = array.directoryItems
                self?.usersList.reloadData()
                    
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
}


// MARK: Delegate
extension UsersViewController: UITableViewDelegate, UsersComunicationDelegate {
    /// Funcion delegada de comunicacion con TopicComunicationDelegate
    func updateTableAfterDelete(modifiedUser: User) {
        usersList.reloadData()
    }

    /// Funcion delegada de UITableViewDelegate para seleccion de celda
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail: UserDetailViewController = UserDetailViewController.init(user: users[indexPath.row].user)
        /// SIempre hay que indicarle quien sera delegado de los eventos
        detail.delegate = self
        self.navigationController?.pushViewController(detail, animated: true)
        usersList.deselectRow(at: indexPath, animated: true)
    }

    /// Funcion delegada de UITableViewDelegate para altura de celda
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}


// MARK: DataSource
extension UsersViewController: UITableViewDataSource {
    /// Funcion delegada de UITableViewDataSource para el numero de secciones de cada celda
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    /// Funcion delegada de UITableViewDataSource para el numero de celdas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
        
    /// Funcion delegada de UITableViewDataSource para el repintado de celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Obligamos a que la celda se cree con el tipo UsersTableViewCell
        if let cell = usersList.dequeueReusableCell(withIdentifier: "UsersTableViewCell", for: indexPath) as? UsersTableViewCell {
            cell.setCell(user: users[indexPath.row].user)
            cell.setNeedsLayout()
            return cell
        }
        fatalError("No se pueden crear las celdas")
    }
}


// MARK: API Request
extension UsersViewController {
    func userListAPIDiscourseRequest(completion: @escaping (Result<UsersDirectoryResponse, Error>) -> (Void)) {
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let topicsURL: URL = URL(string: "https://mdiscourse.keepcoding.io/directory_items.json?period=all&order=topics_entered") else {
            DispatchQueue.main.async {
                completion(.failure(ErrorTypes.malformedURL))
            }
            return
        }
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest(url: topicsURL)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
            
        /// La session lanza su URLSessionDatatask con la request. Esta bloquea el hilo principal por el acceso a la red
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
                        print("Users Status Code: \(response.statusCode)")
                        if response.statusCode == 200 {
                            /// Devolvemos el array que contiene los topics recuperados
                            do {
                                let response = try JSONDecoder().decode(UsersDirectoryResponse.self, from: data)
                                DispatchQueue.main.async {
                                    completion(.success(response))
                                }
                            /// Devolvemos el tipo Error para la no decodificacion de la response
                            } catch {
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
    }
