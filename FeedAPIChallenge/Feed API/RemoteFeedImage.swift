//
//  RemoteFeedImage.swift
//  FeedAPIChallenge
//
//  Created by Jean Mouton on 26/11/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct RemoteFeedImage {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
}

extension RemoteFeedImage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
}
