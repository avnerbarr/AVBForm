//
//  AVBComponent.swift
//  AVBForm
//
//  Created by Avner on 5/7/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

struct AVBState {
    
}

typealias AVBStateClosure = (component : AVBComponent,state : AVBState) -> ()

//MARK: -
//MARK: AVBComponent
class AVBComponent :   AVBComponentSectionProtocol,AVBValidatable {

    var title : String?
    var detailText = ""
    var labelStyle = UITableViewCellStyle.Default
    /**
    Weak reference to parent accordione container
    */
    weak var accordione : AVBAccordioneComponent?
    
    /**
    Mark if this value is required
    */
    var mandatory = true
    /**
    This is for API user - wishing to mark this component
    */
    var identifier : String?
    
    /**
    Called in certain events when the state changes
    */
    var stateChanged : AVBStateClosure?
    
    /// Weak reference to the parent group
    weak var parent : AVBFormSection?
    func numberOfRows() -> Int {return 0}
    func needsReload() {
        self.parent?.needsReload(self)
    }
    func needsUpdateRowCount() {
        self.parent?.needsUpdateRowCount(self)
    }
    //MARK: AVBComponentGroupProtocol
    func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.Simple
    }
    func prepareCell(cell : AVBFormTableViewCell, index : Int) {}
    func didSelectCell(cell : AVBFormTableViewCell, index : Int) {}
    func heightForRowAtIndex(index : Int) -> CGFloat {return 44.0}
    
    //MARK: AVBValidatable
    func isValid() -> Bool {
        return true
    }
    func markInvalid() {
        
    }
}

extension AVBComponent : Equatable {
    
}

func ==(lhs: AVBComponent, rhs: AVBComponent) -> Bool {
    return lhs === rhs
}

class AVBFullScreenComponent : AVBComponent {
    let childComponent : AVBComponent
    override var detailText : String {
        didSet {
            self.parent?.cellForComponent(self)?.detailTextLabel?.text = detailText
        }
    }
    init(component : AVBComponent) {
        childComponent = component
    }
    override func numberOfRows() -> Int {
        return 1
    }
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.Simple
    }
    override func prepareCell(cell: AVBFormTableViewCell, index: Int) {
        cell.textLabel?.text = self.title
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.detailTextLabel?.text = detailText
    }
    override func didSelectCell(cell: AVBFormTableViewCell, index: Int) {
        var group = AVBFormSection(title: "Test", schemes: [childComponent])
        var form = AVBForm(groups: [group], tableView: nil)
        self.parent?.form?.presentChildForm(form)
    }
    override func isValid() -> Bool {
        return childComponent.isValid()
    }
}

//MARK:-
//MARK: AVBArrayItem

/**
*  Represents a choice item
*/
struct AVBArrayItem {
    /// Assign this id to loop up on
    var id : String?
    /// The title to display
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
    /// Mark as selected
    var selected = false
}


class AVBInlineArrayComponent : AVBComponent {
    private(set) var arrayItems : [AVBArrayItem]
    
    /**
    initialize an inline array component with an array of items
    
    :param: items The items to display
    
    :returns: The component
    */
    init(items : [AVBArrayItem]) {
        arrayItems = items
    }
    
    //MARK: -
    //MARK: Inherited
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
        return AVBFormTableView.CellIdentifiers.Simple
    }
    override func prepareCell(cell : AVBFormTableViewCell, index : Int) {
        if index == 0 {
            cell.model = AVBFormCellModel(text : self.title,detailText : nil, accesoryType : UITableViewCellAccessoryType.None,mandatory : self.mandatory)
            return
        }
        var item = self.arrayItems[index - 1]
        cell.textLabel?.text = item.title
        cell.model = AVBFormCellModel(text: item.title, detailText: nil, accesoryType: item.selected == true ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None, mandatory: false)
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
        stateChanged?(component : self,state: AVBState())
    }
    //MARK: AVBValidatable
    override func isValid() -> Bool {
        var selected = false
        for item in self.arrayItems {
            selected = selected || item.selected
            if selected == true {
                return true
            }
        }
        return selected
    }
}

//MARK: -
//MARK: AVBInlineMultiSelectComponent
class AVBInlineMultiSelectComponent : AVBInlineArrayComponent {
    // inherited from parent
}

//MARK: -
//MARK: AVBInlineRadioComponent

/**
*  Inline Radio Component - Allows only one simultaneous selection
*/
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

//MARK: -
//MARK: AVBInlineTextComponent

