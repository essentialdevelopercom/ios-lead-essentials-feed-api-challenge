
import Foundation


internal final class FeedImagesMapper {
    
    private let data: Data
    private let response: HTTPURLResponse
    
    init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
    
    func map() -> FeedLoader.Result {
        if response.statusCode != 200 {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        do {
            let _ = try JSONDecoder().decode(FeedImagesResponse.self, from: data)
            return .success([])
        } catch {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
    }
    
}
