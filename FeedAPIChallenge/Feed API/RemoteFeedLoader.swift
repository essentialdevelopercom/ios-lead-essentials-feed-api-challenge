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
				case let .success((data,response)):
					completion(FeedImageMapper.map(data: data, response: response))
				case .failure:
					completion(.failure(Error.connectivity))
			}
		}
	}
}

struct FeedImageMapper {

	private struct Root: Decodable {

		let items: [Image]
		
		var feedImages: [FeedImage] {
			return items.map {
				FeedImage(id: $0.image_id
						  , description: $0.image_desc
						  , location: $0.image_loc
						  , url: $0.image_url)
			}
		}
	}

	private struct Image: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL
	}
	
	private static let OK_200 = 200
	
	static func map(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		
		if response.statusCode == OK_200 {
			do {
				let root = try JSONDecoder().decode(Root.self, from: data)
				return .success(root.feedImages)
			} catch {
				return .failure(RemoteFeedLoader.Error.invalidData)
			}
		} else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}
}


