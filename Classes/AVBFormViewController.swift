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
    var form : AVBForm?
    override func loadView() {
        self.view = tableView
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.frame = self.view.bounds
        
        func radio () -> AVBInlineRadioComponent {
            var radio = AVBInlineRadioComponent(
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
            radio.title = "Radio Group"
            radio.stateChanged = {(component : AVBComponent,state : AVBState) in
                if let component = component as? AVBInlineRadioComponent {
                    for item in component.arrayItems {
                        println(item.title! + " " + item.id! + " " + item.selected.description )
                    }
                    
                    if let parent = component.parent {
                        var newRadio = AVBInlineRadioComponent(
                            items: [
                                AVBArrayItem(
                                    id : "kuku:",
                                    title : "1"
                                ),
                                AVBArrayItem(
                                    id : "kuku:",
                                    title : "2"
                                )
                            ]
                        )
                        newRadio.title = "New Radio"
                        parent.replace(component, newComponent: newRadio)
                    }
                }
                println("Changed")
            }
            return radio
        }
        func multiSelect() -> AVBInlineMultiSelectComponent {
            var arrayScheme = AVBInlineMultiSelectComponent(
                items: [
                    AVBArrayItem(
                        id : "kuku:",
                        title : "A"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "B"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "C"
                    ),
                    AVBArrayItem(
                        id : "kuku:",
                        title : "D",
                        selected : true
                    )
                ]
            )
            arrayScheme.title = "Multi Select Group"
            return arrayScheme
        }
        func accessory () -> AVBDateAccessoryComponent {
            var accessory = AVBDateAccessoryComponent()
            accessory.title = "Accessory"
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
        self.form = AVBForm(groups : [firstGroup,secondGroup,thirdGroup,forthGroup],tableView : tableView)
    }
    
}

class AVBFormTableView : UITableView {
    init() {
        super.init(frame: CGRectZero, style: UITableViewStyle.Grouped)
        var tableView = self
        keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
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