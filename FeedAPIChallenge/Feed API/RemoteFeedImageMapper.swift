//
//  RemoteFeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Gustavo Londono on 8/5/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct RemoteFeedImageMapper {
    private struct Root: Decodable {
        var items: [FeedImage]
    }
    
    static func mapFeedImage(data: Data, httpResponse: HTTPURLResponse) -> FeedLoader.Result {
        guard httpResponse.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.items)
    }
}
