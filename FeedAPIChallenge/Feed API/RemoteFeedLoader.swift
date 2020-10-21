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
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(FeedImageMapper.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private struct FeedImageMapper {
    struct Root: Decodable {
        let items: [Item]
    }
    struct Item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL

        private enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }

    private static let OK_200 = 200

    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == OK_200 else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        let items = root.items.map { (item) -> FeedImage in
            return FeedImage(
                id: item.id,
                description: item.description,
                location: item.location,
                url: item.url
            )
        }

        return .success(items)
    }
}
