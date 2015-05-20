# AVBForm
Yet another Swift implementation to create forms without dealing directly with UITableView

The API is purposely primitive. Currently the main goal is to allow fast implementation of a simple simple form. 
I currently use this library to mock behavior.

Forms are created by defining sections and components.
Components can be thought to be equivalant to a table view cell with a certain behavior.

Form components are one of:
* AVBComponent
  * Basic component with text and detail label  
* AVBInlineMultiSelectComponent
  * Manages an array of selectable items
* AVBInlineRadioComponent
  * Manages an array of selectable items in radio button style
* AVBInlineTextComponent
  * Manages a text field component  
* AVBInlineDateComponent
  * A date component 
* AVBAccordioneComponent
  * Component which when clicked exposes an addional component
* AVBDateAccessoryComponent
  * A component which manages an accessory view of a date picker
* AVBFullScreenComponent
  * A component which exposes addional components in a new screen 
