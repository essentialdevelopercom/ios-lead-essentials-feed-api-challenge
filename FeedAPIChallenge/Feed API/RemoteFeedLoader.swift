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
            if case let .success((data, httpURLResponse)) = result {
                guard httpURLResponse.statusCode == 200 else {
                    completion(.failure(RemoteFeedLoader.Error.invalidData))
                    return
                }
                
                do {
                    let items = try JSONDecoder().decode(RemoteFeedImageItems.self, from: data)
                    let feedImages = items.items.map { $0.toModel() }
                    completion(.success(feedImages))
                    
                } catch {
                    completion(.failure(RemoteFeedLoader.Error.invalidData))
                }
                
            } else if case .failure = result {
                completion(.failure(RemoteFeedLoader.Error.connectivity))
                
            }
        }
    }
}

struct RemoteFeedImageItems: Decodable {
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

extension RemoteFeedImage {
    func toModel() -> FeedImage {
        return FeedImage(id: id, description: description, location: location, url: url)
    }
}
