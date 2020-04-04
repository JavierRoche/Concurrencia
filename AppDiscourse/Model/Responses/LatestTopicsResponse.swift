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
    let id: Int
    let title: String
    let postCount: Int
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case postCount = "posts_count"
    }
}



// MARK: API Response Sample
// https://docs.discourse.org
