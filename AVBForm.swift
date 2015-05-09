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
    subscript(index : Int) -> AVBComponentGroup? {
        if schemes.count > index {
            return schemes[index]
        }
        return nil
    }
    init(schemes : [AVBComponentGroup]) {
        self.schemes = schemes
        for group in schemes {
            group.form = self
        }
    }
}


extension UIView {
    var keyWindowFrame : CGRect? {
        get {
            return UIApplication.sharedApplication().keyWindow?.convertRect(self.frame, fromView: self.superview)
        }
    }
}




