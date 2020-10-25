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
            guard let self = self else { return }
            self.mapCompletionResult(result, completion: completion)
        }
    }
    
    private func mapCompletionResult(_ result: Result<(Data, HTTPURLResponse), Swift.Error>, completion: @escaping (FeedLoader.Result) -> Void) {
        switch result {
        case let .success((data, response)):
            completion(FeedImageMapper.map(data, from: response))
        case .failure:
            completion(.failure(RemoteFeedLoader.Error.connectivity))
        }
    }
}

class FeedImageMapper {
    private static var ACK200: Int { 200 }
    private struct Root: Decodable {
        let items: [Item]
        
        var feedImages: [FeedImage] {
            items.map(\.feedImage)
        }
    }
    
    private struct Item: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
        
        var feedImage: FeedImage {
            FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
        guard response.statusCode == ACK200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feedImages)
    }
}
