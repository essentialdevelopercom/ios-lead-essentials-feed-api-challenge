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
            switch result {
            case .success(let result):
                let items = self?.convert(data: result.0)
                switch (items, result.1.statusCode) {
                case (nil, 200):
                    completion(Result.failure(Error.invalidData))
                case (_, 200):
                    completion(Result.success(items!))
                default:
                    completion(Result.failure(Error.invalidData))
                }
            case .failure(_):
                completion(Result.failure(Error.connectivity))
            }
        }
    }

    private func convert(data: Data?) -> [FeedImage]? {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: [[String: Any]]],
            let items = json["items"] else {
                return nil
        }

        let feedImages: [FeedImage] = items.compactMap { dic in
            FeedImage.item(from: dic)
        }
        return feedImages
    }
}

private extension FeedImage {
    static func item(from dic: [String: Any]) -> FeedImage? {
        guard let imageIdString = dic["image_id"] as? String,
            let uuid = UUID(uuidString: imageIdString),
            let urlString = dic["image_url"] as? String,
            let url = URL(string: urlString) else {
                return nil
        }
        return FeedImage(id: uuid,
                         description: dic["image_desc"] as? String,
                         location: dic["image_loc"] as? String,
                         url: url)
    }
}