/**
*  Represent an inline text input
*/
class AVBInlineTextComponent : AVBComponent {
    struct Options {
        let keypad : UIKeyboardType
        let placeHolderText : String?
        var initialValue : String?
    }
    private var options : Options
    init(options : Options) {
        self.options = options
    }
    override func numberOfRows() -> Int {
        return 1
    }
    override func prepareCell(var cell: AVBFormTableViewCell, index: Int) {
        if let cell = cell as? AVBInlineTextCell {
            cell.setValues(self.title!, placeholder: options.placeHolderText, value: options.initialValue)
            cell.textView.addTarget(self, action: "textFieldDidChangeValue:", forControlEvents: UIControlEvents.EditingChanged)
            cell.textView.keyboardType = options.keypad
        }
    }
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.Text
    }
    @objc func textFieldDidChangeValue(textField : UITextField) {
        self.options.initialValue = textField.text
    }
    //MARK: AVBValidatable
    override func isValid() -> Bool {
        return !String.isEmptyOrNil(options.initialValue)
    }
}

//MARK: -
//MARK: AVBDateComponent

/**
*  Represent a simple date picker - can be placed inside an accordion
*  Has no label attached to it
*/

protocol AVBDateProtocol {
    init(options : DateOptions)
}

class AVBInlineDateComponent : AVBComponent ,AVBDateProtocol {

    var date : NSDate? {
        didSet(newDate){
            if let accordione = accordione, newDate = newDate {
                accordione.detailText = newDate.description
                dateOptions.date = newDate
            }
        }
    }
    private var dateOptions : DateOptions
    required init(options : DateOptions) {
        self.dateOptions = options
    }
    override func numberOfRows() -> Int {
        return 1
    }
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.DateTime
    }
    override func prepareCell(cell: AVBFormTableViewCell, index: Int) {

        if let cell = cell as? AVBFormDatePickerCell {
            cell.datePicker.addTarget(self, action: "datePickerDidChangeValue:", forControlEvents: UIControlEvents.ValueChanged)
            cell.datePicker.dateOptions = self.dateOptions
        }

    }
    
    @objc func datePickerDidChangeValue(picker : UIDatePicker) {
        if let accordione = accordione {
            accordione.detailText = picker.date.description
            date = picker.date
        }
    }
    override func heightForRowAtIndex(index: Int) -> CGFloat {
        return 200
    }
    //MARK: AVBValidatable
    override func isValid() -> Bool {
        return date != nil
    }

}

/**
*  Abstract class representing a composite of components
*/
class AVBCompositeComponent : AVBComponent {
    init(component : AVBComponent) {}
}

//MARK: -
//MARK: AVBAccordioneComponent

/**
*  Represents a collapsable component with a nested child component
*/
class AVBAccordioneComponent : AVBCompositeComponent {
    var childComponent : AVBComponent?
    override var detailText : String {
        didSet {
            if let cell = self.parent?.cellForComponent(self) {
                cell.detailTextLabel?.text = detailText
            }
        }
    }
    private var folded = true
    override var parent : AVBFormSection? {
        didSet {
            childComponent?.parent = parent
        }
    }
    override init(component : AVBComponent) {
        childComponent = component
        
        super.init(component: component)
        component.accordione = self
        childComponent?.parent = parent
    }
    
    override func numberOfRows() -> Int {
        if childComponent == nil {
            return 1
        }
        if folded == true {
            return 1
        }
        return childComponent!.numberOfRows() + 1
    }
    override func cellIdentifierForIndex(index: Int) -> AVBFormTableView.CellIdentifiers {
        if index == 0 {
            return AVBFormTableView.CellIdentifiers.Simple
        }
        return childComponent!.cellIdentifierForIndex(index-1)
    }
    override func prepareCell(cell: AVBFormTableViewCell, index: Int) {
        if index == 0 {
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = detailText
            return
        }
        childComponent!.prepareCell(cell, index: index-1)
    }
    override func didSelectCell(cell: AVBFormTableViewCell, index: Int) {
        if index == 0 {
            folded = !folded
            self.needsUpdateRowCount()
            self.needsReload()
            return
        }
        childComponent!.didSelectCell(cell, index: index-1)
    }
    override func heightForRowAtIndex(index: Int) -> CGFloat {
        if index == 0 {
            return super.heightForRowAtIndex(index)
        }
        return childComponent!.heightForRowAtIndex(index-1)
    }
}

//MARK: -
//MARK: AVBDateAccessoryComponent
/**
*  Represents a date picker component exposed as an accessory view
*/
class AVBDateAccessoryComponent : AVBComponent , AVBFormAccessoryCellDelegate,AVBDateProtocol /*, UIPickerViewDataSource, UIPickerViewDelegate*/ {
    
    var date : NSDate? {
        didSet(newDate) {
            dateOptions.date = newDate
            if let cell = self.parent?.cellForComponent(self) as? AVBFormAccessoryCell {
                cell.detailTextLabel?.text = newDate?.description
            }
        }
    }
    override func numberOfRows() -> Int {
        return 1
    }
    private var dateOptions : DateOptions
    required init(options : DateOptions) {
        self.dateOptions = options
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
        view.dateOptions = self.dateOptions
        return view
    }
    
    @objc func datePickerDidChangeValue(picker : UIDatePicker) {
        date = picker.date
    }
    
    //MARK: AVBValidatable
    override func isValid() -> Bool {
        return date != nil
    }
}