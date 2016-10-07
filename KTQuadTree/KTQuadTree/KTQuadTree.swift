//
//  KTQuadTree.swift
//  KTQuadTree
//
//  Created by Kartik Patel on 10/7/16.
//  Copyright © 2016 KTPatel. All rights reserved.
//

import UIKit

struct QuadTreeNodeData {
    var x : Double
    var y : Double
    //var data : Void
    
    var id : Int
    var title : String
    var level : String
    var industry : String
    var function : String
    var datePosted : NSDate
    var companyName : String
    var details : String
    var city : String
    var state : String
    var coutnry : String
}

struct BoundingBox {
    var x0 : Double
    var y0 : Double
    var xf : Double
    var yf : Double
}

class QuadTreeNode {
    var northWest : QuadTreeNode? = nil
    var northEast : QuadTreeNode? = nil
    var southWest : QuadTreeNode? = nil
    var southEast : QuadTreeNode? = nil
    
    var objBoundingBox : BoundingBox
    var bucketCapacity : Int
    var points : [QuadTreeNodeData?]
    var count : Int = 0
    
    init(objBoundingBox : BoundingBox, bucketCapacity : Int){
        
        self.objBoundingBox = objBoundingBox
        self.bucketCapacity = bucketCapacity
        self.points = [QuadTreeNodeData?](count: bucketCapacity, repeatedValue: nil)
    }
}


class KTQuadTree: NSObject {
    override init() {
        
    }
    
    func QuadTreeTraverse(node : QuadTreeNode, block : (QuadTreeNode)->Void ) -> Void {
        block(node)
        
        if (node.northWest == nil) {
            return
        }
        
        QuadTreeTraverse(node.northWest!, block: block)
        QuadTreeTraverse(node.northEast!, block: block)
        QuadTreeTraverse(node.southWest!, block: block)
        QuadTreeTraverse(node.southEast!, block: block)
    }
}
func BoundingBoxIntersectsBoundingBox(b1 : BoundingBox, b2 : BoundingBox) -> Bool {
    return (b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0)
}
func QuadTreeGatherDataInRange(node : QuadTreeNode, range : BoundingBox, block : (data: QuadTreeNodeData) -> Void) -> Void {
    if (!BoundingBoxIntersectsBoundingBox(node.objBoundingBox, b2: range)) {
        return
    }
    
    for i in 0..<node.count {
        if (BoundingBoxContainsData(range, data: node.points[i]!)) {
            block(data: node.points[i]!)
        }
    }
    
    if (node.northWest == nil) {
        return
    }
    
    QuadTreeGatherDataInRange(node.northWest!, range: range, block: block)
    QuadTreeGatherDataInRange(node.northEast!, range: range, block: block)
    QuadTreeGatherDataInRange(node.southWest!, range: range, block: block)
    QuadTreeGatherDataInRange(node.southEast!, range: range, block: block)
}
func QuadTreeBuildWithData(data : [QuadTreeNodeData?], count : Int, boundingBox : BoundingBox, capacity : Int) -> QuadTreeNode{
    
    let root : QuadTreeNode = QuadTreeNode(objBoundingBox: boundingBox, bucketCapacity: capacity)
    for i in 0..<count {
        QuadTreeNodeInsertData(root, data: data[i])
    }
    
    return root
}
func QuadTreeNodeInsertData(node : QuadTreeNode, data : QuadTreeNodeData?) -> Bool {
    if BoundingBoxContainsData(node.objBoundingBox, data: data!) == false {
        return false
    }
    
    if (node.count < node.bucketCapacity) {
        node.points[node.count] = data
        node.count+=1
        return true
    }
    
    if (node.northWest == nil) {
        QuadTreeNodeSubdivide(node)
    }
    
    if (QuadTreeNodeInsertData(node.northWest!, data:data)){
        return true
    }
    if (QuadTreeNodeInsertData(node.northEast!, data:data)){
        return true
    }
    if (QuadTreeNodeInsertData(node.southWest!, data:data)){
        return true
    }
    
    if (QuadTreeNodeInsertData(node.southEast!, data:data)){
        return true
    }
    return false
}
func BoundingBoxContainsData(box : BoundingBox, data : QuadTreeNodeData) -> Bool {
    let containsX : Bool = box.x0 <= data.x && data.x <= box.xf
    let containsY : Bool = box.y0 <= data.y && data.y <= box.yf
    
    return containsX && containsY
}
func QuadTreeNodeSubdivide(node : QuadTreeNode) -> Void
{
    let box : BoundingBox = node.objBoundingBox
    
    let xMid : Double = (box.xf + box.x0) / 2.0
    let yMid : Double = (box.yf + box.y0) / 2.0
    
    let northWest : BoundingBox = BoundingBox(x0:box.x0, y0:box.y0, xf:xMid, yf:yMid)
    node.northWest = QuadTreeNode(objBoundingBox: northWest, bucketCapacity: node.bucketCapacity)
    
    let northEast : BoundingBox = BoundingBox(x0:xMid, y0:box.y0, xf:box.xf, yf:yMid)
    node.northEast = QuadTreeNode(objBoundingBox: northEast, bucketCapacity: node.bucketCapacity)
    
    let southWest : BoundingBox = BoundingBox(x0:box.x0, y0:yMid, xf:xMid, yf:box.yf)
    node.southWest = QuadTreeNode(objBoundingBox: southWest, bucketCapacity: node.bucketCapacity)
    
    let southEast : BoundingBox = BoundingBox(x0:xMid, y0:yMid, xf:box.xf, yf:box.yf)
    node.southEast = QuadTreeNode(objBoundingBox: southEast, bucketCapacity: node.bucketCapacity)
}
