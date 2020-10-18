//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Carlos Linares on 18/10/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

class FeedImagesMapper {
    
    static private var Ok200HTTPStatusCode = 200
    
    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard valid200HTTPResponse(from: response),
              let items = decodeFeedImages(from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(items.feedImages)
    }
    
    static private func valid200HTTPResponse(from response: HTTPURLResponse) -> Bool {
        response.statusCode == Ok200HTTPStatusCode
    }
    
    static private func decodeFeedImages(from data: Data) -> Root? {
        try? JSONDecoder().decode(Root.self, from: data)
    }
    
    private struct Root: Decodable {
        let items: [FeedImageItem]
        
        var feedImages: [FeedImage] {
            items.map { FeedImage(id: $0.id,
                                  description: $0.description,
                                  location: $0.location,
                                  url: $0.url) }
        }
    }

    private struct FeedImageItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
}
