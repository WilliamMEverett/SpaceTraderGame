//
//  MarketPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/12/22.
//

import Cocoa

class MarketPanelViewController: GameViewPanelViewController {

    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var selectionHolderView: NSView!
    @IBOutlet weak var commoditySelectionButton: NSPopUpButton!
    
    @IBOutlet weak var transactionHolderView: NSView!
    @IBOutlet weak var commodityTitleLabel: NSTextField!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var currentQuantityLabel: NSTextField!
    @IBOutlet weak var transactionDescriptionLabel: NSTextField!
    @IBOutlet weak var buyPriceLabel: NSTextField!
    @IBOutlet weak var sellPriceLabel: NSTextField!
    @IBOutlet weak var buy1Button: NSButton!
    @IBOutlet weak var buy10Button: NSButton!
    @IBOutlet weak var buyAllButton: NSButton!
    @IBOutlet weak var sell1Button: NSButton!
    @IBOutlet weak var sell10Button: NSButton!
    @IBOutlet weak var sellAllButton: NSButton!
    
    private var selectedCommodity : Commodity? = nil
    private var commodityArray = [Commodity]()
    private var quantityToBuy : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commoditySelectionButton.removeAllItems()
        self.commodityArray.removeAll()
        
        let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location)
        Commodity.allCases.forEach { comm in
            if (currentStar?.market?.target[comm] ?? 0) != 0 {
                self.commoditySelectionButton.addItem(withTitle: "\(comm)")
                self.commodityArray.append(comm)
            }
        }
        self.commoditySelectionButton.selectItem(at: -1)
        
        self.refreshView()
    }
    
    func refreshView() {
        guard let selComm = self.selectedCommodity else {
            self.selectionHolderView.isHidden = false
            self.transactionHolderView.isHidden = true
            return
        }
        
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        
        self.selectionHolderView.isHidden = true
        self.transactionHolderView.isHidden = false
        
        self.commodityTitleLabel.stringValue = "\(selComm)"
        let currentQty = Int(self.gameState.player.ship.commodities[selComm] ?? 0)
        self.currentQuantityLabel.stringValue = "\(currentQty)"
        
        let remainingCargoSpace = Int(self.gameState.player.ship.cargo - self.gameState.player.ship.totalCargoWeight())
        
        let negotiationAdjustment = self.gameState.player.negotiationPriceAdjustment()
        
        let effectiveMarketQty = (currentStar.market!.stock[selComm] ?? 0) - self.quantityToBuy
        let centerPrice = currentStar.market!.priceForCommodityAtQty(comm: selComm, qty: effectiveMarketQty)!
        self.buyPriceLabel.stringValue = String(format: "%.1f", centerPrice*(1+negotiationAdjustment))
        self.sellPriceLabel.stringValue = String(format: "%.1f", centerPrice*(1-negotiationAdjustment))
        
        self.buy1Button.isEnabled = false
        self.buy10Button.isEnabled = false
        self.buyAllButton.isEnabled = false
        self.sell1Button.isEnabled = false
        self.sell10Button.isEnabled = false
        self.sellAllButton.isEnabled = false
        
        if effectiveMarketQty >= 1 && (self.quantityToBuy < 0 || self.cumulativeCostToBuy(comm: selComm, qty: self.quantityToBuy + 1) <= Double(self.gameState.player.money) && (self.quantityToBuy + 1 <= remainingCargoSpace)) {
            self.buy1Button.isEnabled = true
        }
        if effectiveMarketQty >= 10 && (self.quantityToBuy <= -10 || self.cumulativeCostToBuy(comm: selComm, qty: self.quantityToBuy + 10) <= Double(self.gameState.player.money) && (self.quantityToBuy + 10 <= remainingCargoSpace)) {
            self.buy10Button.isEnabled = true
        }
        if currentQty + self.quantityToBuy >= 1 {
            self.sell1Button.isEnabled = true
        }
        if currentQty + self.quantityToBuy >= 10 {
            self.sell10Button.isEnabled = true
        }
        
        if effectiveMarketQty > 0 {
            self.buyAllButton.isEnabled = true
        }
        if self.quantityToBuy > 0 || currentQty > 0 {
            self.sellAllButton.isEnabled = true
        }
        
        self.executeButton.isEnabled = true
        if self.quantityToBuy == 0 {
            self.transactionDescriptionLabel.stringValue = "Buy or sell"
            self.executeButton.isEnabled = false
        }
        else {
            let price = Int(ceil(self.cumulativeCostToBuy(comm: selComm, qty: self.quantityToBuy)))
            if self.quantityToBuy > 0 {
                self.transactionDescriptionLabel.stringValue = "Buy \(self.quantityToBuy) for \(price) cr"
            }
            else {
                self.transactionDescriptionLabel.stringValue = "Sell \(-1*self.quantityToBuy) for \(-1*price) cr"
            }
        }
        
    }
    
    private func cumulativeCostToBuy(comm: Commodity, qty: Int) -> Double {
        if qty == 0 {
            return 0
        }
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return 0
        }
        
        let negotiationAdjustment = self.gameState.player.negotiationPriceAdjustment()
        let buyNSell = qty > 0 ? true : false
        let absoluteQty = abs(qty)
        let currentMarkeyQty = currentStar.market!.stock[comm] ?? 0
        var total : Double = 0
        for inc in 0..<absoluteQty {
            let testQty = buyNSell ? currentMarkeyQty - inc : currentMarkeyQty + inc
            if testQty < 0 {
                break
            }
            let centerPrice = currentStar.market!.priceForCommodityAtQty(comm: comm, qty: testQty)!
            let effPrice = buyNSell ? centerPrice*(1+negotiationAdjustment) : centerPrice*(1-negotiationAdjustment)
            total += effPrice
        }
        return buyNSell ? total : -1*total
    }
    
    private func maxQuantityToBuyForCost(comm: Commodity, max_qty: Int, cost: Int) -> Int {
        if max_qty <= 0 || cost <= 0 {
            return 0
        }
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return 0
        }
        
        let negotiationAdjustment = self.gameState.player.negotiationPriceAdjustment()
        
        let currentMarkeyQty = currentStar.market!.stock[comm] ?? 0
        var totalPrice : Double = 0
        var finalQty : Int = 0
        for inc in 0..<max_qty {
            let testQty = currentMarkeyQty - inc
            if testQty < 0 {
                break
            }
            let centerPrice = currentStar.market!.priceForCommodityAtQty(comm: comm, qty: testQty)!
            let effPrice = centerPrice*(1+negotiationAdjustment)
            totalPrice += effPrice
            if totalPrice > Double(cost) {
                break
            }
            finalQty = inc + 1
        }
        return finalQty
    }
    
    //MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        if self.selectedCommodity != nil {
            self.selectedCommodity = nil
            self.commoditySelectionButton.selectItem(at: -1)
            self.quantityToBuy = 0
            self.refreshView()
            return
        }
        
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    @IBAction func commoditySelectionButtonUsed( _ sender : NSPopUpButton) {
        if self.commoditySelectionButton.indexOfSelectedItem < 0 || self.commoditySelectionButton.indexOfSelectedItem >= self.commodityArray.count {
            return
        }
        self.selectedCommodity = self.commodityArray[self.commoditySelectionButton.indexOfSelectedItem]
        self.refreshView()
    }
    
    @IBAction func buy1ButtonPressed(_ sender: NSButton) {
        self.quantityToBuy += 1
        self.refreshView()
    }
    
    @IBAction func buy10ButtonPressed(_ sender: NSButton) {
        self.quantityToBuy += 10
        self.refreshView()
    }
    
    @IBAction func buyAllButtonPressed(_ sender: NSButton) {
        guard let selComm = self.selectedCommodity else {
            return
        }
        
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        
        let remainingCargoSpace = Int(self.gameState.player.ship.cargo - self.gameState.player.ship.totalCargoWeight())
        let marketQty = (currentStar.market!.stock[selComm] ?? 0)
        let maxSpace = remainingCargoSpace < marketQty ? remainingCargoSpace : marketQty
        
        let maxQty = self.maxQuantityToBuyForCost(comm: selComm, max_qty: maxSpace, cost: self.gameState.player.money)
        self.quantityToBuy = maxQty
        self.refreshView()
        
    }
    
    @IBAction func sell1ButtonPressed(_ sender: NSButton) {
        self.quantityToBuy -= 1
        self.refreshView()
    }
    
    @IBAction func sell10ButtonPressed(_ sender: NSButton) {
        self.quantityToBuy -= 10
        self.refreshView()
    }
    
    @IBAction func sellAllButtonPressed(_ sender: NSButton) {
        guard let selComm = self.selectedCommodity else {
            return
        }
        
        let currentQty = Int(self.gameState.player.ship.commodities[selComm] ?? 0)
        self.quantityToBuy = -1*currentQty
        self.refreshView()
    }
    
    @IBAction func executeButtonPressed(_ sender: NSButton) {
        guard let selComm = self.selectedCommodity else {
            return
        }
        
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        
        let currentMarket = currentStar.market!.stock[selComm] ?? 0
        let remainingCargoSpace = Int(self.gameState.player.ship.cargo - self.gameState.player.ship.totalCargoWeight())
        let currentQty = Int(self.gameState.player.ship.commodities[selComm] ?? 0)
        
        let price = Int(ceil(self.cumulativeCostToBuy(comm: selComm, qty: self.quantityToBuy)))
        if price > self.gameState.player.money {
            self.refreshView()
            return
        }
        if self.quantityToBuy > remainingCargoSpace {
            self.refreshView()
            return
        }
        if self.quantityToBuy > currentMarket {
            self.refreshView()
            return
        }
        if self.quantityToBuy + currentQty < 0 {
            self.refreshView()
            return
        }
        
        let verb = self.quantityToBuy > 0 ? "Bought" : "Sold"
        self.gameState.addLogEntry("\(verb) \(abs(self.quantityToBuy)) \(selComm) for \(abs(price))cr")
        
        currentStar.market!.stock[selComm] = currentMarket - self.quantityToBuy
        self.gameState.player.ship.commodities[selComm] = Double(currentQty + self.quantityToBuy)
        self.gameState.player.money -= price
        self.quantityToBuy = 0
        self.refreshView()
        
        self.gameState.player.negotiationExperience += (Double(abs(price))/400.0)
        
        currentStar.starSystemUpdated()
    }
}
