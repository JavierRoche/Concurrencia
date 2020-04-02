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
        self.setupData()
    }


    // MARK: Funciones
    func setupUI() {
        print("TopicDetailViewController: func setupUI")
        self.title = "Topic: \(topic?.id ?? 0))"
    }
    
    func setupData() {
        print("TopicDetailViewController: func setupData")
    }
    
    @IBAction func addOneButttonTapped(_ sender: Any) {
        print("addOneButttonTapped")
        delegate?.changes()
    }
}
