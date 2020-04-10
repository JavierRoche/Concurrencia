//
//  UsersTableViewCell.swift
//  AppDiscourse
//
//  Created by APPLE on 09/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        avatarImage.layer.cornerRadius = 8
        avatarImage.layer.borderColor  = UIColor.white.withAlphaComponent(0.2).cgColor
        avatarImage.layer.borderWidth  = 1.0
    }
    
    
    //MARK: Functions
    func setCell(user: User) {
        let url: String = "https://mdiscourse.keepcoding.io\(user.avatarTemplate)"
        let avatarURL: String = url.replacingOccurrences(of: "{size}", with: "80")

        /// Comienza la ejecucion concurrente porque bloquea el hilo principal por el acceso a la red
        DispatchQueue.global(qos:.userInitiated).async { [weak self] in
            guard let urlAvatar: URL = URL(string: avatarURL) else { return }
            guard let data = try? Data(contentsOf: urlAvatar) else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self?.avatarImage.image = image
                self?.idLabel.text  = "User ID: \(user.id)"
                self?.usernameLabel.text = user.username
                self?.nameLabel.text = user.name
            }
        }
    }
}
