//
//  AVBTests.swift
//  AVBForm
//
//  Created by Avner on 5/20/15.
//  Copyright (c) 2015 Avner. All rights reserved.
//

import Foundation
import UIKit

func makeTestForm(tableView : AVBFormTableView) -> AVBForm {
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
                if let parent = component.parent {
                    var newRadio = AVBInlineRadioComponent(
                        items: [
                            AVBArrayItem(
                                id : "kuku:",
                                title : "1"
                            )
                        ]
                    )
                    newRadio.title = "New Radio"
                    newRadio.identifier = "Swapped radio group"
                    parent.replace(component, newComponent: newRadio)
                    println("Swapped out component")
                }
            }
            
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
        var accessory = AVBDateAccessoryComponent(options: DateOptions.new())
        accessory.title = "Accessory Date"
        accessory.labelStyle = UITableViewCellStyle.Value1
        accessory.mandatory = true
        return accessory
    }
    
    func datePicker() -> AVBAccordioneComponent {
        var date = AVBInlineDateComponent(options: DateOptions.new())
        date.labelStyle = UITableViewCellStyle.Subtitle
        var accordion = AVBAccordioneComponent(component: date)
        accordion.title = "Accordion inline choose date"
        accordion.labelStyle = UITableViewCellStyle.Subtitle
        return accordion
    }
    
    func fullScreen () -> AVBFullScreenComponent {
        var multiSelect = multiSelect()
        var fullScreen = AVBFullScreenComponent(component: multiSelect)
        fullScreen.title = "Full screen"
        multiSelect.stateChanged = {[weak fullScreen] (component : AVBComponent, state : AVBState) in
            if let component = component as? AVBInlineMultiSelectComponent {
                var total = component.arrayItems.reduce(0, combine: { (total, item) -> Int in
                    if (item.selected == true) {
                        return total+1
                    }
                    return total
                })
                
                fullScreen?.detailText = total.description
            }
        }
        return fullScreen
    }
    var firstGroup = AVBFormSection(title : "Section 1", schemes : [fullScreen(),multiSelect(),radio()])
    var secondGroup = AVBFormSection(title : "Section 2", schemes : [multiSelect(),radio()])
    
    var scheme = AVBInlineTextComponent(
        options: AVBInlineTextComponent.Options(
            keypad : UIKeyboardType.NumberPad,
            placeHolderText : "Enter value",
            initialValue : nil
        )
    )
    scheme.title = "Insert text"
    var thirdGroup = AVBFormSection(title: "Text Section", schemes: [scheme])
    
    var accordione = AVBAccordioneComponent(component: radio())
    accordione.title = "Accordione Radio Group"
    var forthGroup = AVBFormSection(title: "Section with an accordion", schemes: [accordione,accessory(),datePicker()])
    return AVBForm(groups : [firstGroup,secondGroup,thirdGroup,forthGroup],tableView : tableView)
}
