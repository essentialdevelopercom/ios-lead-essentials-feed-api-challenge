//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Rakesh Ramamurthy on 19/10/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
    private struct Root: Decodable {
        let items: [ImageItem]
        
        var feed: [FeedImage] {
            return items.map { $0.item }
        }
    }

    private struct ImageItem: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        
        var item: FeedImage {
            return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }

    private static var OK_HTTP_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_HTTP_200,
        let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feed)
    }
}
