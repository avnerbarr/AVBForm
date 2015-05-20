//
//  AVBFormTableView.swift
//  AVBForm
//
//  Created by Avner on 5/20/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

class AVBFormTableView : UITableView {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: UITableViewStyle.Grouped)
        commonInit()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    convenience init() {
        self.init(frame : CGRectZero, style : UITableViewStyle.Grouped)
    }

    private func commonInit() {
        var tableView = self
        keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        for enumVal in CellIdentifiers.values {
            tableView.registerClass(enumVal.cellClass, forCellReuseIdentifier: enumVal.identifier)
        }
    }

    enum CellIdentifiers {
        case Simple
        case Cell1
        case Cell2
        case Text
        case DateTime
        case RadioCell
        case RadioHeader
        case Accessory
        static var values : [CellIdentifiers] { get {return [CellIdentifiers.Simple,CellIdentifiers.Cell1,CellIdentifiers.Cell2,CellIdentifiers.Text,CellIdentifiers.DateTime,CellIdentifiers.RadioCell,CellIdentifiers.RadioHeader,CellIdentifiers.Accessory]}}
        var identifier : String {
            get {
                switch self {
                case Simple:
                    return "Simple"
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
                case Simple:
                    return AVBFormTableViewCell.self
                case .Cell1, .Cell2:
                    return AVBFormLeftDetailCell.self
                case .Text:
                    return AVBInlineTextCell.self
                case .DateTime:
                    return AVBFormDatePickerCell.self
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