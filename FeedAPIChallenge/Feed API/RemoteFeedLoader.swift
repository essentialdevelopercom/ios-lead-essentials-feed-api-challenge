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
            items.map { FeedImage(id: $0.imageId, description: $0.imageDesc, location: $0.imageLoc, url: $0.imageUrl)}
        }
    }

    private struct RemoteItem: Decodable {

        let imageId: UUID
        let imageDesc: String?
        let imageLoc: String?
        let imageUrl: URL

        enum CodingKeys: String, CodingKey {
            case imageId = "image_id"
            case imageDesc = "image_desc"
            case imageLoc = "image_loc"
            case imageUrl = "image_url"
        }
    }
}
