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
                FeedImage.init(id: $0.imageId, description: $0.imageDesc, location: $0.imageLoc, url: $0.imageUrl)
            })
        }
    }
    
    private struct FeedImageParseModel: Decodable {
        public let imageId: UUID
        public let imageDesc: String?
        public let imageLoc: String?
        public let imageUrl: URL
        
        public init(id: UUID, description: String?, location: String?, url: URL) {
            self.imageId = id
            self.imageDesc = description
            self.imageLoc = location
            self.imageUrl = url
        }
    }
    
    internal static func getFeedImagesResultFor(data: Data, response: HTTPURLResponse) -> FeedLoader.Result{
        guard response.statusCode == 200,
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
