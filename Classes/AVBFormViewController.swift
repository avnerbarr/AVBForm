//
//  AVBFormViewController.swift
//  AVBForm
//
//  Created by Avner on 5/6/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import UIKit


class AVBFormViewController: UIViewController {
    let tableView = AVBFormTableView()
    var dataSource : AVBFormDataSource?
    override func loadView() {
        self.view = tableView
        tableView.registerClass(AVBFormTableViewCell.self, forCellReuseIdentifier: AVBFormTableView.CellIdentifiers.cell1.identifier)
        tableView.registerClass(AVBFormTableViewCell.self, forCellReuseIdentifier: AVBFormTableView.CellIdentifiers.cell2.identifier)
        tableView.registerClass(AVBInlineTextCell.self, forCellReuseIdentifier: AVBFormTableView.CellIdentifiers.text.identifier)

    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.frame = self.view.bounds
        
        func schemes () -> [AVBComponent] {
            var arrayScheme = AVBMultiSelectComponent(
                items: [
                    AVBArrayItem(
                        id : "kuku:",
                        title : "first"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "Second"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "Third"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "Fourth",
                        selected : true
                    )
                ]
            )
            arrayScheme.title = "Selection Group 1"
            
            var arrayScheme2 = AVBRadioComponent(
                items: [
                    AVBArrayItem(
                        id : "kuku:",
                        title : "first"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "Second"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "Third"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "Fourth"
                    ),
                ]
            )
            arrayScheme2.title = "Selection Group 2"
            return [arrayScheme,arrayScheme2]
        }
        
        
        var firstGroup = AVBComponentGroup(title : "Group 1", schemes : schemes())
        var secondGroup = AVBComponentGroup(title : "Group 1", schemes : schemes())
        
        var scheme = AVBInlineTextComponent()
        scheme.title = "Insert text"
        var thirdGroup = AVBComponentGroup(title: nil, schemes: [scheme])
        var form = AVBForm(schemes : [firstGroup,secondGroup,thirdGroup])
        dataSource = AVBFormDataSource(tableView: tableView, form: form)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
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
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
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
    func needsGroupReload(form : AVBForm , group : AVBComponentGroup) {
        var index = (form.schemes as NSArray).indexOfObject(group)
        self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.None)
    }

}
class AVBFormTableView : UITableView {
    var form : AVBForm?  {
        didSet {
            self.reloadData()
        }
    }
    
    enum CellIdentifiers {
        case cell1
        case cell2
        case text
        var identifier : String {
            get {
                switch self {
                case cell1:
                    return "cell1"
                case cell2:
                    return "cell2"
                case text:
                    return "text"
                }

            }
        }

    }
    
    
}