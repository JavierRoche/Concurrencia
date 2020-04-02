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
                print(error.localizedDescription)
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
        //OJO FALTA CAPTURAR EL ERROR
        guard let topicsURL = URL(string: "https://mdiscourse.keepcoding.io/latest.json") else { return }
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
            /// El parametro error tiene errores de servicio con el servidor
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            /// Si ha habido respuesta y la podemos recibir como HTTPURLResponse y ademas hay datos
            if let response = response as? HTTPURLResponse, let data = data {
                print("Status Code: \(response.statusCode)")
                if response.statusCode == self.cn200 {
                    guard let response = try? JSONDecoder().decode(LatestTopicsResponse.self, from: data) else {
                        print("JSONDecoder failed")
                        return
                    }
                    print("JSONDecoder success")
                    DispatchQueue.main.async {
                        completion(.success(response.topicList.topics))
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
