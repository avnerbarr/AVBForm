//
//  String-Helpers.swift
//  AVBForm
//
//  Created by Avner on 5/10/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation

extension String {
    static func isEmptyOrNil(str : String?) -> Bool {
        if str == nil {
            return true
        }
        return (str! as NSString).length != 0
    }
}