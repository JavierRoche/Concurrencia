//
//  SingleTopicResponse.swift
//  AppDiscourse
//
//  Created by APPLE on 03/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import Foundation

// MARK: Single Topics Response Model
struct SingleTopicResponse: Codable {
    let id: Int
    let title: String
    let postCount: Int
    let details: Detail
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case postCount = "posts_count"
        case details
    }
}

struct Detail: Codable {
    let canDelete: Bool?
    enum CodingKeys: String, CodingKey {
        case canDelete = "can_delete"
    }
}



// MARK: API Response Sample
// https://docs.discourse.org
