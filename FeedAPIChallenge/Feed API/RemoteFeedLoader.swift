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
            self?.handleClientResult(result, completion: completion)
        }
    }

    private func handleClientResult(_ result: HTTPClient.Result, completion: @escaping (FeedLoader.Result) -> Void) {
        switch result {
        case let .success((data, response)):
            guard response.statusCode == 200, let feedItemList = try? JSONDecoder().decode(FeedItemListDTO.self, from: data) else {
                completion(.failure(Error.invalidData))
                return
            }
            completion(.success(feedItemList.items.map { $0.feedImage }))
        case .failure:
            completion(.failure(Error.connectivity))
        }
    }
}

private struct FeedItemListDTO: Decodable {
    let items: [FeedImageDTO]
}

private struct FeedImageDTO: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL

    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
}

private extension FeedImageDTO {
    var feedImage: FeedImage {
        FeedImage(id: id, description: description, location: location, url: url)
    }
}
