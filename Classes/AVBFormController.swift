//
//  AVBFormController.swift
//  AVBForm
//
//  Created by Avner on 5/20/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

@objc class AVBFormController : NSObject, UITableViewDataSource, UITableViewDelegate, AVBFormProtocol {
    private weak var tableView : AVBFormTableView!
    private(set) var form : AVBForm!
    init(tableView : AVBFormTableView, form : AVBForm) {
        super.init()
        self.tableView = tableView
        self.form = form
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return form.groups.count
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
    func needsGroupReload(form : AVBForm , group : AVBFormSection) {
        var index = (form.groups as NSArray).indexOfObject(group)
        self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}
