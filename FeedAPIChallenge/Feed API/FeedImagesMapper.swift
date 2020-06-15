//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Nicolas Cadena on 15/06/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
    // MARK: - Structs
    private struct StatusCodeConstants {
        static var code200 = 200
    }

    private struct Root: Decodable {
        let items: [ImageItem]
        
        var feed: [FeedImage] {
            return items.map { $0.feedImageItem }
        }
    }

    private struct ImageItem: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        
        var feedImageItem: FeedImage {
            return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
    
    // MARK: - Functions
    internal static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == StatusCodeConstants.code200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
