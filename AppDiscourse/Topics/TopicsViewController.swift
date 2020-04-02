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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    // MARK: Funciones
    func setupUI() {
        // Indicamos a la vista que ella controla el dataSource y el delegate
        latestTopics.dataSource = self
        latestTopics.delegate = self
        //Configuraremos el UITableView para que reconozca la clase de la celda
        latestTopics.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: Delegate
extension TopicsViewController: UITableViewDelegate, TopicDetailViewControllerDelegate {
    // Funcion delegada de comunicacion con TopicDetailViewControllerDelegate
    func changes() {
        print("TopicsViewController: func changes")
    }
    // Funcion delegada de UITableViewDelegate para seleccion de celda
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TopicsViewController: didSelectRowAt - pushViewController")
        let detail = TopicDetailViewController.init(cellTapped: indexPath.row)
        detail.delegate = self
        self.navigationController?.pushViewController(detail, animated: true)
        latestTopics.deselectRow(at: indexPath, animated: true)
    }
    // Funcion delegada de UITableViewDelegate para altura de celda
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: DataSource
extension TopicsViewController: UITableViewDataSource {
    // Funcion delegada de UITableViewDataSource para el numero de secciones de cada celda
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Funcion delegada de UITableViewDataSource para el numero de celdas
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    // Funcion delegada de UITableViewDataSource para el repintado de celdas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("TopicsViewController: cellForRowAt - dequeueReusableCell \(indexPath.row)")
        let cell = latestTopics.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
}
