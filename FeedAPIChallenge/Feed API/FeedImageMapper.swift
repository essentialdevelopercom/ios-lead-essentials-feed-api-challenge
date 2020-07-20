//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Hashem Aboonajmi on 7/20/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
    
    private class Root: Decodable {
        let items: [Item]
        var images: [FeedImage] {
            return items.map { $0.item }
        }
    }
    
    private class Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        private enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
        
        var item: FeedImage {
            return FeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == OK_200 , let root = try? JSONDecoder().decode(Root.self, from: data) else {
            
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.images)
    }
}
