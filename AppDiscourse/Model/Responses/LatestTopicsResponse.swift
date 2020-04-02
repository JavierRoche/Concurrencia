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
///"users": [
///    "id": 0,
///    "username": "string",
///    "avatar_template": "string"
///],
///"topic_list": {
///    "can_create_topic": true,
///    "draft": { },
///    "draft_key": "string",
///    "draft_sequence": { },
///    "per_page": 0,
///    "topics": [
///            "id": 0,
///            "title": "string",
///            "fancy_title": "string",
///            "slug": "string",
///            "posts_count": 0,
///            "reply_count": 0,
///            "highest_post_number": 0,
///            "image_url": { },
///            "created_at": "string",
///            "last_posted_at": "string",
///            "bumped": true,
///            "bumped_at": "string",
///            "unseen": true,
///            "pinned": true,
///            "unpinned": { },
///            "excerpt": "string",
///            "visible": true,
///            "closed": true,
///            "archived": true,
///            "bookmarked": { },
///            "liked": { },
///            "views": 0,
///            "like_count": 0,
///            "has_summary": true,
///            "archetype": "string",
///            "last_poster_username": "string",
///            "category_id": 0,
///            "pinned_globally": true,
///            "posters": []
///    ]
