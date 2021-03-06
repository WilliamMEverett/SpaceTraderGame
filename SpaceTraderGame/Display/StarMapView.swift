//
//  StarMapView.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/4/22.
//

import Cocoa

@objc protocol StarMapViewDelegate : AnyObject {
    func mapClickedAtCoordinates(sender: StarMapView, coordinates: CGPoint)
    func mapDragged(sender: StarMapView, from: CGPoint, to: CGPoint)
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
    var gameState : GameState? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    @IBOutlet weak var delegate : StarMapViewDelegate?
    
    var distancePixelRatio : Double = 20.0/500.0
    var lastMouseDown = NSPoint(x: 0, y: 0)
    
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
                                                      
    // MARK: - Mouse Events
    
    @objc func handleClickGesture(gestureRecognizer: NSClickGestureRecognizer) {
        let location = gestureRecognizer.location(in: self)
        let convertedLocation = self.convertScreenToStarCoord(location)
        delegate?.mapClickedAtCoordinates(sender: self, coordinates: convertedLocation)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.lastMouseDown = self.convert(event.locationInWindow, from: nil)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let currentMouseLocation = self.convert(event.locationInWindow, from: nil)
        
        let fromCoords = self.convertScreenToStarCoord(self.lastMouseDown)
        let toCoords = self.convertScreenToStarCoord(currentMouseLocation)
        
        delegate?.mapDragged(sender: self, from: fromCoords, to: toCoords)
        
        self.lastMouseDown = currentMouseLocation
    }
                                                      
    
    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if self.gameState == nil {
            return
        }
        
        let fillScreenPath = NSBezierPath(rect: dirtyRect)
        NSColor.black.setFill()
        fillScreenPath.fill()
        
        let ratio = distancePixelRatio
        let originInDistance = (x:centerCoordinates.x - (self.bounds.size.width/2)*ratio,
                                y:centerCoordinates.y - (self.bounds.size.height/2)*ratio)
        
        let convertedRect = NSRect(x: originInDistance.x + dirtyRect.origin.x*ratio, y: originInDistance.y + dirtyRect.origin.y*ratio, width: dirtyRect.size.width*ratio, height: dirtyRect.size.height*ratio)
        
        let allStars = self.gameState!.player.allKnownStars
        
        let starsOnMap = allStars.filter({ key in
            let value = self.gameState!.galaxyMap.getSystemForId(key)!
            if value.position.x < convertedRect.origin.x || value.position.x > (convertedRect.origin.x + convertedRect.size.width) || value.position.y < convertedRect.origin.y || value.position.y > (convertedRect.origin.y + convertedRect.size.height) {
                return false
            }
            else {
                return true
            }
        })
        
        NSColor.gray.setStroke()
        
        starsOnMap.forEach { key in
            let value = self.gameState!.galaxyMap.getSystemForId(key)!
            let starPoint = self.convertStarCoordToScreen(value.position)
            
            value.connectingSystems.forEach { otherKey in
                if !allStars.contains(otherKey) {
                    return
                }
                let otherStar = self.gameState!.galaxyMap.getSystemForId(otherKey)!
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
        
        starsOnMap.forEach { key in
            
            
            let textColor = self.gameState!.player.visitedStars.contains(key) ? NSColor.white : NSColor(calibratedWhite: 0.7, alpha: 1.0)
            
            let value = self.gameState!.galaxyMap.getSystemForId(key)!
            let diameter = Double(20 + 4*self.zoomLevel)
            let starPoint = self.convertStarCoordToScreen(value.position)
            
            self.drawStringCenteredAt(point: CGPoint(x: starPoint.x, y: starPoint.y + diameter/2), text: value.name, textColor: textColor)
            
            if self.gameState!.player.location == key {
                NSColor.red.setFill()
            }
            else if self.gameState!.player.visitedStars.contains(key) {
                NSColor.white.setFill()
            }
            else {
                NSColor(calibratedWhite: 0.7, alpha: 1.0).setFill()
            }

            let circleRect = NSRect(x: starPoint.x - diameter/2, y: starPoint.y - diameter/2, width: diameter, height: diameter)
            let circlePath = NSBezierPath(ovalIn: circleRect)
            circlePath.fill()
        }
        
        let crosshairLength = 15.0
        let centerScreen = NSPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        if ((centerScreen.x + crosshairLength) > dirtyRect.origin.x) && ((centerScreen.y + crosshairLength) > dirtyRect.origin.y) &&
            ((centerScreen.x - crosshairLength) < (dirtyRect.origin.x + dirtyRect.size.width)) &&
            ((centerScreen.y - crosshairLength) < (dirtyRect.origin.y + dirtyRect.size.height)) {
            NSColor(calibratedRed: 0.5, green: 0.0, blue: 0.0, alpha: 1.0).setStroke()
            
            let crosshair = NSBezierPath()
            crosshair.move(to: NSPoint(x: centerScreen.x - 5, y: centerScreen.y))
            crosshair.line(to: NSPoint(x: centerScreen.x - crosshairLength, y: centerScreen.y))
            crosshair.move(to: NSPoint(x: centerScreen.x + 5, y: centerScreen.y))
            crosshair.line(to: NSPoint(x: centerScreen.x + crosshairLength, y: centerScreen.y))
            crosshair.move(to: NSPoint(x: centerScreen.x, y: centerScreen.y - 5))
            crosshair.line(to: NSPoint(x: centerScreen.x, y: centerScreen.y - crosshairLength))
            crosshair.move(to: NSPoint(x: centerScreen.x, y: centerScreen.y + 5))
            crosshair.line(to: NSPoint(x: centerScreen.x, y: centerScreen.y + crosshairLength))
            crosshair.lineWidth = 1
            crosshair.stroke()
        }
    }
    
    func drawStringCenteredAt(point : CGPoint, text : String, textColor: NSColor ) {
        let attributes = [NSAttributedString.Key.font:NSFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor:textColor]
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
