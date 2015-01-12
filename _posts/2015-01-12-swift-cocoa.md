---
title: "Swift/Cocoa Type Dissonance"
excerpt: |
    I did some iOS programming recently (for an unknown reason). Using the new Swift language has made it evident the language is young---and, like a rebellious teenager, it conflicts with its much older framework counterpart, Cocoa. Here are two places where the disconnect is most stark, and where Swift should grow more sophisticated type-system features.
---
[Cocoa][] was designed for [Objective-C][]. Compared with Objective-C (b. 1989, like Taylor Swift), [Swift][] is an infant. Clashes with the much older framework were inevitable. Apple has baked in [special-purpose language features][interop] to ease interoperation, but fundamental disconnects remain.

Here are two cases where Swift's type system fails to capture Cocoa's intent. Modern type system features from other languages could help save the day in each case.

[interop]: https://developer.apple.com/library/ios/documentation/swift/conceptual/buildingcocoaapps/MixandMatch.html
[Objective-C]: https://en.wikipedia.org/wiki/Objective-C
[Swift]: https://developer.apple.com/swift/
[Cocoa]: https://developer.apple.com/technologies/mac/cocoa.html


## Stringly Typed Segues

Swift's type system is much stronger (and, subjectively, much better) than Objective-C's. As a result, Cocoa idioms that felt natural in Objective-C, where casts and checks are commonplace, are uncomfortable in Swift.

Case in point: [storyboard][] transitions, called *segues*, move the application between views. Segues are associated with particular objects, which have specific types. But segues are [stringly typed][]. The code that consumes identifier strings typically knows the associated types, but the compiler is powerless to help: the programmer has to supply all the type information.

This comes up when contacting one [UIViewController][] from another when transitioning. The pattern invariably looks like this:

    override func prepareForSegue(segue: UIStoryboardSegue,
                                  sender: AnyObject?) {
      if (segue.identifier == "MySpecialSegue") {
        let myController =
          segue.destinationViewController as MyViewController
        myController.doStuff()
      }
    }

The transition code almost always needs to explicitly cast the destination controller (with `as MyViewController`). So the programmer needs to manually map the magic string identifier to this type. The redundancy feels natural in Objective-C, where this kind of thing happens all the time, and deeply uncomfortable in Swift.

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

But the framework again writes checks that the type system can't cash. Since the field is set on transition and not on controller initialization, the compiler cannot enforce what the programmer knows is true: this field *will never be null* when it matters. The field needs to be an implicitly unwrapped optional:

    var parentController : SomeViewController!

This workaround papers over a fundamental disconnect. There is again an opportunity for Swift and Cocoa to evolve together. A notion of [typestate][] or [Rust][]'s simpler [lifetimes][], for instance, could resolve this discomfort.

[Rust]: http://www.rust-lang.org/
[lifetimes]: http://doc.rust-lang.org/book/ownership.html#lifetimes
[typestate]: http://en.wikipedia.org/wiki/Typestate_analysis
[dependency injection]: https://en.wikipedia.org/wiki/Dependency_injection
[uivc injection]: https://developer.apple.com/library/ios/featuredarticles/ViewControllerPGforiPhoneOS/ManagingDataFlowBetweenViewControllers/ManagingDataFlowBetweenViewControllers.html#//apple_ref/doc/uid/TP40007457-CH8-SW4

## More Types? Really?

Both examples call out for Apple to make Swift's type system more powerful---but also more complicated. Languages with [stronger][haskell] [types][agda] run the risk of offending workaday programmers with their complexity. [Lattner][] and crew have a difficult job: to make good on their promise of safety while maintaining the ineffable mouthfeel of a "mainstream" language.

[Lattner]: http://nondot.org/sabre/
[agda]: http://wiki.portal.chalmers.se/agda/pmwiki.php
[haskell]: https://www.haskell.org/
