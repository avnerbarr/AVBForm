//
//  AVBComponent.swift
//  AVBForm
//
//  Created by Avner on 5/7/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit
/**
*  Defines functionality that the group needs from the form
*/
protocol AVBComponentGroupParentProtocol {
    func needsReload(AVBComponent)
    func needsUpdateRowCount(AVBComponent)
}

struct AVBState {
    
}

class AVBComponentGroup : AVBComponentGroupParentProtocol {
    var title : String?
    var identifier : String?
    weak var form : AVBForm?
    typealias InternalIndexMap = (scheme : AVBComponent,index : Int)
    
    var schemes : [AVBComponent] {
        didSet {
            updateInternals()
        }
    }
    private func updateInternals() {
        _numberOfRequiredRows = 0
        _internalIndexMap = [Int : InternalIndexMap]()
        for scheme in schemes {
            scheme.parent = self
            for i in 0..<scheme.numberOfRows() {
                _internalIndexMap[_numberOfRequiredRows] = (scheme,i)
                _numberOfRequiredRows++
            }
        }
    }
    
    private var _internalIndexMap = [Int : InternalIndexMap]()
    private var _numberOfRequiredRows = 0
    init(title : String?,schemes : [AVBComponent]) {

        self.title = title
        self.schemes = schemes
        updateInternals()
        
    }
    var numberOfRows : Int {
        get {
            return _numberOfRequiredRows
        }
    }
    
    func internalIndexMap(indexPath : NSIndexPath) -> InternalIndexMap? {
        if let internalMap = _internalIndexMap[indexPath.row] {
            return internalMap
        }
        return nil
    }
    func heightForRowAtIndexPath(indexPath : NSIndexPath , tableView : AVBFormTableView) -> CGFloat {
        if let map = self.internalIndexMap(indexPath) {
            return map.scheme.heightForRowAtIndex(map.index)
        }
        return 0
    }
    func cellForRowAtIndex(indexPath : NSIndexPath, tableView : AVBFormTableView) -> AVBFormTableViewCell? {
        if let map = self.internalIndexMap(indexPath) {
            var identifier = map.scheme.cellIdentifierForIndex(map.index)
            var cell = tableView.dequeueReusableCellWithIdentifier(identifier.identifier, forIndexPath: indexPath) as! AVBFormTableViewCell
            map.scheme.prepareCell(cell, index: map.index)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AVBFormTableViewCell
        cell.textLabel?.text = "Fucked"
        return cell
        
    }
    
    func didSelectRowAtIndexPath(tableView : AVBFormTableView,indexPath : NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let map = _internalIndexMap[indexPath.row], cell = tableView.cellForRowAtIndexPath(indexPath) as? AVBFormTableViewCell {
            map.scheme.didSelectCell(cell, index: map.index)
        }
    }
    
    func replace(toReplace : AVBComponent, newComponent : AVBComponent) {
        var components = self.schemes
        if let index = find(self.schemes,toReplace) {
            components[index] = newComponent
            self.schemes = components
            self.form?.delegate?.needsGroupReload(self.form!, group: self)
        }
    }
    //MARK: AVBComponentGroupParentProtocol
    func needsReload(section : AVBComponent) {
        self.form?.delegate?.needsGroupReload(self.form!, group: self)
    }
    func needsUpdateRowCount(component : AVBComponent) {
        updateInternals()
    }
}

/**
*  Defines methods to populate items of a scheme in a group
*/
protocol AVBComponentGroupProtocol {
    func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers
    func prepareCell(cell : AVBFormTableViewCell, index : Int)
    func didSelectCell(cell : AVBFormTableViewCell, index : Int)
    func heightForRowAtIndex(index : Int) -> CGFloat
}

typealias AVBStateClosure = (component : AVBComponent,state : AVBState) -> ()
class AVBComponent :   AVBComponentGroupProtocol {

    var title : String?
    var labelStyle = LabelStyle.Normal
    var mandatory = false
    var identifier : String?
    var stateChanged : AVBStateClosure?
    enum LabelStyle {
        case Normal
        case Special
    }
    weak var parent : AVBComponentGroup?
    func numberOfRows() -> Int {return 0}
    func needsReload() {
        self.parent?.needsReload(self)
    }
    func needsUpdateRowCount() {
        self.parent?.needsUpdateRowCount(self)
    }
    //MARK: AVBComponentGroupProtocol
    func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.Cell1
    }
    func prepareCell(cell : AVBFormTableViewCell, index : Int) {}
    func didSelectCell(cell : AVBFormTableViewCell, index : Int) {
        
    }
    func heightForRowAtIndex(index : Int) -> CGFloat {return 44.0}
}

extension AVBComponent : Equatable {
    
}

func ==(lhs: AVBComponent, rhs: AVBComponent) -> Bool {
    return lhs === rhs
}
struct AVBArrayItem {
    var id : String?
    var title : String?
    init (id : String? , title : String?) {
        self.id = id
        self.title = title
    }
    init (id : String? , title : String?,selected : Bool) {
        self.id = id
        self.title = title
        self.selected = selected
    }
    var selected = false
}


class AVBInlineArrayComponent : AVBComponent {
    var arrayItems : [AVBArrayItem]
    
