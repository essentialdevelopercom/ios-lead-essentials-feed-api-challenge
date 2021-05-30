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
		client.get(from: url, completion: { [ weak self ] result in
			guard self != nil else { return }
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case .success((let data, let response)):
				completion(FeedImageMapper.map(from: data, response))
			}
		})
	}
	
	private class FeedImageMapper {
		static let OK_200: Int = 200
		
		static func map(from data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
			if response.statusCode != OK_200 {
				return .failure(Error.invalidData)
			} else {
				let decoder = JSONDecoder()
				do {
					let root = try decoder.decode(Root.self, from: data)
					return .success(root.items.map { $0.feedImage })
				} catch  {
					return .failure(Error.invalidData)
				}
			}
		}
		
		private struct Root : Decodable {
			let items: [ImageItem]
		}
		
		private struct ImageItem: Decodable {
			private let image_id: UUID
			private let image_desc: String?
			private let image_loc: String?
			private let image_url: URL
			
			var feedImage: FeedImage {
				return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
			}
		}
	}
}
