//
//  Get.swift
//  test
//
//  Created by thibaut noah on 20/12/15.
//  Copyright © 2015 thibaut noah. All rights reserved.
//

import Foundation

class Get {
    var title:String?
    var body:String?
    var id:Int?
    var userId:Int?
    
    required init?(aTitle: String?, aBody: String?, anId: Int?, aUserId: Int?) {
        self.title = aTitle
        self.body = aBody
        self.id = anId
        self.userId = aUserId
    }
    
    func description() -> String {
        return "ID: \(self.id)" +
            "User ID: \(self.userId)" +
            "Title: \(self.title)\n" +
        "Body: \(self.body)\n"
    }
    
    // MARK: URLs
    class func endpointForID(id: Int) -> String {
        return "http://jsonplaceholder.typicode.com/posts/\(id)"
    }
    class func endpointForGet() -> String {
        return "http://middle.openjetlab.fr/api/rests/airport/list"
    }
    
    // MARK: GET

}