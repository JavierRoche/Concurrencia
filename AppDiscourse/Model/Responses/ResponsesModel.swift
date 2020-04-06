//
//  LatestTopicsResponse.swift
//  AppDiscourse
//
//  Created by APPLE on 02/04/2020.
//  Copyright © 2020 Javier Roche. All rights reserved.
//

import Foundation

// MARK: Latest Topics Response Model
struct LatestTopicsResponse: Codable {
    let topicList: TopicList
    enum CodingKeys: String, CodingKey {
        case topicList = "topic_list"
    }
}

struct TopicList: Codable {
    let topics: [Topic]
}

struct Topic: Codable {
    var id: Int
    var title: String?
    let postCount: Int?
    let topicID: Int?
    let topicSlug: String?
    let details: Detail?
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case postCount = "posts_count"
        case topicID = "topic_id"
        case topicSlug = "topic_slug"
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
