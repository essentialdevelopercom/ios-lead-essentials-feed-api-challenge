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
            guard self != nil  else { return }
            switch result {
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            case let .success((data, response)):
                guard response.statusCode == 200,
                      let root = try? JSONDecoder().decode(Root.self, from: data) else {
                        completion(.failure(RemoteFeedLoader.Error.invalidData))
                        return
                    }
                completion(.success(root.imageItems))
            }
        }
    }
}

private struct Root:Decodable {
    
    let items:[FeedImageResponse]
    
    struct FeedImageResponse:Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
    }
    
    var imageItems:[FeedImage] {
        return items.map {
            FeedImage(
                id: $0.image_id,
                description: $0.image_desc,
                location: $0.image_loc,
                url: $0.image_url)
        }
    }
}

