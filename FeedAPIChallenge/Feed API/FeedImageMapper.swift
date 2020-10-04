//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Maxim Soldatov on 04.10.2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedItemsMapper {
    
    private static var OK_200: Int { return 200 }
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedImage] {
            return items.map({ $0.item })
        }
    }

    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        
        var item: FeedImage {
            return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
    
    internal static func map(_ data: Data, form response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
