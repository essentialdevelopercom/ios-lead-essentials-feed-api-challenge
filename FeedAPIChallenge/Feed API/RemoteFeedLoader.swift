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
            case let .success((data, response)):
                completion(FeedImageMapper.map(data: data, with: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private struct FeedImageMapper {
    
    // MARK: - Decodable
    
    private struct Root: Decodable {
        let items: [Image]
        
        var feedImages: [FeedImage] {
            items.map(\.feedImage)
        }
    }

    private struct Image: Decodable {
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
            FeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private enum HTTPStatusCode: Int {
        case success = 200
    }
    
    // MARK: - Mapping
    static func map(data: Data, with response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == HTTPStatusCode.success.rawValue,
              let feedImages = try? JSONDecoder().decode(Root.self, from: data).feedImages else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    
        return .success(feedImages)
    }
}
