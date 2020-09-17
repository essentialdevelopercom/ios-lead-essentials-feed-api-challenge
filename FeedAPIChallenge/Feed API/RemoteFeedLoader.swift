//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
		
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            if case let .success((data, httpURLResponse)) = result {
                let result = Result { try FeedImageMapper.map(data, httpURLResponse) }
                completion(result)
            
            } else if case .failure = result {
                completion(.failure(RemoteFeedLoader.Error.connectivity))
                
            }
        }
    }
}

class FeedImageMapper {
    private struct RemoteFeedImageItems: Decodable {
        let items: [RemoteFeedImage]
    }

    private struct RemoteFeedImage: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
    
    static func map(_ data: Data, _ httpURLResponse: HTTPURLResponse) throws -> [FeedImage] {
        guard httpURLResponse.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        do {
            let items = try JSONDecoder().decode(RemoteFeedImageItems.self, from: data)
            let feedImages = items.items.map(toModel(_:))
            return feedImages
            
        } catch {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
    
    private static func toModel(_ item: RemoteFeedImage) -> FeedImage {
        return FeedImage(id: item.id,
                         description: item.description,
                         location: item.location,
                         url: item.url)
    }
}
