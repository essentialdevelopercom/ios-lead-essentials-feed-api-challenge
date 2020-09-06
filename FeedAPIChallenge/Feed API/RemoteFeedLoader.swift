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
        client.get(from: url, completion: { result in
            switch result {
            case let .success((data, response)):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                } else if (try? JSONSerialization.jsonObject(with: data)) != nil {
                    if let root = try? JSONDecoder().decode(Root.self, from: data) {
                        completion(.success(root.items.toModel()))
                    } else {
                        completion(.success([]))
                    }
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
}

private struct Root: Decodable {
    let items: [RemoteFeedImage]
}

private struct RemoteFeedImage: Decodable {
    let image_id: UUID
    let image_desc: String?
    let image_loc: String?
    let image_url: URL
}

extension Array where Element == RemoteFeedImage {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url) }
    }
}
