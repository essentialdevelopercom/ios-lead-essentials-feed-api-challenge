//
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageMapper {
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        var item: FeedImage {
            FeedImage(id: id,
                      description: description,
                      location: location,
                      url: url)
            
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
        
    }
    
    private struct RootNode: Decodable {
        let items: [Item]
        
        var images: [FeedImage] {
            items.map { $0.item }
        }
        
    }
    
    private enum StatusCodes: Int {
        case success = 200
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == StatusCodes.success.rawValue, let feedImages = try? JSONDecoder().decode(RootNode.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(feedImages.images)
    }
}
