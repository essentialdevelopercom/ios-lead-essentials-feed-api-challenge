import Foundation

internal final class FeedItemMapper {
	private struct Root: Decodable {
		var items: [Item]
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

	internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == OK_200 else {
			throw RemoteFeedLoader.Error.invalidData
		}

		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map { $0.item }
	}
}