    init(items : [AVBArrayItem]) {
        arrayItems = items
    }
    override func numberOfRows() -> Int {
        if self.title == nil || self.title == "" {
            return self.arrayItems.count
        }
        if (self.arrayItems.count == 0) {
            return 0
        }
        return self.arrayItems.count + 1
    }
    //MARK: AVBComponentGroupProtocol
    override func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.Cell1
    }
    override func prepareCell(cell : AVBFormTableViewCell, index : Int) {
        if index == 0 {
            cell.textLabel?.text = self.title
            cell.accessoryType = UITableViewCellAccessoryType.None
            return
        }
        var item = self.arrayItems[index - 1]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.selected == true ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
    }
    
    override func didSelectCell(cell : AVBFormTableViewCell, index : Int) {
        if index == 0 {
            return
        }
        if cell.isFirstResponder() == true {
            cell.resignFirstResponder()
        }
        var item = self.arrayItems[index - 1]
        item.selected = !item.selected
        self.arrayItems[index - 1] = item
        prepareCell(cell, index: index)
    }
}

class AVBInlineMultiSelectComponent : AVBInlineArrayComponent {
    // inherited from parent
}

class AVBInlineRadioComponent : AVBInlineArrayComponent {
    override func didSelectCell(cell : AVBFormTableViewCell, index : Int) {
        if index == 0 {
            return
        }
        super.didSelectCell(cell, index: index)
        var array = self.arrayItems.dynamicType()
        var needsReload = false
        for (arrayindex,var item) in enumerate(self.arrayItems) {
            if arrayindex != index-1 {
                if item.selected == true {
                    needsReload = true
                }
                item.selected = false
            }
            array.append(item)
        }
        self.arrayItems = array
        if needsReload {
            self.needsReload()
        }
        if let state = self.stateChanged {
            state(component: self, state: AVBState())
        }
    }
    
    //MARK: AVBComponentGroupProtocol
    override func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers {
        if index == 0 {
            return AVBFormTableView.CellIdentifiers.RadioHeader
        }
        return AVBFormTableView.CellIdentifiers.RadioCell
    }
}

class AVBInlineTextComponent : AVBComponent {
    override func numberOfRows() -> Int {
        return 1
    }
    override func prepareCell(var cell: AVBFormTableViewCell, index: Int) {
        (cell as! AVBInlineTextCell).setValues("Avner", placeholder: "Barr")
        
    }
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.Text
    }
}

class AVBDateComponent : AVBComponent {
    override func numberOfRows() -> Int {
        return 1
    }
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.DateTime
    }
    override func prepareCell(cell: AVBFormTableViewCell, index: Int) {
        for view in cell.contentView.subviews as! [UIView] {
            view.removeFromSuperview()
        }
        var picker = UIDatePicker()
        picker.sizeToFit()
        cell.contentView.addSubview(picker)

    }
    var _sizeThatFits : CGFloat?
    var sizeThatFits : CGFloat {
        if _sizeThatFits != nil {
            return _sizeThatFits!
        }
        var picker = UIDatePicker()
        picker.sizeToFit()
        _sizeThatFits = picker.frame.height
        return _sizeThatFits!
    }
    override func heightForRowAtIndex(index: Int) -> CGFloat {
        return sizeThatFits
    }
}

class AVBCompositeComponent : AVBComponent {
    init(component : AVBComponent) {}
}

class AVBAccordioneComponent : AVBCompositeComponent {
    var accordione : AVBComponent?
    var folded = true
    override var parent : AVBComponentGroup? {
        didSet {
            accordione?.parent = parent
        }
    }
    override init(component : AVBComponent) {
        accordione = component
        super.init(component: component)
    }
    
    override func numberOfRows() -> Int {
        if accordione == nil {
            return 1
        }
        if folded == true {
            return 1
        }
        return accordione!.numberOfRows() + 1
    }
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        if index == 0 {
            return AVBFormTableView.CellIdentifiers.Cell1
        }
        return accordione!.cellIdentifierForIndex(index-1)
    }
    override func prepareCell(cell: AVBFormTableViewCell, index: Int) {
        if index == 0 {
            cell.textLabel?.text = self.title
            return
        }
        accordione!.prepareCell(cell, index: index-1)
    }
    override func didSelectCell(cell: AVBFormTableViewCell, index: Int) {
        if index == 0 {
            folded = !folded
            self.needsUpdateRowCount()
            self.needsReload()
            return
        }
        accordione!.didSelectCell(cell, index: index-1)
    }
    override func heightForRowAtIndex(index: Int) -> CGFloat {
        if index == 0 {
            return super.heightForRowAtIndex(index)
        }
        return accordione!.heightForRowAtIndex(index-1)
    }
}

class AVBDateAccessoryComponent : AVBComponent , AVBFormAccessoryCellDelegate /*, UIPickerViewDataSource, UIPickerViewDelegate*/ {
    
    var date : NSDate?
    override func numberOfRows() -> Int {
        return 1
    }
    override func prepareCell(cell: AVBFormTableViewCell, index: Int) {
        if let cell = cell as? AVBFormAccessoryCell {
            cell.accessoryDelegate = self
        }
        cell.textLabel?.text = self.title
        cell.detailTextLabel?.text = date?.description
    }
    
    override func didSelectCell(cell: AVBFormTableViewCell, index: Int) {
        cell.becomeFirstResponder()
    }
    
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.Accessory
    }
    
    func accessoryView(AVBFormAccessoryCell) -> UIView? {
        let view = UIDatePicker()
        view.addTarget(self, action: "datePickerDidChangeValue:", forControlEvents: UIControlEvents.ValueChanged)
        return view
    }
    
    @objc func datePickerDidChangeValue(picker : UIDatePicker) {
        date = picker.date
        self.needsReload()
    }
}