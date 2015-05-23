//
//  AVBComponentGroup.swift
//  AVBForm
//
//  Created by Avner on 5/10/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit


/**
*  Defines functionality that the section needs from the form
*/
protocol AVBFormSectionParentProtocol {
    /**
    Called by the component to request a reload on itself. If The component needs to update its row count - call needs update row count first
    */
    func needsReload(AVBComponent)
    /**
    Called by a component when it needs to update its row count. If the row count changes, call this before calling 'needsReload'
    
    */
    func needsUpdateRowCount(AVBComponent)
    /**
    Get the cell for the component if visible
    
    :param: component The component to loop up for
    
    :returns: The cell if available
    */
    func cellForComponent(component : AVBComponent) -> AVBFormTableViewCell?
}



class AVBFormSection : AVBFormSectionParentProtocol , AVBValidatable {
    var title : String?
    var identifier : String?
    /// weak reference to the parent
    weak var form : AVBForm?
    
    /**
    *  internal representation of a UITableView index path
    *
    *  @param AVBComponent The component
    *  @param Int          The internal row
    *
    *  @return The mapping pair
    */
    typealias InternalIndexMap = (scheme : AVBComponent,index : Int)
    
    private(set) var components : [AVBComponent] {
        didSet {
            updateInternals()
        }
    }
    private func updateInternals() {
        _numberOfRequiredRows = 0
        _internalIndexMap = [Int : InternalIndexMap]()
        for scheme in components {
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
        self.components = schemes
        updateInternals()
        
    }
    var numberOfRows : Int {
        get {
            return _numberOfRequiredRows
        }
    }
    
    private func internalIndexMap(indexPath : NSIndexPath) -> InternalIndexMap? {
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
            // get the runtime cell class to create the cell
            var cellClass : AVBFormTableViewCell.Type = identifier.cellClass as! AVBFormTableViewCell.Type
            // no reuse of the cells because it would be complicated to populate
            var cell = cellClass(style : map.scheme.labelStyle, reuseIdentifier : identifier.identifier)
            map.scheme.prepareCell(cell, index: map.index)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        /// Bug in the mapping
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
    
    //MARK: -
    //MARK: API
    func replace(toReplace : AVBComponent, newComponent : AVBComponent) {
        var components = self.components
        if let index = find(self.components,toReplace) {
            components[index] = newComponent
            self.components = components
            self.form?.dataSource?.needsGroupReload(self.form!, group: self)
        }
    }
    //MARK: AVBFormSectionParentProtocol
    func needsReload(section : AVBComponent) {
        self.form?.dataSource?.needsGroupReload(self.form!, group: self)
    }
    func needsUpdateRowCount(component : AVBComponent) {
        updateInternals()
    }
    func cellForComponent(component : AVBComponent) -> AVBFormTableViewCell? {
        var section = find(self.form!.groups, self)
        if let visible = self.form?.tableView?.indexPathsForVisibleRows() as? [NSIndexPath] {
            for index in visible {
                if index.section != section {
                    continue
                }
                if let map = internalIndexMap(index) {
                    if map.scheme == component {
                        return self.form?.tableView?.cellForRowAtIndexPath(index) as? AVBFormTableViewCell
                    }
                    
                }
            }
        }
        return nil
    }
    
    //MARK: AVBValidatable
    
    func isValid() -> Bool {
        var valid = true
        for component in self.components {
            valid = valid && component.isValid()
            if valid == false {
                return false
            }
        }
        return true
    }
    
    func markInvalid() {
        for component in components {
            component.markInvalid()
        }
    }
    
    var mode = Mode.Normal {
        didSet {
            for component in components {
                component.mode = mode
            }
        }
    }
}

extension AVBFormSection : Equatable {}
func ==(lhs : AVBFormSection, rhs: AVBFormSection) -> Bool {
    return lhs===rhs
}

/**
*  Defines methods to populate items of a scheme in a section
*/
protocol AVBComponentSectionProtocol {
    func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers
    func prepareCell(cell : AVBFormTableViewCell, index : Int)
    func didSelectCell(cell : AVBFormTableViewCell, index : Int)
    func heightForRowAtIndex(index : Int) -> CGFloat
}
