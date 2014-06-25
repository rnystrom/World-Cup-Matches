World Cup 2014 for iOS
=================

This is a stupid-simple app for iOS that reads World Cup data from [World Cup ... in JSON](http://worldcup.sfg.io/) which is made by the gang at [software for good](http://softwareforgood.com/). It was a hacked-together app that was built in a couple days because I was bored and I didn't have a wicked fast World Cup app.

There is some hacky code in here. I'm not open sourcing this because it's a perfect project. I'm open sourcing this because it's a real app made by a real person for a real problem. Sometimes it's just about building.

<p align="center"><img title="Fancy pantsy" src="https://raw.github.com/rnystrom/World-Cup-Matches/master/images/wc-preview.gif"/></p>

# Attribution

Special thanks to these wonderful projects for making my life easier (and why I used them)

### [Facebook Pop](https://github.com/facebook/pop)

Amazing, lifelike animations. As with all animations, you should be judicious with how you use animations. Really put some thought into *why* you're animating something. Once you know you need an animation, then you use Pop.

If you like my animations or want to learn more, come see my presentation at [360 iDev](http://360idev.com/speakers/ryan-nystrom/) this year.

### [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)

Very unlike me, I only used this in one place. Traditionally I use RAC [all over the place](http://www.raywenderlich.com/55384/ios-7-best-practices-part-1) so I imported it by habit.

### [KZPropertyMapper](https://github.com/krzysztofzablocki/KZPropertyMapper)

[Krzysztof Zabłocki](http://twitter.com/merowing_) made JSON -> NSObject mapping a breeze. I probably could have used Mantle's solutions, but I added Mantle later on for persistence, after I had already implemented my mapping. In my opinion this is kind of a code smell and should be refactored. But hey, it works.

### [Mantle](https://github.com/Mantle/Mantle)

```NSCoding``` out of the box with no effort from me. I then slap my object map into ```NSUserDefaults``` on app termination.

As an aside, storing data in ```NSUserDefaults``` is a terrible idea on paper, but, I think that you should always think about implementation speed vs. use-case. If your data isn't sensitive or large, storing it in the file system as an object graph dump is fine. You don't need Core Data to solve every data problem, it *can* be overkill.

[Drew McCormack](https://twitter.com/drewmccormack) has done some research on JSON vs SQLite performance and raw data sizes. Long story short is that JSON doesn't suck.

### [CocoaPods](http://cocoapods.org/)

I love you guys so much.