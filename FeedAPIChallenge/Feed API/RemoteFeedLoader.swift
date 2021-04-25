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
        client.get(from: url, completion: { [weak self] in
            guard self != nil else { return }
            
            switch $0 {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success((_, let response)) where response.statusCode != 200:
                completion(.failure(Error.invalidData))
            case .success((let data, _)):
                do {
                    let response = try JSONDecoder()
                        .decode(Response.self, from: data)

                    completion(.success(response.toFeed()))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            }
        })
    }
}

private struct Response: Decodable {
    struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL

        func toFeedImage() -> FeedImage {
            FeedImage(
                id: image_id,
                description: image_desc,
                location: image_loc,
                url: image_url
            )
        }
    }

    let items: [Item]

    func toFeed() -> [FeedImage] {
        items.map({ $0.toFeedImage() })
    }
}
