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
            switch result {
            case .success((let data, let response)):
                guard let items = self.convert(data: data),
                    response.statusCode == 200 else {
                        completion(Result.failure(Error.invalidData))
                        return
                }
                completion(Result.success(items))
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

        return items.compactMap { FeedImage.feedImage(from: $0) }
    }
}

private extension FeedImage {
    static func feedImage(from dic: [String: Any]) -> FeedImage? {
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
