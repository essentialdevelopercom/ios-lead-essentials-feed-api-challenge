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
            case id
            case description
            case location
            case url
        }
        
        var item: FeedImage {
            return FeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard let _ = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), response.statusCode == OK_200 else {
            
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
         return .success([])
    }
}
