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
                completion(FeedImagesMapper.map(data: data, response: response))
            default:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

class FeedImagesMapper {
    
    static private var Ok200HTTPStatusCode = 200
    
    static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        guard valid200HTTPResponse(from: response),
              let items = decodeFeedImages(from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(items.feedImages)
    }
    
    static private func valid200HTTPResponse(from response: HTTPURLResponse) -> Bool {
        response.statusCode == Ok200HTTPStatusCode
    }
    
    static private func decodeFeedImages(from data: Data) -> Root? {
        try? JSONDecoder().decode(Root.self, from: data)
    }
    
    private struct Root: Decodable {
        let items: [FeedImageItem]
        
        var feedImages: [FeedImage] {
            items.map { FeedImage(id: $0.id,
                                  description: $0.description,
                                  location: $0.location,
                                  url: $0.url) }
        }
    }

    private struct FeedImageItem: Decodable {
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
}
