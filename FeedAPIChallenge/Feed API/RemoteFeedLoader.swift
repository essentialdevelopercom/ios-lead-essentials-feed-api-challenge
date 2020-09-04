//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let request: Request
	
    public typealias Request = (URL, @escaping (Swift.Result<(Data, HTTPURLResponse), Swift.Error>) -> Void) -> Void
    
	public enum Error: Swift.Error {
        case connectivity
        case invalidData
	}
		
    public init(url: URL, request: @escaping Request) {
        self.url = url
        self.request = request
	}
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        request(url) { result in
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                completion(FeedItemsMapper.map(data, response: response))
            }
        }
    }
}

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedImage] {
            return items.map {
                FeedImage(id: $0.id,
                          description: $0.description,
                          location: $0.location,
                          url: $0.imageURL
                )
            }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let imageURL: URL
        
        enum CodingKeys: String, CodingKey {
            case id = "image_id"
            case description = "image_desc"
            case location = "image_loc"
            case imageURL = "image_url"
        }
    }
    
    private static var OK_200: Int { return 200 }

    static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
}
