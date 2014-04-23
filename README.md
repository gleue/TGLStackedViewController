TGLStackedViewController
========================

A stack layout with gesture-based reordering using UICollectionView -- inspired by Passbook and Reminders apps.

Getting Started
===============

Take a look at sample project `TGLStackedViewExample.xcodeproj`.

Usage
=====

* Add files in folder `TGLStackedViewController` to your project
* Create a derived class from `TGLStackedViewController` and overwrite method `-moveItemAtIndexPath:toIndexPath:`
* Implement `UICollectionDataSource` (currently only 1 section supported) and `UICollectionViewDelegate` protocols
* Place `UICollectionViewController` in your storyboard and set its class to your derived class

Requirements
============

* ARC
* iOS 7
* Xcode 5

Credits
=======

- Reordering based on [LXReorderableCollectionViewFlowLayout](https://github.com/lxcid/LXReorderableCollectionViewFlowLayout)

License
=======

TGLStackedViewController is available under the MIT License (MIT)

Copyright (c) 2014 Tim Gleue (http://gleue-interactive.com)

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
