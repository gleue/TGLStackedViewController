TGLStackedViewController
========================

A stack layout with gesture-based reordering using UICollectionView -- inspired by Passbook and Reminders apps.

<p align="center">
<img src="https://raw.github.com/gleue/TGLStackedViewController/master/Screenshots/TGLStackedViewExample.gif" alt="TGLStackedViewExample" title="TGLStackedViewExample">
</p>

Getting Started
===============

Take a look at sample project `TGLStackedViewExample.xcodeproj`.

Usage
=====

Via [CocoaPods](http://cocoapods.org):

* Add `pod 'TGLStackedViewController', '~> 1.0'` to your project's `Podfile`

Or the "classic" way:

* Add files in folder `TGLStackedViewController` to your project

Then in your project:

* Create a derived class from `TGLStackedViewController` and overwrite method `-moveItemAtIndexPath:toIndexPath:`
* Implement `UICollectionDataSource` (currently only 1 section supported) and `UICollectionViewDelegate` protocols
* Place `UICollectionViewController` in your storyboard and set its class to your derived class

Requirements
============

* ARC
* iOS >= 7.0
* Xcode 5

Credits
=======

- Reordering based on [LXReorderableCollectionViewFlowLayout](https://github.com/lxcid/LXReorderableCollectionViewFlowLayout)
- Podspec by [Pierre Dulac](https://github.com/dulaccc)

License
=======

TGLStackedViewController is available under the MIT License (MIT)

Copyright (c) 2015 Tim Gleue (http://gleue-interactive.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
