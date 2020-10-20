//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Sharu on 20/10/20.
//  Copyright © 2020 Essential Developer Ltd. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
    
    private struct Root:Decodable
    {
        let items:[Item]
        var feed : [FeedImage] {
            return items.map{$0.item}
        }
    }
    
    private struct Item : Decodable{
     let id : UUID
     let description : String?
     let location : String?
     let url : URL
        
        var item:FeedImage{
            return FeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private static var OK_200 : Int{return 200}
    
    internal static func map(_ data:Data,from response:HTTPURLResponse) -> RemoteFeedLoader.Result
    {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self,from:data) else
        {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
           
    }
    
}
