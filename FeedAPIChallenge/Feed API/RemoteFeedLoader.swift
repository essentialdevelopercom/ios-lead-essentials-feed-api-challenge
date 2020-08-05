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
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(FeedImagesMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

class FeedImagesMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feedImages: [FeedImage] {
            return items.map { FeedImage(id: $0.image_id,
                                         description: $0.image_desc,
                                         location: $0.image_loc,
                                         url: $0.image_url) }
        }
    }
    
    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
    }

    static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200, let json = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(json.feedImages)
    }
}
