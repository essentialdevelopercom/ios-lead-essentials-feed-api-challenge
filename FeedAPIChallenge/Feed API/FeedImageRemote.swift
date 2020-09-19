//
//  FeedImageRemote.swift
//  FeedAPIChallenge
//
//  Created by Danil on 9/20/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

public struct FeedImageRemote: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    init(from model: FeedImage) {
        self.id = model.id
        self.description = model.description
        self.location = model.location
        self.url = model.url
    }
    
    var toFeedImage: FeedImage {
        .init(id: id, description: description, location: location, url: url)
    }
}
