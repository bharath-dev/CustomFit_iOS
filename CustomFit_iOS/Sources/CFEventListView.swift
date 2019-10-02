//
//  CFEventListView.swift
//  CustomFit
//
//  Created by Bharath R on 24/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

struct CFEventListView: Codable {
    
    var configuredEventList: [CFConfiguredEvent]?
    private var totalCount: Int?
    private var returnedListCount: Int?
    private var nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case configuredEventList = "results"
        case totalCount = "total_count"
        case returnedListCount = "returned_list_count"
        case nextPage = "next_page"
    }

}

