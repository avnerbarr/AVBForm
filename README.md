# AVBForm
Yet another Swift implementation to create forms without dealing directly with UITableView

The API is purposely primitive. Currently the main goal is to allow fast implementation of a simple simple form. 
I currently use this library to mock behavior.

Forms are created by defining sections and components.
Components can be thought to be equivalant to a table view cell with a certain behavior.

Form components are one of:
* ```AVBComponent```
  * Basic component with text and detail label  
* ```AVBInlineMultiSelectComponent```
  * Manages an array of selectable items
* ```AVBInlineRadioComponent```
  * Manages an array of selectable items in radio button style
* ```AVBInlineTextComponent```
  * Manages a text field component  
* ```AVBInlineDateComponent```
  * A date component 
* ```AVBAccordioneComponent```
  * Component which when clicked exposes an addional component
* ```AVBDateAccessoryComponent```
  * A component which manages an accessory view of a date picker
* ```AVBFullScreenComponent```
  * A component which exposes addional components in a new screen 


## Usage

3 steps: Create components. Add components to sections, and then add sections to a form.

For example:
```swift
var multiSelectList = AVBInlineMultiSelectComponent(
            items: [
                AVBArrayItem(
                    id : "usefullIdYouCanDecide1:",
                    title : "item1"
                ),
                AVBArrayItem(
                    id : "usefullIdYouCanDecide2:",
                    title : "item2"
                ),
                AVBArrayItem(
                    id : "usefullIdYouCanDecide3:",
                    title : "item3"
                ),
                AVBArrayItem(
                    id : "usefullIdYouCanDecide4:",
                    title : "item4",
                    selected : true
                )
            ]
        )
 multiSelectList.title = "Add a title to the group"
        
 var section1 = AVBFormSection(title : "Choose items:", schemes : [multiSelectList])
 
 var section2 = ... // more of the same
 
 var myForm = AVBForm(sections : [section1,section2],tableView : nil /* you can assign the form to a AVBFormViewController instead of assigning a table view and retaining a reference to the form*/)
 
 var formViewController = AVBFormViewController(form : myForm)
 
 presentViewController(formViewController)
 
 
 // Check if the form is valid?
 
 if myForm.isValid() == false {
   // do something
 } else {
 // do something else
 // for instance change the mode of the form to "Validate"
 myForm.mode = Mode.Validate // now the form will highlight the errors
 }
 
 
 // get a callback on state change of the form:
 // assign a closure to the component . The closure is called on state change
 typealias AVBStateClosure = (component : AVBComponent,state : AVBState) -> ()
 
 var radio = AVBInlineRadioComponent( // add the radio items
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
        // add a callback on state change and mutate the form
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
                    // lets replace a component in the form
                    // we need to tell the form which component to swap out - useful for branched conditions on the form without recreating a new form and explicately telling the form its state
                    parent.replace(component, newComponent: newRadio)
                }
            }
            
        }

 ```
