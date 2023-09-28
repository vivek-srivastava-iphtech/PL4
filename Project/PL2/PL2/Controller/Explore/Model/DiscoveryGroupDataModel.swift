//
//  GroupDataModel.swift
//  InPower
//
//  Created by Saddam Khan on 4/29/21.
//  Copyright © 2021 iPHSTech31. All rights reserved.
//

import Foundation

struct DiscoveryGroupDataModel {
    
    var groupId = String()
    var groupName = String()
    var groupFeaturedImage = String()
    var groupDescription = String()
    var groupTapped = "0"
    var groupJoined = "0"
    
    init(groupId: String, groupName: String, groupFeaturedImage: String, groupDescription: String, groupTapped: String = "0", groupJoined: String = "0") {
        self.groupId = groupId
        self.groupName = groupName
        self.groupFeaturedImage = groupFeaturedImage
        self.groupDescription = groupDescription
        self.groupTapped = groupTapped
        self.groupJoined = groupJoined
    }
}
