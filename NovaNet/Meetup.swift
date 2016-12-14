//
//  Meetup.swift
//  NovaNet
//
//  Created by Nathan Lam on 12/13/16.
//  Copyright © 2016 Nova. All rights reserved.
//

import UIKit

class Meetup: NSObject {
    var id: String!
    var title: String!
    var desc: String!
    var creatorId: String!
    var creatorName: String!
    var address: String!
    var goingList: [String]!
    var maybeList: [String]!
    var notGoingList: [String]!
    var date: Date!
    var lat: Float!
    var lon: Float!
    
    init(id: String,
         title: String,
         desc: String,
         creatorId: String,
         creatorName: String,
         address: String,
         goingList: [String],
         maybeList: [String],
         notGoingList: [String],
         date: Date,
         lat: Float,
         lon: Float)
    {
        super.init()
        self.id = id
        self.title = title
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.address = address
        self.goingList = goingList
        self.maybeList = maybeList
        self.notGoingList = notGoingList
        self.date = date
        self.lat = lat
        self.lon = lon
    }
    
    override var description: String {
        return "name: \(title)" +
            "date: \(date)" +
            "id: \(id)" +
            "desc: \(desc)"
    }

}
