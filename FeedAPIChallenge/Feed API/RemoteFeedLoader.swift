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
                case .failure:
                    completion(.failure(Error.connectivity))

                case let .success((data, response)):
                    guard response.statusCode == 200
                    else {
                        completion(.failure(Error.invalidData))
                        break
                    }
                    completion(data.decodeFeedImages())
            }
        }
    }
}

private extension Data {
    func decodeFeedImages() -> FeedLoader.Result  {

        guard let feed = try? JSONDecoder().decode(RemoteFeedJSON.self, from: self)
        else { return .failure(RemoteFeedLoader.Error.invalidData) }

        let images = feed.items.map {
            FeedImage(id: $0.image_id,
                      description: $0.image_desc,
                      location: $0.image_loc,
                      url: $0.image_url)
        }

        return .success(images)
    }
}

private struct RemoteFeedJSON: Decodable {
    let items: [RemoteFeedImage]

    struct RemoteFeedImage: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
    }
}
