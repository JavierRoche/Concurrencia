//
//  CategoriesViewController.swift
//  AppDiscourse
//
//  Created by APPLE on 01/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    @IBOutlet weak var categoriesTableView: UITableView!
    
    var categories: [Category] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Categories"
        /// Indicamos a la vista que ella controla el delegate
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        categoriesAPIDiscourseRequest { [weak self] (result) in
            switch result {
            case .success(let categories):
                self?.categories = categories
                self?.categoriesTableView.reloadData()
            case .failure(let error):
                if let errorType = error as? ErrorTypes {
                    switch errorType {
                    case .malformedURL, .malformedData, .statusCode:
                        self?.showAlert(title: "Error", message: errorType.description)
                    }
                } else {
                    self?.showAlert(title: "Server Error", message: error.localizedDescription)
                }
            }
        }
    }
}


// MARK: Delegate
extension CategoriesViewController: UITableViewDelegate {
    /// Funcion delegada de UITableViewDelegate para seleccion de celda
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoriesTableView.deselectRow(at: indexPath, animated: true)
    }

    /// Funcion delegada de UITableViewDelegate para altura de celda
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}


// MARK: DataSource
extension CategoriesViewController: UITableViewDataSource {
    /// Funcion delegada de UITableViewDataSource para el numero de celdas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    /// Funcion delegada de UITableViewDataSource para el repintado de celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = categoriesTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        /*
         cellForRowAt es un método llamado por UIKit y por tanto ejecutado en la main queue. No hace falta llamar a este código
         dentro de main.async
         */
        DispatchQueue.main.async { [weak self] in
            cell.textLabel?.font = UIFont.systemFont(ofSize: 35)
            cell.textLabel?.text = self?.categories[indexPath.row].name
            cell.imageView?.image = UIImage.init(named: "AppImage87")
            cell.setNeedsLayout()
        }
        return cell
    }
}


// MARK: API Request
extension CategoriesViewController {
    func categoriesAPIDiscourseRequest(completion: @escaping (Result<[Category], Error>) -> Void) {
        /// Creamos la URL utilizando el constructor con string, capturamos el posible error
        guard let topicsURL: URL = URL(string: "https://mdiscourse.keepcoding.io/categories.json") else {
            completion(.failure(ErrorTypes.malformedURL))
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
                print("Categories Status Code: \(response.statusCode)")
                    if response.statusCode == 200 {
                        /// Devolvemos el array que contiene los topics recuperados
                        do {
                            let response = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                            DispatchQueue.main.async {
                                completion(.success(response.categoryList.categories))
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
