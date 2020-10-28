
import Foundation


struct FeedImageResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "image_id"
        case description = "image_desc"
        case location = "image_loc"
        case url = "image_url"
    }
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
}
