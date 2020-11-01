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
            case .success((let data, let response)):
                    completion(FeedImageItemsMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

final class FeedImageItemsMapper {

    private struct Items: Decodable {
        let items: [ImageItem]

        var feedImageItems: [FeedImage] {
            items.compactMap {
                guard let url = URL(string: $0.imageURL) else { return nil }
                return FeedImage(id: $0.imageId,
                          description: $0.imageDesc,
                          location: $0.imageLoc,
                          url: url)
            }
        }
    }

    private struct ImageItem: Decodable {
        let imageId: UUID
        let imageDesc: String?
        let imageLoc: String?
        let imageURL: String

        enum CodingKeys: String, CodingKey {
            case imageId = "image_id"
            case imageDesc = "image_desc"
            case imageLoc = "image_loc"
            case imageURL = "image_url"
        }
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
        guard
            response.statusCode == 200,
            let feedItems = try? JSONDecoder().decode(Items.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)

        }
        return .success(feedItems.feedImageItems)
    }
}
