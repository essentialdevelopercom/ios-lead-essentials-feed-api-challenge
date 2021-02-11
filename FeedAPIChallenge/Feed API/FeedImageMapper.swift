import Foundation

struct FeedImageMapper {
	private enum StatusCode {
		static let OK = 200
	}
	
	private struct Root: Decodable {
		let items: [Image]
		var feed: [FeedImage] {
			items.map { $0.image }
		}
	}
	
	private struct Image: Decodable {
		let id: UUID
		let description: String?
		let location: String?
		let imageURL: URL
		
		var image: FeedImage {
			.init(id: id, description: description, location: location, url: imageURL)
		}
		
		enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case imageURL = "image_url"
		}
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == StatusCode.OK,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		
		return .success(root.feed)
	}
}
