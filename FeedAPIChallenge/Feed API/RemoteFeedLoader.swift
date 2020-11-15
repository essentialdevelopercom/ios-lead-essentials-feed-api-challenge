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

    private static var OK_200: Int { return 200 }
	
	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let (data, response)):
                guard response.statusCode == RemoteFeedLoader.OK_200 else {
                    completion(.failure(Error.invalidData))
                    return
                }

                do {
                    let root = try JSONDecoder().decode(Root.self, from: data)
                    completion(.success(root.feed))
                } catch {
                    completion(.failure(Error.invalidData))
                }

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items:  [Item]

    var feed: [FeedImage] { items.map{ $0.item } }
}

private struct Item: Decodable {
    let image_id: UUID
    let image_desc: String?
    let image_loc: String?
    let image_url: URL

    var item: FeedImage {
        FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
    }
}
