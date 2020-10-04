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
        client.get(from: self.url) { result in
            switch result {
            case let .success((data, response)):
                completion(RemoteFeedImageMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

final class RemoteFeedImageMapper {
    
    static var validHTTPResponseCode: Int = 200
    
    private struct RemoteFeedImageRoot: Decodable {
        
        var items: [RemoteFeedImage]
        
        var feedItems: [FeedImage] {
            items.map { $0.feedImage }
        }
    }

    private struct RemoteFeedImage: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var url: URL
        
        var feedImage: FeedImage {
            return FeedImage(id: id,
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
    
    static func map(_ data: Data,
                    from response: HTTPURLResponse) -> FeedLoader.Result {
        
        guard response.statusCode == validHTTPResponseCode,
              let items = try? JSONDecoder().decode(RemoteFeedImageRoot.self, from: data).feedItems else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(items)
    }
}
