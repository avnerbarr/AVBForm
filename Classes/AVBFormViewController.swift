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
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.frame = self.view.bounds
        
        func radio () -> AVBRadioComponent {
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
            arrayScheme2.title = "Radio Group"
            return arrayScheme2
        }
        func multiSelect() -> AVBMultiSelectComponent {
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
            arrayScheme.title = "Multi Select Group"
            return arrayScheme
        }
        func accessory () -> AVBAccessoryViewComponent {
            var accessory = AVBAccessoryViewComponent(style: .Date)
            accessory.title = "Accessory"
            accessory.style = .Date
            return accessory
        }
        
        
        var firstGroup = AVBComponentGroup(title : "Group 1", schemes : [multiSelect(),radio()])
        var secondGroup = AVBComponentGroup(title : "Group 1", schemes : [multiSelect(),radio()])
        
        var scheme = AVBInlineTextComponent()
        scheme.title = "Insert text"
        var thirdGroup = AVBComponentGroup(title: nil, schemes: [scheme])
        
        var accordione = AVBAccordioneComponent(component: radio())
        accordione.title = "Accordione"
        var forthGroup = AVBComponentGroup(title: "Accordione Group", schemes: [accordione,accessory()])
        var form = AVBForm(schemes : [firstGroup,secondGroup,thirdGroup,forthGroup])
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.form[indexPath.section]?.heightForRowAtIndexPath(indexPath, tableView: tableView as! AVBFormTableView) ?? 44.0
    }
    func needsGroupReload(form : AVBForm , group : AVBComponentGroup) {
        var index = (form.schemes as NSArray).indexOfObject(group)
        self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
    }

}
class AVBFormTableView : UITableView {
    init() {
        super.init(frame: CGRectZero, style: UITableViewStyle.Grouped)
        var tableView = self
        for enumVal in CellIdentifiers.values {
            tableView.registerClass(enumVal.cellClass, forCellReuseIdentifier: enumVal.identifier)
        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    var form : AVBForm?  {
        didSet {
            self.reloadData()
        }
    }
    
    enum CellIdentifiers {
        case Cell1
        case Cell2
        case Text
        case DateTime
        case RadioCell
        case RadioHeader
        case Accessory
        static var values : [CellIdentifiers] { get {return [CellIdentifiers.Cell1,CellIdentifiers.Cell2,CellIdentifiers.Text,CellIdentifiers.DateTime,CellIdentifiers.RadioCell,CellIdentifiers.RadioHeader,CellIdentifiers.Accessory]}}
        var identifier : String {
            get {
                switch self {
                case Cell1:
                    return "cell1"
                case Cell2:
                    return "cell2"
                case Text:
                    return "text"
                case .DateTime:
                    return "DateTime"
                case .RadioCell:
                    return "RadioCell"
                case .RadioHeader:
                    return "RadioHeader"
                case .Accessory:
                    return "Accessory"
                }

            }
        }
        var cellClass : AnyClass {
            get {
                switch self {
                case .Cell1, .Cell2:
                    return AVBFormTableViewCell.self
                case .Text:
                    return AVBInlineTextCell.self
                case .DateTime:
                    return AVBFormTableViewCell.self
                case .RadioCell:
                    return AVBFormTableViewCell.self
                case .RadioHeader:
                    return AVBFormRadioHeaderCell.self
                case .Accessory:
                    return AVBFormAccessoryCell.self
                }
            }
        }

    }
    
    
}