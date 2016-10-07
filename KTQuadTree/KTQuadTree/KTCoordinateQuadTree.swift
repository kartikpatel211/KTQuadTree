//
//  KTCoordinateQuadTree.swift
//  KTQuadTree
//
//  Created by Kartik Patel on 10/7/16.
//  Copyright © 2016 KTPatel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Darwin

class KTCoordinateQuadTree: NSObject {
    
    var root : QuadTreeNode?
    var mapView : MKMapView?
    
    func BoundingBoxForMapRect(mapRect : MKMapRect) -> BoundingBox {
        let topLeft : CLLocationCoordinate2D = MKCoordinateForMapPoint(mapRect.origin)
        let botRight : CLLocationCoordinate2D = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)))
        
        let minLat : CLLocationDegrees = botRight.latitude
        let maxLat : CLLocationDegrees = topLeft.latitude
        
        let minLon : CLLocationDegrees = topLeft.longitude
        let maxLon : CLLocationDegrees = botRight.longitude
        
        return BoundingBox(x0: minLat, y0: minLon, xf: maxLat, yf: maxLon)
    }
    
    func MapRectForBoundingBox(boundingBox : BoundingBox) -> MKMapRect {
        let topLeft : MKMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0))
        let botRight : MKMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf))
        
        return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y))
    }
    
    func ZoomScaleToZoomLevel(scale : MKZoomScale) -> NSInteger {
        let totalTilesAtMaxZoom : Double = MKMapSizeWorld.width / 256.0
        let zoomLevelAtMaxZoom : Int = Int(log2(totalTilesAtMaxZoom))
        let zoomLevel : Int = max(0, zoomLevelAtMaxZoom + Int(floor( log2f(Float(scale)) + 0.5 )) )
        
        return zoomLevel
    }
    
    func CellSizeForZoomScale(zoomScale : MKZoomScale) -> Double {
        let zoomLevel : NSInteger = ZoomScaleToZoomLevel(zoomScale)
        
        switch (zoomLevel) {
        case 13, 14, 15:
            return 64
        case 16, 17, 18:
            return 32
        case 19:
            return 16
        default:
            return 88
        }
    }
    
    func buildTree(dataArray : [QuadTreeNodeData?]) -> Void {
        autoreleasepool {
            let world : BoundingBox = BoundingBox(x0: 19, y0: -166, xf: 72, yf: -53)
            root = QuadTreeBuildWithData(dataArray, count: dataArray.count, boundingBox: world, capacity: 4)
        }
    }
    
    func clusteredAnnotationsWithinMapRect(rect : MKMapRect, zoomScale: Double) -> [KTClusterAnnotation] {
        let CellSize : Double = CellSizeForZoomScale(MKZoomScale(zoomScale))
        let scaleFactor : Double = zoomScale / CellSize
        
        let minX : Int = Int(floor(MKMapRectGetMinX(rect) * scaleFactor))
        let maxX : Int = Int(floor(MKMapRectGetMaxX(rect) * scaleFactor))
        let minY : Int = Int(floor(MKMapRectGetMinY(rect) * scaleFactor))
        let maxY : Int = Int(floor(MKMapRectGetMaxY(rect) * scaleFactor))
        
        var clusteredAnnotations = [KTClusterAnnotation]()
        for x in minX...maxX{
            for y in minY...maxY{
                let mapRect : MKMapRect = MKMapRectMake(Double(x) / scaleFactor, Double(y) / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor)
                
                var totalX : Double = 0
                var totalY : Double = 0
                var count : Int = 0
                
                var title  = [String]()
                var companyName  = [String]()
                
                QuadTreeGatherDataInRange(self.root!, range: BoundingBoxForMapRect(mapRect),  block:({(data: QuadTreeNodeData) -> Void in
                    totalX += data.x
                    totalY += data.y
                    count+=1
                    
                    title.append(data.title)
                    companyName.append(data.companyName)
                    }
                ))
                
                if count == 1 {
                    let coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: totalX, longitude: totalY)
                    let annotation = KTClusterAnnotation.init(coordinate: coordinate, count: count)
                    
                    if title.count > 0 {
                        annotation.title = title.last
                    }
                    if companyName.count > 0 {
                        annotation.subtitle = companyName.last
                    }
                    
                    clusteredAnnotations.append(annotation)
                }
                
                if count > 1 {
                    let coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: totalX / Double(count), longitude: totalY / Double(count))
                    let annotation = KTClusterAnnotation.init(coordinate: coordinate, count: count)
                    clusteredAnnotations.append(annotation)
                }
            }
        }
        
        return clusteredAnnotations
    }
}
