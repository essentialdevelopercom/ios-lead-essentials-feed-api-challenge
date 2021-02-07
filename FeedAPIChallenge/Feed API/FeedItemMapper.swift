import Foundation

internal final class FeedItemMapper {
	private struct Root: Decodable {
		let items: [Item]

		var feed: [FeedImage] {
			items.map { $0.item }
		}
	}

	private struct Item: Decodable {
		private let image_id: UUID
		private let image_desc: String?
		private let image_loc: String?
		private let image_url: URL

		var item: FeedImage {
			FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	private static var OK_200: Int { 200 }

	internal static func map(_ data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(root.feed)
	}
}
