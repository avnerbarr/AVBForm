//
//  AVBFormViewController.swift
//  AVBForm
//
//  Created by Avner on 5/6/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import UIKit


class AVBFormViewController: UIViewController, AVBFormDelegate {
    let tableView = AVBFormTableView()
    var dataSource : AVBFormController?
    var form : AVBForm?
    override func loadView() {
        self.view = tableView
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    convenience init(form : AVBForm) {
        self.init(nibName: nil, bundle: nil)
        form.tableView = self.tableView
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.form = makeTestForm(self.tableView)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.form?.formDelegate = self
    }
    
    func presentChildForm(form : AVBForm) {
        var vc = AVBFormViewController(form: form)
        self.navigationController?.showViewController(vc, sender: self)
    }
    
    @IBAction func validateForm(sender: UIBarButtonItem) {
        if self.form?.isValid() == true {
            println("Valid")
        } else {
            println("Invalid")
        }
        self.form?.mode = Mode.Validate
    }
    
    func validateForm() -> Bool? {
        return self.form?.isValid()
    }
}

