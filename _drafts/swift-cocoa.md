---
title: "Swift/Cocoa Type Dissonance"
excerpt: |
    For no discernable reason, I've done a little iOS programming lately. Using the new Swift language has made it evident the language is young---and it sometimes conflicts with its much older framework counterpart, Cocoa. Here are two places where the disconnect is most stark, and where Swift should grow more sophisticated type-system features.
---
Cocoa was designed for Objective-C. Swift's major, fundamental differences inevitably create clashes with the framework that were not present when everyone used Objective-C. Apple has done a remarkable job creating as few of these as possible, even baking in [special-purpose language features][interop] to ease interoperation, but it was inevitable that some things will remain uncomfortable.

Here are two situations where Swift, Cocoa, or both should evolve to resolve their dissonance.

[interop]: https://developer.apple.com/library/ios/documentation/swift/conceptual/buildingcocoaapps/MixandMatch.html

## Stringly Typed Segues

Swift's type system is much stronger (and, subjectively, much better) than Objective-C's. As a result, Cocoa idioms that felt natural in Objective-C, where casts and checks are commonplace, are uncomfortable in Swift.

Case in point: [storyboard][] transitions, called *segues*, move the application between views. Segues are associated with particular objects, which have specific types. But segues are [stringly typed][]. The code that consumes identifier strings typically knows the associated types, but the compiler is powerless to help: the programmer has to supply all the type information.

Most commonly, this comes up when contacting one [UIViewController][] from another when transitioning. The pattern invariably looks like this:

    override func prepareForSegue(segue: UIStoryboardSegue,
                                  sender: AnyObject?) {
      if (segue.identifier == "MySpecialSegue") {
        let myController =
          segue.destinationViewController as MyViewController
        myController.doStuff()
      }
    }

The transition code almost always needs to explicitly cast the destination controller as a specific controller subclass. So the code needs to map the magic string identifier to this type---which feels natural in Objective-C, where this kind of thing happens all the time, and deeply uncomfortable in Swift.

A future Cocoa+Swift framework should make segues first class and strongly typed. A mechanism like [type providers][] could help supply types from the storyboard file.

[type providers]: http://msdn.microsoft.com/en-us/library/hh156509.aspx
[UIViewController]: https://developer.apple.com/library/ios/documentation/uikit/reference/UIViewController_Class/index.html
[stringly typed]: http://c2.com/cgi/wiki?StringlyTyped
[storyboard]: https://developer.apple.com/library/ios/documentation/general/conceptual/Devpedia-CocoaApp/Storyboard.html

## Storyboards and Dependency Injection

To communicate between view controllers, the [standard advice][uivc injection] is to [inject dependencies][dependency injection] on transitioning from one controller to another. In the above example, this would involve setting some fields on the destination controller inside the `if`. For example:

    myController.parentController = self

Since the field is guaranteed to be set before the controller does anything else, you would want to declare the field as a non-optional type. Like so:

    var parentController : SomeViewController

But the framework again writes checks that the type system can't cash. Since the field is set on transition and not on controller initialization, the compiler cannot enforce what the programmer knows is true: this field will never be null when user code runs. The field needs to be an implicitly unwrapped optional:

    var parentController : SomeViewController!

...which is a fine workaround. But it papers over a fundamentally unsatisfying design. There is again an opportunity for Swift and Cocoa to evolve together. A notion of [typestate][] or [Rust][]'s simpler [liftemes][], for instance, could resolve this discomfort.

[Rust]: http://www.rust-lang.org/
[liftemes]: http://doc.rust-lang.org/guide-lifetimes.html
[typestate]: http://en.wikipedia.org/wiki/Typestate_analysis
[dependency injection]: https://en.wikipedia.org/wiki/Dependency_injection
[uivc injection]: https://developer.apple.com/library/ios/featuredarticles/ViewControllerPGforiPhoneOS/ManagingDataFlowBetweenViewControllers/ManagingDataFlowBetweenViewControllers.html#//apple_ref/doc/uid/TP40007457-CH8-SW4
