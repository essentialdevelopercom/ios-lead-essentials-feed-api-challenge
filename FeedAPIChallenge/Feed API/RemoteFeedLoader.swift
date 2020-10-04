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
        client.get(from: self.url) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200,
                      let items = try? JSONDecoder().decode(RemoteFeedImageRoot.self, from: data).feedItems else {
                    completion(.failure(Error.invalidData))
                    return
                }
                completion(.success(items))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

struct RemoteFeedImageRoot: Decodable {
    
    var items: [RemoteFeedImage]
    
    var feedItems: [FeedImage] {
        items.map { $0.feedImage }
    }
}

struct RemoteFeedImage: Decodable {
    var id: UUID
    var description: String?
    var location: String?
    var url: URL
    
    var feedImage: FeedImage {
        return FeedImage(id: id,
                         description: description,
                         location: location,
                         url: url)
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
    
}
