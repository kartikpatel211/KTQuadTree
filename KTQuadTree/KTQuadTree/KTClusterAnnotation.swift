//
//  KTClusterAnnotation.swift
//  KTQuadTree
//
//  Created by Kartik Patel on 10/7/16.
//  Copyright © 2016 KTPatel. All rights reserved.
//

import UIKit
import MapKit

class KTClusterAnnotation: NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var count : Int = 0
    var title : String?
    var subtitle : String?
    
    init(coordinate: CLLocationCoordinate2D, count: NSInteger ){
        self.coordinate = coordinate
        self.title = "\(count) jobs in  this area"
        self.count = count
    }
    
    override var hashValue: Int {
        return self.hash
    }
    
    override var hash: Int {
        let latitude = String(format: "%.5f", self.coordinate.latitude)
        let longitude = String(format: "%.5f", self.coordinate.longitude)
        return "\(latitude)\(longitude)".hash
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return self.hash == object?.hash
    }
}
func ==(lhs: KTClusterAnnotation, rhs: KTClusterAnnotation) -> Bool {
    return lhs.hash == rhs.hash
}
