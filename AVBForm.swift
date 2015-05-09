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
    func needsGroupReload(form : AVBForm , group : AVBComponentGroup)
}


class AVBForm {
    let schemes : [AVBComponentGroup]
    weak var delegate : AVBFormProtocol?
    weak var tableView : AVBFormTableView?
    lazy var dataSource : AVBFormDataSource? = {
        if let tableView = self.tableView {
            return AVBFormDataSource(tableView: tableView, form: self)
        }
        return nil
    }()
    subscript(index : Int) -> AVBComponentGroup? {
        if schemes.count > index {
            return schemes[index]
        }
        return nil
    }
    init(groups : [AVBComponentGroup],tableView : AVBFormTableView) {
        self.schemes = groups
        self.tableView = tableView
        for group in schemes {
            group.form = self
        }
        self.tableView?.delegate = self.dataSource
        self.tableView?.dataSource = self.dataSource
    }
}

@objc class AVBFormDataSource : NSObject, UITableViewDataSource, UITableViewDelegate, AVBFormProtocol {
    private weak var tableView : AVBFormTableView!
    private(set) var form : AVBForm!
    init(tableView : AVBFormTableView, form : AVBForm) {
        super.init()
        self.tableView = tableView
        self.form = form
        self.form.delegate = self
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return form.schemes.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.form[indexPath.section]!.cellForRowAtIndex(indexPath, tableView: self.tableView)!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sec = self.form[section] {
            return sec.numberOfRows
        }
        return 0
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.form[section]?.title
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.form[indexPath.section]?.didSelectRowAtIndexPath(tableView as! AVBFormTableView, indexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.form[indexPath.section]?.heightForRowAtIndexPath(indexPath, tableView: tableView as! AVBFormTableView) ?? 44.0
    }
    func needsGroupReload(form : AVBForm , group : AVBComponentGroup) {
        var index = (form.schemes as NSArray).indexOfObject(group)
        self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
}

extension UIView {
    var keyWindowFrame : CGRect? {
        get {
            return UIApplication.sharedApplication().keyWindow?.convertRect(self.frame, fromView: self.superview)
        }
    }
}




