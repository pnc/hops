## Hops

Hops lets you preview compiled iOS applications in Quick Look.

![Screenshot showing Quick Look preview of an iPhone application called Coatcheck, version 1.0, listing the application identifier, the push message environment, debugging, a list of permitted devices, and keychain access groups](http://f.cl.ly/items/04242J2K17370j0w3A15/Screen%20Shot%202014-06-15%20at%2016.28.32.png)

At present, it will display previews for exported IPAs (`.ipa`) and Xcode build archives (`.xcarchive`).

You can use it to preflight IPAs, to make sure the correct provisoning profile was used during compilation, and to check that the desired device UDIDs are permitted. You can also use it to determine which of a list of seemingly identical archived builds contains the specific version you want.

Currently, it displays the application's name, version, unique identifier, the APNS environment (if any), whether debugging is permitted (AKA `get-task-allow`), what device UDIDs the application is permitted to run on, and the keychain access groups accessible by the application.

Displaying supported Universal architectures (ARMv7, ARMv7s, etc.) and supported hardware (via `UIRequiredDeviceCapabilities`) is planned.

## Installation

### Download

[Download the latest version](http://www.philcalvin.com/downloads/hops-0.2.qlgenerator.zip), unzip it if necessary, and install it by following these steps:

1. Open the Library by opening Finder, holding the Option key, and choosing **Go - Library** in the menu.
2. Double-click the **QuickLook** folder.
3. Drag **Hops Viewer.qlgenerator** here.

### Building from source

First, clone this repository.

#### Using Xcode (GUI)

2. Open **Hops.xcworkspace** (not Hops.xcodeproj) in Xcode 5.
3. Choose **Product - Build** from the menu.
4. Show the Project Navigator by pressing ⌘-1.
5. Expand the **Products** group by clicking the arrow.
6. Control-click (or right-click) **Hops Viewer.qlgenerator** and choose **Show in Finder**.
1. Open the Library by opening Finder, holding the Option key, and choosing **Go - Library** in the menu.
2. Double-click the **QuickLook** folder.
3. Drag **Hops Viewer.qlgenerator** here.

#### Using xcodebuild

From the root of this repository, run:

    xcodebuild -target "Hops Viewer"
    mv "build/Release/Hops Viewer.qlgenerator" ~/Library/QuickLook


## Development

Hops is broken into a dynamic library (called Hops) and a Quick Look generator that uses this library (called Hops Viewer.) There is no runnable build target -- just use the test suite, or install the built `.qlgenerator` for interactive testing.

You may need to run `qlmanage -r` to forcibly reload the Quick Look generators after installing a new version.

`NSLog` statements in Hops or Hops Viewer can be viewed using Console.app, available in `/Applications/Utilities`.

## Tests

You can run the test suite from Xcode using **Product - Test** in the menu or from the command line:

    hops $ xcodebuild -scheme Hops test

## Contributors

Bugfixes and enhancements will happily be accepted either as GitHub pull requests or [via email](mailto:phil@philcalvin.com) as `git format-patch`-style patches. Do whatever works best for you!

## License

The MIT License (MIT)

Copyright (c) 2014 Phillip Calvin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
