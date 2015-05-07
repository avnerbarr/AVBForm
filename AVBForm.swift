//
//  AVBFormItem.swift
//  AVBForm
//
//  Created by Avner on 5/5/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

struct AVBComponentConfiguration {
    let needsHeaderLine : Bool
    let numberOfLines : Int
    let headerCellClass : AnyClass
    let cellClass : AnyClass
}

class AVBFormTableViewCell : UITableViewCell {
    
}

protocol AVBInlineTextCellProtocol {
    func setValues(label : String , placeholder : String)
    func getText()->String
}

class AVBInlineTextCell : AVBFormTableViewCell,AVBInlineTextCellProtocol {
    let label = UILabel()
    let textView = UITextView()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        var r1 = CGRectZero,r2 = CGRectZero
        CGRectDivide(self.contentView.bounds, &r1, &r2, 30, CGRectEdge.MinXEdge)
        label.frame = r1
        textView.frame = r2
    }
    func commonInit() {

        self.contentView.addSubview(label)
        self.contentView.addSubview(textView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification : NSNotification) {
        if !self.textView.isFirstResponder() {
            return
        }

        if let keywindowFrame = self.keyWindowFrame, kbframe = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            if CGRectIntersectsRect(keyWindowFrame!, kbframe) {
                var superView = self.superview
                while superView != nil {
                    if let superView = superView as? UITableView {
                        superView.contentInset = UIEdgeInsets(top: superView.contentInset.top, left: 0, bottom: superView.contentInset.bottom + kbframe.height, right: 0)
                        superView.setContentOffset(CGPointMake(0, superView.contentOffset.y + kbframe.height), animated: true)
                        break
                    }
                    superView = superView?.superview
                }
            }
        }

    }
    func keyboardWillHide(notification : NSNotification) {
        if !self.textView.isFirstResponder() {
            return
        }
        var superView = self.superview
        while superView != nil {
            if let superView = superView as? UITableView {
                superView.contentInset = UIEdgeInsets(top: superView.contentInset.top, left: 0, bottom: 0, right: 0)
                break
            }
            superView = superView?.superview
        }


    }
    func keyboardWillChangeFrame(notification : NSNotification) {
        
    }
    
    func setValues(label : String , placeholder : String) {
        self.label.text = label
        self.textView.text = placeholder
    }
    
    func getText()->String {
        return self.textView.text
    }
}
/**
*  Defines functionality the form needs from the controller
*/
protocol AVBFormProtocol : class {
    func needsGroupReload(form : AVBForm , group : AVBComponentGroup)
}

class AVBForm {
    let schemes : [AVBComponentGroup]
    weak var delegate : AVBFormProtocol?
    subscript(index : Int) -> AVBComponentGroup? {
        if schemes.count > index {
            return schemes[index]
        }
        return nil
    }
    init(schemes : [AVBComponentGroup]) {
        self.schemes = schemes
        for group in schemes {
            group.form = self
        }
    }
}

/**
*  Defines functionality that the group needs from the form
*/
protocol AVBComponentGroupParentProtocol {
    func needsReload(AVBComponent)
}
class AVBComponentGroup : AVBComponentGroupParentProtocol {
    var title : String?
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

    //MARK: AVBComponentGroupParentProtocol
    func needsReload(section : AVBComponent) {
        self.form?.delegate?.needsGroupReload(self.form!, group: self)
    }
}

/**
*  Defines methods to populate items of a scheme in a group
*/
protocol AVBComponentGroupProtocol {
    func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers
    func prepareCell(cell : AVBFormTableViewCell, index : Int)
    func didSelectCell(cell : AVBFormTableViewCell, index : Int)
}

class AVBComponent : AVBComponentGroupProtocol {
    var title : String?
    var labelStyle = LabelStyle.Normal
    enum LabelStyle {
        case Normal
        case Special
    }
    weak var parent : AVBComponentGroup?
    func numberOfRows() -> Int {return 0}
    func needsReload() {
        self.parent?.needsReload(self)
    }
    //MARK: AVBComponentGroupProtocol
    func cellIdentifierForIndex(index : Int) -> AVBFormTableView.CellIdentifiers {
        return AVBFormTableView.CellIdentifiers.cell1
    }
    func prepareCell(cell : AVBFormTableViewCell, index : Int) {}
    func didSelectCell(cell : AVBFormTableViewCell, index : Int) {}
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


class AVBArrayComponent : AVBComponent {
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
        return AVBFormTableView.CellIdentifiers.cell1
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
        var item = self.arrayItems[index - 1]
        item.selected = !item.selected
        self.arrayItems[index - 1] = item
        prepareCell(cell, index: index)
    }
}

class AVBMultiSelectComponent : AVBArrayComponent {
// inherited from parent
}

class AVBRadioComponent : AVBArrayComponent {
    override func didSelectCell(cell : AVBFormTableViewCell, index : Int) {
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
        return AVBFormTableView.CellIdentifiers.text
    }
}

class AVBNavigationScheme : AVBComponent {
    override func numberOfRows() -> Int {
        return 1
    }
}

class AVBAccessoryViewScheme : AVBComponent {
    var accessoryViewScheme : AVBComponent?
    override func numberOfRows() -> Int {
        return 1
    }
}

class AVBSection {
    var title : String?
    var schemes : [AVBComponent]?
}

enum AnswerFormat {
    case Date
    case Numeric
    case Text
}

extension UIView {
    var keyWindowFrame : CGRect? {
        get {
            return UIApplication.sharedApplication().keyWindow?.convertRect(self.frame, fromView: self.superview)
        }
    }
}




