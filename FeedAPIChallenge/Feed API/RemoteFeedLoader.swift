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
            case .failure(_):
                completion(.failure(Error.connectivity))
                break
            case .success((let data, let response)):
                guard response.statusCode == 200,
                      let _ = try? JSONSerialization.jsonObject(with: data) else {
                    return completion(.failure(Error.invalidData))
                }
                
                return completion(FeedImageMapper.map(from: data, response: response))
            }
        }
    }
}

struct Root: Decodable {
    var items: [FeedImageDto]
}

struct FeedImageDto: Decodable {
    var id: UUID
    var description: String?
    var location: String?
    var url: URL
    
    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
}

struct FeedImageMapper {
    static func map(from data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == 200,
              let root: Root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        let feedImages = root.items.map { dto in
            FeedImage(id: dto.id, description: dto.description, location: dto.location, url: dto.url)
        }

        return .success(feedImages)
    }
}
