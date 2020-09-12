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
        client.get(from: url) { response in
            switch response {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success(let success):
               completion(FeedImageMapper.map(success.data, success.response))
            }
        }
    }
}

final class FeedImageMapper {
    typealias Error = RemoteFeedLoader.Error

    static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        if response.statusCode == 200,
            let feed = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(feed.items.map(\.feedImage))
        } else {
            return .failure(Error.invalidData)
        }
    }

    private struct Root: Decodable {
        let items: [FeedImageResponse]
    }

    struct FeedImageResponse: Decodable {
        private let image_id: UUID
        private let image_desc: String?
        private let image_loc: String?
        private let image_url: URL

        var feedImage: FeedImage {
            FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
}
