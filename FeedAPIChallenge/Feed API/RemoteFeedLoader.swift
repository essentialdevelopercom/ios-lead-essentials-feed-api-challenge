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
                if let items = try? FeedImageObjectMapper.map(data), response.statusCode == 200 {
                    
                    completion(.success(items))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
    
            }
        }
    }
}

class FeedImageObjectMapper {
    static func map(_ data: Data) throws -> [FeedImage] {
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.items.map { $0.feedImage }
        } catch {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
}

private struct Root: Decodable {
    let items: [RemoteFeedImage]
}

private struct RemoteFeedImage: Decodable {
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
    
    var feedImage: FeedImage {
        return FeedImage(
            id: id,
            description: description,
            location: location,
            url: url)
    }
}

