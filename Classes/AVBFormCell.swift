//
//  AVBFormCell.swift
//  AVBForm
//
//  Created by Avner on 5/9/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

class AVBFormTableViewCell : UITableViewCell {
    override func prepareForReuse() {
        accessoryType = .None
        textLabel?.text = nil
    }
}

class AVBFormRadioHeaderCell: AVBFormTableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
                        superView.setContentOffset(CGPointMake(0, superView.contentOffset.y + kbframe.height), animated: true)
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
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    func setValues(label : String , placeholder : String)
    func getText()->String
}

class AVBInlineTextCell : AVBFormKeyboardAvoidingCell,AVBInlineTextCellProtocol {
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
        self.registerKeyboardListeners()
    }
    
    
    func setValues(label : String , placeholder : String) {
        self.label.text = label
        self.textView.text = placeholder
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
