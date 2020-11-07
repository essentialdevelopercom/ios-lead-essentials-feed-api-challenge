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

    static var OK_STATUS: Int { 200 }

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                if response.statusCode != RemoteFeedLoader.OK_STATUS {
                    return completion(.failure(Error.invalidData))
                }

                let root = try? JSONDecoder().decode(Root.self, from: data)
                if root == nil {
                    return completion(.failure(Error.invalidData))
                }
            }
        }
    }
}

struct Root: Decodable {
    let items: [RemoteFeedImage]
}

struct RemoteFeedImage: Decodable {
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
