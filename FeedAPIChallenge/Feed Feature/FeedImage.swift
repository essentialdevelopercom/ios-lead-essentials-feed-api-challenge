//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImage: Hashable, Decodable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let url: URL
    
	
	public init(image_id: UUID, image_desc: String?, image_loc: String?, image_url: URL) {
		self.id = image_id
		self.description = image_desc
		self.location = image_loc
		self.url = image_url
	}
    
}


