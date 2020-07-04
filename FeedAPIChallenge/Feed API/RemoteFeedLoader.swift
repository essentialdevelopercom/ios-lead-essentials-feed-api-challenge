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
        self.client.get(from: self.url) { [weak self] result in
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

internal final class FeedImagesMapper {

    private struct Root: Decodable {
        let items: [Item]

        var feed: [FeedImage] {
            self.items.map { $0.image }
        }
    }

    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL

        var image: FeedImage {
            FeedImage(id: self.image_id,
                      description: self.image_desc,
                      location: self.image_loc,
                      url: self.image_url)
        }
    }

    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feed)
    }

}
