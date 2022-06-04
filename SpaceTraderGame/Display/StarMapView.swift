//
//  StarMapView.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

class StarMapView: NSView {
    
    var centerCoordinates : Coord = Coord() {
        didSet {
            self.needsDisplay = true
        }
    }
    var zoomLevel : Int = 0 {
        didSet {
            self.needsDisplay = true
        }
    }
    var galaxyMap : GalaxyMap = GalaxyMap() {
        didSet {
            self.needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let fillScreenPath = NSBezierPath(rect: dirtyRect)
        NSColor.black.setFill()
        fillScreenPath.fill()
        
        let ratio = self.getDistancePixelRatio()
        let originInDistance = (x:centerCoordinates.x - (self.bounds.size.width/2)*ratio,
                                y:centerCoordinates.y - (self.bounds.size.height/2)*ratio)
        
        let convertedRect = NSRect(x: originInDistance.x + dirtyRect.origin.x*ratio, y: originInDistance.y + dirtyRect.origin.y*ratio, width: dirtyRect.size.width*ratio, height: dirtyRect.size.height*ratio)
        
        NSColor.white.setFill()
        NSColor.white.setStroke()
        
        self.galaxyMap.getAllSystemIdentifiers().forEach { key in
            let value = self.galaxyMap.getSystemForId(key)!
            if value.position.x < convertedRect.origin.x || value.position.x > (convertedRect.origin.x + convertedRect.size.width) || value.position.y < convertedRect.origin.y || value.position.y > (convertedRect.origin.y + convertedRect.size.height) {
                return
            }
            let diameter = Double(20 + 4*self.zoomLevel)
            let starPoint = self.convertStarCoordToScreen(value.position)
            let circleRect = NSRect(x: starPoint.x - diameter/2, y: starPoint.y - diameter/2, width: diameter, height: diameter)
            let circlePath = NSBezierPath(ovalIn: circleRect)
            circlePath.fill()
            
            value.connectingSystems.forEach { otherKey in
                let otherStar = self.galaxyMap.getSystemForId(otherKey)!
                let otherStarPoint = self.convertStarCoordToScreen(otherStar.position)
                let linePath = NSBezierPath()
                linePath.move(to: starPoint)
                linePath.line(to: otherStarPoint)
                if self.zoomLevel < 0 {
                    linePath.lineWidth = 1
                }
                else {
                    linePath.lineWidth = 2
                }
                linePath.stroke()
            }
        }
    }
    
    func convertStarCoordToScreen(_ c : Coord) -> CGPoint {
        let ratio = self.getDistancePixelRatio()
        let originInDistance = (x:centerCoordinates.x - (self.bounds.size.width/2)*ratio,
                                y:centerCoordinates.y - (self.bounds.size.height/2)*ratio)
        return CGPoint(x: (c.x - originInDistance.x)/ratio, y: (c.y - originInDistance.y)/ratio)
        
    }
    
    func getDistancePixelRatio() -> Double {
        let baseLevel = 20.0/500.0
        if self.zoomLevel == 0 {
            return baseLevel
        }
        else if self.zoomLevel < 0 {
            return baseLevel*pow(1.2, Double(-1*self.zoomLevel))
        }
        else {
            return baseLevel*pow(0.8, Double(-1*self.zoomLevel))
        }
    }
}
