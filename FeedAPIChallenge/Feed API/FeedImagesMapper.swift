//
//  FeedImagesMapper.swift
//  FeedAPIChallenge
//
//  Created by Gustavo Arthur Vollbrecht on 29/10/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImagesMapper {
    
    private struct Item : Decodable {
        public let image_id : UUID
        public let image_desc : String?
        public let image_loc : String?
        public let image_url : URL
        
        var feedImage : FeedImage {
            return FeedImage(id: self.image_id,
                             description: self.image_desc,
                             location: self.image_loc,
                             url: self.image_url)
        }
    }

    private struct Root : Decodable {
        private let items : [Item]
        
        var images : [FeedImage] {
            return self.items.map { $0.feedImage }
        }
    }
    
    private static var successStatusCode : Int { return 200 }
    
    static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == successStatusCode, let root = try? JSONDecoder().decode(Root.self, from: data)
        else { return .failure(RemoteFeedLoader.Error.invalidData) }
        
        return .success(root.images)
    }
}
