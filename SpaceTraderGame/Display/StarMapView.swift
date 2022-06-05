//
//  StarMapView.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

@objc protocol StarMapViewDelegate : AnyObject {
    func mapClickedAtCoordinates(sender: StarMapView, coordinates: CGPoint)
}

class StarMapView: NSView {
    
    
    var centerCoordinates : Coord = Coord() {
        didSet {
            self.needsDisplay = true
        }
    }
    var zoomLevel : Int = 0 {
        didSet {
            self.setDistancePixelRatio()
            self.needsDisplay = true
        }
    }
    var galaxyMap : GalaxyMap = GalaxyMap() {
        didSet {
            self.needsDisplay = true
        }
    }
    
    @IBOutlet weak var delegate : StarMapViewDelegate?
    
    var distancePixelRatio : Double = 20.0/500.0
    
    // MARK: - Initialization
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.configureGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureGestureRecognizer()
    }
    
    private func configureGestureRecognizer() {
        let gestureHandler = NSClickGestureRecognizer(target: self, action: #selector(handleClickGesture(gestureRecognizer:)))
        self.addGestureRecognizer(gestureHandler)
    }
    
    private func setDistancePixelRatio() {
        let baseLevel = 20.0/500.0
        if self.zoomLevel == 0 {
            distancePixelRatio = baseLevel
        }
        else if self.zoomLevel < 0 {
            distancePixelRatio = baseLevel*pow(1.2, Double(-1*self.zoomLevel))
        }
        else {
            distancePixelRatio = baseLevel*pow(0.8, Double(self.zoomLevel))
        }
    }
                                                      
    // MARK: - Clicks
    
    @objc func handleClickGesture(gestureRecognizer: NSClickGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        let convertedLocation = self.convertScreenToStarCoord(location)
        delegate?.mapClickedAtCoordinates(sender: self, coordinates: convertedLocation)
    }
                                                      
    
    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let fillScreenPath = NSBezierPath(rect: dirtyRect)
        NSColor.black.setFill()
        fillScreenPath.fill()
        
        let ratio = distancePixelRatio
        let originInDistance = (x:centerCoordinates.x - (self.bounds.size.width/2)*ratio,
                                y:centerCoordinates.y - (self.bounds.size.height/2)*ratio)
        
        let convertedRect = NSRect(x: originInDistance.x + dirtyRect.origin.x*ratio, y: originInDistance.y + dirtyRect.origin.y*ratio, width: dirtyRect.size.width*ratio, height: dirtyRect.size.height*ratio)
        

        
        
        let starsOnMap = self.galaxyMap.getAllSystemIdentifiers().filter({ key in
            let value = self.galaxyMap.getSystemForId(key)!
            if value.position.x < convertedRect.origin.x || value.position.x > (convertedRect.origin.x + convertedRect.size.width) || value.position.y < convertedRect.origin.y || value.position.y > (convertedRect.origin.y + convertedRect.size.height) {
                return false
            }
            else {
                return true
            }
        })
        
        NSColor.gray.setFill()
        NSColor.gray.setStroke()
        
        starsOnMap.forEach { key in
            let value = self.galaxyMap.getSystemForId(key)!
            let starPoint = self.convertStarCoordToScreen(value.position)
            
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
        
        NSColor.white.setFill()
        NSColor.white.setStroke()
        
        starsOnMap.forEach { key in
            let value = self.galaxyMap.getSystemForId(key)!
            let diameter = Double(20 + 4*self.zoomLevel)
            let starPoint = self.convertStarCoordToScreen(value.position)
            let circleRect = NSRect(x: starPoint.x - diameter/2, y: starPoint.y - diameter/2, width: diameter, height: diameter)
            let circlePath = NSBezierPath(ovalIn: circleRect)
            circlePath.fill()
            
            self.drawStringCenteredAt(point: CGPoint(x: starPoint.x, y: starPoint.y + diameter/2), text: value.name)
        }
    }
    
    func drawStringCenteredAt(point : CGPoint, text : String ) {
        let attributes = [NSAttributedString.Key.font:NSFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor:NSColor.white]
        let nsText = text as NSString
        
        let boundingRect = nsText.boundingRect(with: NSSize(width: 500, height: 30), attributes: attributes)
        let textStartingPoint = CGPoint(x: point.x - (boundingRect.size.width/2), y: point.y)
        nsText.draw(at: textStartingPoint, withAttributes: attributes)
    }
    
    func convertScreenToStarCoord(_ s : CGPoint) -> CGPoint {
        
        let distanceFromCenter = NSPoint(x: s.x - self.bounds.size.width/2,
                                         y: s.y - self.bounds.size.height/2)
        return CGPoint(x: distanceFromCenter.x*distancePixelRatio + self.centerCoordinates.x,
                     y: distanceFromCenter.y*distancePixelRatio + self.centerCoordinates.y)
        
    }
    
    func convertStarCoordToScreen(_ c : Coord) -> CGPoint {
        let ratio = distancePixelRatio
        let originInDistance = (x:centerCoordinates.x - (self.bounds.size.width/2)*ratio,
                                y:centerCoordinates.y - (self.bounds.size.height/2)*ratio)
        return CGPoint(x: (c.x - originInDistance.x)/ratio, y: (c.y - originInDistance.y)/ratio)
        
    }
}
