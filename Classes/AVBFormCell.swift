//
//  AVBFormCell.swift
//  AVBForm
//
//  Created by Avner on 5/9/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit


struct AVBFormCellModel {
    let text : String?
    let detailText : String?
    let accesoryType : UITableViewCellAccessoryType?
    let mandatory : Bool?
}

struct AVBFormCellAppearance {
    struct Border {
        let color : UIColor
        let width : CGFloat
    }
    let border : Border?
}

class AVBFormTableViewCell : UITableViewCell {
    
    lazy var requiredSymbol : UILabel = {
       var symbol = UILabel(frame: CGRect(x: 5, y: 5, width: 10, height: 10))
        symbol.backgroundColor = UIColor.clearColor()
        symbol.text = "*"
        symbol.sizeToFit()
        symbol.frame.origin = CGPoint(x: 5, y: 5)
        symbol.textColor = UIColor.redColor()
        return symbol
    }()
    override func prepareForReuse() {
        accessoryType = .None
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var cellText : String? {
        get {
            return textLabel?.text
        }
        set(theText) {
            textLabel?.text = theText
        }
    }
    var detailText : String? {
        get {
            return detailTextLabel?.text
        }
        set(theText)  {
            detailTextLabel?.text = theText
        }
    }
    var model = AVBFormCellModel(text: nil, detailText: nil, accesoryType: UITableViewCellAccessoryType.None, mandatory: false) {
        didSet {
            cellText = model.text
            detailText = model.detailText
            accessoryType = model.accesoryType ?? UITableViewCellAccessoryType.None
            mandatory = model.mandatory ?? false
        }
    }    
    enum Validity {
        case None
        case Valid
        case Invalid
    }
    
    private var mandatory = false {
        didSet {
            if mandatory == true {
                contentView.addSubview(requiredSymbol)
                contentView.bringSubviewToFront(requiredSymbol)
                requiredSymbol.hidden = false
            } else {
                requiredSymbol.hidden = true
            }
        }
    }
}



class AVBFormDatePickerCell : AVBFormTableViewCell {
    let datePicker = UIDatePicker()
    //MARK: -
    //MARK: Lifecycle
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        datePicker.sizeToFit()
        contentView.addSubview(datePicker)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit {
        datePicker.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
    }
    
    override func prepareForReuse() {
        datePicker.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func canResignFirstResponder() -> Bool {
        return true
    }
    override func becomeFirstResponder() -> Bool {
        return datePicker.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        return datePicker.resignFirstResponder()
    }
}

class AVBFormRadioHeaderCell: AVBFormTableViewCell {
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.lightGrayColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class AVBFormKeyboardAvoidingCell : AVBFormTableViewCell {
    func registerKeyboardListeners() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func keyboardWillShow(notification : NSNotification) {
        if !self.isFirstResponder() {
            return
        }
        
        if let keywindowFrame = self.keyWindowFrame, kbframe = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            if CGRectIntersectsRect(keyWindowFrame!, kbframe) {
                var superView = self.superview
                while superView != nil {
                    if let superView = superView as? UITableView {
                        superView.contentInset = UIEdgeInsets(top: superView.contentInset.top, left: 0, bottom: superView.contentInset.bottom + kbframe.height, right: 0)
                        var duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                        
                        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            superView.contentOffset = CGPointMake(0, superView.contentOffset.y + kbframe.height)
                        }, completion: nil)

                        break
                    }
                    superView = superView?.superview
                }
            }
        }
        
    }
    func keyboardWillHide(notification : NSNotification) {
        if !self.isFirstResponder() {
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

protocol AVBFormAccessoryCellDelegate : class {
    func accessoryView(AVBFormAccessoryCell) -> UIView?
}

class AVBFormAccessoryCell : AVBFormKeyboardAvoidingCell {
    
    weak var accessoryDelegate : AVBFormAccessoryCellDelegate?
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        super.registerKeyboardListeners()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryDelegate = nil
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func canResignFirstResponder() -> Bool {
        return true
    }
    override var inputView : UIView? {
        get {
            return self.accessoryDelegate?.accessoryView(self)
        }
    }
}
protocol AVBInlineTextCellProtocol {
    func setValues(label : String? , placeholder : String?, value : String?)
    func getText()->String
}

class AVBInlineTextCell : AVBFormKeyboardAvoidingCell,AVBInlineTextCellProtocol {
    let label = UILabel()
    let textView : UITextField = {
        var textField = UITextField()
        textField.textColor = UIColor.blueColor()
        return textField
    }()
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func prepareForReuse() {
        textView.text = nil
        textView.placeholder = nil
    }
    
    override func layoutSubviews() {
        var r1 = CGRectZero,r2 = CGRectZero
        var size = label.sizeThatFits(self.contentView.bounds.size)
        CGRectDivide(CGRectInset(self.contentView.bounds, 20, 0), &r1, &r2, size.width, CGRectEdge.MinXEdge)
        label.frame = r1
        textView.frame = CGRectInset(r2, 10, 0)
    }
    func commonInit() {
        
        self.contentView.addSubview(label)
        self.contentView.addSubview(textView)
        self.registerKeyboardListeners()
    }
    
    
    func setValues(label : String? , placeholder : String?, value : String?) {
        self.label.text = label
        if value != nil {
            self.textView.text = value
        } else {
            self.textView.text = nil
            self.textView.placeholder = placeholder
        }
        layoutSubviews()
    }
    
    func getText()->String {
        return self.textView.text
    }
    override func isFirstResponder() -> Bool {
        return self.textView.isFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        return self.textView.resignFirstResponder()
    }
}
