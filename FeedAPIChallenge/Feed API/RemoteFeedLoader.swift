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
                case .failure(_):
                    completion(.failure(Error.connectivity))
                case let .success(result):
                    completion(self.mapResponse(result))
            }
        }
    }

    // MARK: - Helpers

    private func mapResponse(_ result: (Data, HTTPURLResponse)) -> FeedLoader.Result {
        guard
            result.1.statusCode == 200,
            let remoteItems = try? JSONDecoder().decode(Root.self, from: result.0)
        else {
            return .failure(Error.invalidData)
        }
        return .success(remoteItems.models)
    }

    private struct Root: Decodable {
        let items: [RemoteItem]

        var models: [FeedImage] {
            items.map { FeedImage(id: $0.image_id, description: $0.image_desc, location: $0.image_loc, url: $0.image_url)}
        }
    }

    private struct RemoteItem: Decodable {
        let image_id: UUID
        let image_desc: String?
        let image_loc: String?
        let image_url: URL
    }
}
