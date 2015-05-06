//
//  AVBFormViewController.swift
//  AVBForm
//
//  Created by Avner on 5/6/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import UIKit


class AVBFormViewController: UIViewController {

    let form : AVBForm
    let tableView = AVBFormTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
    init(form : AVBForm) {
        self.form = form
        super.init(nibName: nil, bundle: nil)
        
    }

    required init(coder aDecoder: NSCoder) {
        self.form = AVBForm(screens : [AVBFormStep]()) // empty form
        super.init(coder: aDecoder)
    }
    
    func setup() {
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.view.addSubview(tableView)
    }
    
    var controller : AVBFormStepController?
    override func viewWillAppear(animated: Bool) {
        controller = AVBFormStepController()
        controller!.tableView = self.tableView
        controller!.step = form.screens.first
        controller!.reload()
    }

}


class AVBFormStepController : NSObject, UITableViewDataSource {
    weak var tableView : AVBFormTableView?
    var step : AVBFormStep?
    func reload() {
        self.tableView?.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return step?.sections.count ?? 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var section = step?.sections[section]
        return section?.formItems.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return (tableView as! AVBFormTableView).dequeueReusableCellWithIdentifier(AVBFormTableView.CellStyle.kTextCell)
    }
}

class AVBFormTableView : UITableView {
    enum CellStyle : String{
        case kTextCell   = "kTextCell"
        case kNumberCell = "kNumberCell"
        case kSelectCell = "kSelectCell"
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellStyle.kTextCell.rawValue)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellStyle.kNumberCell.rawValue)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellStyle.kSelectCell.rawValue)
    }

    func dequeueReusableCellWithIdentifier(identifier: CellStyle) -> UITableViewCell {
        return self.dequeueReusableCellWithIdentifier(identifier.rawValue) as! UITableViewCell
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


