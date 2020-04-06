//
//  TopicsViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 31/03/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class TopicsViewController: UIViewController {
    @IBOutlet weak var latestTopics: UITableView!
    
    var topics: [Topic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.latestTopicsAPIDiscourseRequest { [weak self] (result) in
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
    func setupUI() {
        self.title = "Latest Topics"
        /// Indicamos a la vista que ella controla el dataSource y el delegate
        latestTopics.dataSource = self
        latestTopics.delegate = self
        /// Configuraremos el UITableView para que reconozca la clase de la celda
        latestTopics.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        /// Creacion del boton de la barra de navegacion para crear nuevo topic
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(newTopicRightBarButtonItemTapped))
        rightBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func newTopicRightBarButtonItemTapped() {
        print("TopicsViewController: newTopicRightBarButtonItemTapped")
        let newTopicViewController: NewTopicViewController = NewTopicViewController.init()
        /// SIempre hay que indicarle quien sera delegado de los eventos
        newTopicViewController.delegate = self
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: newTopicViewController)
        navigationController.modalPresentationStyle = UIDevice.current.userInterfaceIdiom == .pad ? .formSheet : .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}


// MARK: Delegate
extension TopicsViewController: UITableViewDelegate, TopicComunicationDelegate {
    /// Funcion delegada de comunicacion con TopicComunicationDelegate
    func updateTableAfterDelete(deletedTopic: Topic) {
        /// Eliminamos del array de topics el recien borrado
        let newsTopics: [Topic] = topics.filter { (topic) -> Bool in
            return topic.id != deletedTopic.id
        }
        topics = newsTopics
        latestTopics.reloadData()
    }
    
    /// Funcion delegada de comunicacion con TopicComunicationDelegate
    func updateTableAfterCreate(createdTopic: Topic) {
        /// Introducimos en el array el nuevo topic creado
        topics.insert(createdTopic, at: 0)
        latestTopics.reloadData()
    }
    
    /// Funcion delegada de UITableViewDelegate para seleccion de celda
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail: TopicDetailViewController = TopicDetailViewController.init(topic: topics[indexPath.row])
        /// SIempre hay que indicarle quien sera delegado de los eventos
        detail.delegate = self
        self.navigationController?.pushViewController(detail, animated: true)
        latestTopics.deselectRow(at: indexPath, animated: true)
    }
    
    /// Funcion delegada de UITableViewDelegate para altura de celda
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
        let cell: UITableViewCell = latestTopics.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = topics[indexPath.row].title
        return cell
    }
}


// MARK: API Request
extension TopicsViewController {
    func latestTopicsAPIDiscourseRequest(completion: @escaping (Result<[Topic], Error>) -> Void) {
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let topicsURL: URL = URL(string: "https://mdiscourse.keepcoding.io/latest.json") else {
            completion(.failure(ErrorTypes.malformedURL))
            return
        }
        /// Creamos la request y le asignamos los valores necesarios del API
        var request: URLRequest = URLRequest(url: topicsURL)
        request.httpMethod = "GET"
        request.addValue("699667f923e65fac39b632b0d9b2db0d9ee40f9da15480ad5a4bcb3c1b095b7a", forHTTPHeaderField: "Api-Key")
        request.addValue("Tushe2", forHTTPHeaderField: "Api-Username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        /// La session es un URLSession con una URLSessionConfiguracion por defecto
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        /// La session lanza su URLSessionDatatask con la request
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
                print("Latest Topics Status Code: \(response.statusCode)")
                if response.statusCode == 200 {
                    /// Devolvemos el array que contiene los topics recuperados
                    do {
                        let response = try JSONDecoder().decode(LatestTopicsResponse.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(response.topicList.topics))
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
