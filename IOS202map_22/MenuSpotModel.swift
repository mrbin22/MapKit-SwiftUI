//
//  MenuSpotModel.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/06/07.
//

import Foundation
import MapKit


struct MenuSpotModel: Identifiable {
    let id = UUID().uuidString
    var title: String
    var location: CLLocationCoordinate2D?
}
