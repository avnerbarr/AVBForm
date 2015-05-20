//
//  AVBFormItem.swift
//  AVBForm
//
//  Created by Avner on 5/5/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

/**
*  Defines functionality the form needs from the controller
*/
protocol AVBFormProtocol : class {
    func needsGroupReload(form : AVBForm , group : AVBFormSection)
}

protocol AVBValidatable {
    func isValid()->Bool
    func markInvalid()
}

protocol AVBFormDelegate : class {
    func presentChildForm(form : AVBForm)
}

class AVBForm : AVBValidatable {
    let groups : [AVBFormSection]
    weak var formDelegate : AVBFormDelegate?
    weak var tableView : AVBFormTableView? {
        didSet {
            tableView?.delegate = self.dataSource
            tableView?.dataSource = self.dataSource
            tableView?.reloadData()
        }
    }
    lazy var dataSource : AVBFormController? = {
        if let tableView = self.tableView {
            return AVBFormController(tableView: tableView, form: self)
        }
        return nil
    }()
    subscript(index : Int) -> AVBFormSection? {
        if groups.count > index {
            return groups[index]
        }
        return nil
    }
    init(groups : [AVBFormSection],tableView : AVBFormTableView?) {
        self.groups = groups
        self.tableView = tableView
        for group in groups {
            group.form = self
        }
        self.tableView?.delegate = self.dataSource
        self.tableView?.dataSource = self.dataSource
    }
    func isValid()->Bool {
        var valid = true
        for group in groups {
            valid = valid && group.isValid()
            if valid == false {
                return false
            }
        }
        return true
    }
    func presentChildForm(form : AVBForm) {
        self.formDelegate?.presentChildForm(form)
    }
    
    func markInvalid() {
        
    }
}


extension UIView {
    var keyWindowFrame : CGRect? {
        get {
            return UIApplication.sharedApplication().keyWindow?.convertRect(self.frame, fromView: self.superview)
        }
    }
}




