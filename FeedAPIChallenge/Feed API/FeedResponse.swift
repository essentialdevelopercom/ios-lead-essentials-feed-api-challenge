//
//  FeedResponse.swift
//  FeedAPIChallenge
//
//  Created by Erik Agujari on 14/06/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

struct FeedResponse: Codable {
    let items: [FeedImageResponse]
}

struct FeedImageResponse: Codable {
    let id: String
    let description: String?
    let location: String?
    let urlString: String
    
    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case urlString = "image_url"
    }
}
