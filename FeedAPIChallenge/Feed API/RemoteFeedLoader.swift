//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

private struct GroupItem: Decodable {
	let items: [RemoteImage]
}

private struct RemoteImage: Decodable {
	let image_id: UUID
	let image_desc: String?
	let image_loc: String?
	let image_url: URL
}

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
			case let .success((data, response)):

				guard response.statusCode == 200,
				      let groupItem = try? JSONDecoder().decode(GroupItem.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}

				let items = FeedImageMapper.mapRemoteImages(groupItem.items)
				if self != nil {
					completion(.success(items))
				}

			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		}
	}
}

private struct FeedImageMapper {
	static func mapRemoteImages(_ items: [RemoteImage]) -> [FeedImage] {
		return items.map { remoteImage in
			return FeedImage(
				id: remoteImage.image_id,
				description: remoteImage.image_desc,
				location: remoteImage.image_loc,
				url: remoteImage.image_url)
		}
	}
}
