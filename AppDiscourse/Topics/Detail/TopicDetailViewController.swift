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

    weak var delegate: TopicDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    convenience init(cellTapped: Int) {
        self.init(nibName: "TopicDetailViewController", bundle: nil)
        self.title = "Topic"
    }
    
    @IBAction func addOneButttonTapped(_ sender: Any) {
        print("addOneButttonTapped")
        delegate?.changes()
    }
}
