//
//  AVBFormItem.swift
//  AVBForm
//
//  Created by Avner on 5/5/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation

struct AVBForm {
    let screens : [AVBFormStep]
}

struct AVBFormStep {
    let text : String?
    let sections : [AVBFormStepSection]
}

struct AVBFormStepSection {
    let sectionHeader : String?
    let formItems : [AVBFormItem]
}

struct AVBFormItem {
    let identifier : String
    let text : String
    let placeholder : String
    let format : AVBAnswerFormat
    let style : AVBFormItemStyle
    enum AVBFormItemStyle {
        case TitleSubtitle
        case RightDetail
    }
}

protocol AVBAnswerFormat {
    
}

struct AVBNumericAnswerFormat : AVBAnswerFormat {
    let min : Double
    let max : Double
    let floatingPoint : Bool
    
    init?(min : Double, max : Double,floatingPoint : Bool ) {

        self.min = min
        self.max = max
        self.floatingPoint = floatingPoint
        
        if min > max {
            return nil
        }
    }
}

struct AVBTextAnswerFormat: AVBAnswerFormat {
    
}

struct AVBChoiceAnswerFormat : AVBAnswerFormat {
    let choices : Set<AVBChoiceItemValue>
    let preSelect : Set<AVBChoiceItemValue>
    let format : ChoiceFormat
    enum ChoiceFormat {
        case SingleSelect
        case MultiSelect
    }
}



struct AVBChoiceItemValue {
    let id : String
    let value : String
}


extension AVBChoiceItemValue : Hashable, Equatable {
    var hashValue : Int {
        get {
            return self.id.hash ^ self.value.hash
        }
    }
}

func ==(lhs: AVBChoiceItemValue, rhs: AVBChoiceItemValue) -> Bool {
    return lhs.value == rhs.value && lhs.id == rhs.id
}