//
//  FeedItemsMapper.swift
//  FeedAPIChallenge
//
//  Created by Valentin Šarić on 25/10/2020.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal class FeedItemsMapper{
    private struct FeedImagesResponse: Decodable{
        private let items: [FeedImageParseModel]
        
        internal func mapToFeedImages() -> [FeedImage]{
            return items.map({
                FeedImage.init(id: $0.imageId,
                               description: $0.imageDesc,
                               location: $0.imageLoc,
                               url: $0.imageUrl)
            })
        }
    }
    
    private struct FeedImageParseModel: Decodable {
        internal let imageId: UUID
        internal let imageDesc: String?
        internal let imageLoc: String?
        internal let imageUrl: URL
    }
    
    private static let OK_200 = 200
    
    internal static func getFeedImagesResultFor(data: Data, response: HTTPURLResponse) -> FeedLoader.Result{
        guard response.statusCode == OK_200,
              let data = decodeFeedImagesResponseFrom(data: data)
        else{
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(data.mapToFeedImages())
    }
    
    private static func decodeFeedImagesResponseFrom(data: Data) -> FeedImagesResponse?{
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(FeedImagesResponse.self, from: data)
    }
}
