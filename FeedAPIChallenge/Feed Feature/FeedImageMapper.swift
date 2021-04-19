import Foundation

internal final class FeedImageMapper {
	private struct Root: Decodable {
		let items: [ImageItem]

		var imageFeed: [FeedImage] {
			return items.map { $0.item }
		}
	}

	private struct ImageItem: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var item: FeedImage {
			return FeedImage(
				id: image_id,
				description: image_desc,
				location: image_loc,
				url: image_url
			)
		}
	}

	private static var OK_200: Int { return 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == OK_200, let rootImageItems = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(rootImageItems.imageFeed)
	}
}
