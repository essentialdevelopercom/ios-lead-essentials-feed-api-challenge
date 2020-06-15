//
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImagesMapper {
    static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data)
            else { return .failure(RemoteFeedLoader.Error.invalidData) }
        
        return .success(root.feed)
    }
    
    private static var OK_200: Int { return 200 }
    
    private struct Item: Decodable {
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
    }
    
    private struct Root: Decodable {
        private let items: [Item]
        
        var feed: [FeedImage] {
            return items.map {
                FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
            }
        }
    }
}
