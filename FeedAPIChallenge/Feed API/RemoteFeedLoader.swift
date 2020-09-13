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
            case .success(let (data, response)):
                completion(FeedIamgeMapper.map(data: data, response: response))
            case .failure(_):
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
}

final class FeedIamgeMapper {
    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feedImages)
    }
}

private struct Root: Decodable {
    private let items: [Image]
    var feedImages: [FeedImage] {
        return items.map { $0.feedImage }
    }

    struct Image: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL

        var feedImage: FeedImage {
            return FeedImage(
                id: id,
                description: description,
                location: location,
                url: url
            )
        }

        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case url = "image_url"
        }
    }
}
