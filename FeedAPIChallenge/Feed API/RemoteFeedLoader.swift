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
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                do {
                    let feedImages = try FeedImageMapper.map(data, from: response)
                    completion(.success(feedImages))
                } catch {
                    completion(.failure(error))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private class FeedImageMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.statusCode == 200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items.map { $0.item }
    }
}

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

    var item: FeedImage {
        return FeedImage(id: id, description: description, location: location, url: url)
    }
}
