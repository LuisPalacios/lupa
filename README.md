## Introduction

Project 'lupa' (spanish word for magnifying glass), created during the summer of 2015 as an exercise to practice Swift during Xcode 7 and El Capitan betas. Something I was playing with in the past but wanted to do again using Swift: status bar application.

<div align="center">
![Lupa](resources/dir_128x128.png?raw=true "My lupa")

<div align="left">

The objective of the App itself is extremely simple. Launches your default browser with a URL formed by the concatenation of "Prefix" + "Search Field". The "Prefix" is a preset stored under the OSX User Defaults. The "Search Field" is typed by the user. 

You can find probably dozen of use cases, some examples could be: Search in Google, search people in an enterprise Directory, etc. My personal use case is searching in my company's Directory, reducing significantly the number of keystrokes and mouse movements :-)


> Note: "lupa" needs OSX 10.10 or higher, it's using *new* `NSStatusBarButton` API introduce in Yosemite.


### Installation

You can clone the project and open/compile with Xcode (tested Xcode 7).

You can download a copy of the binary [lupa-1.0.0.zip](https://github.com/LuisPalacios/lupa/blob/master/download/lupa-1.0.0.zip) or clone/download this repo and compile with XCode (version 7). 

If you download the ZIP file, unzip it and place the executable into your PATH (or better /Applications). Double click to execute. I suggest to add it to the startup items, under Users and Groups in System Preferences so you have it always ready.


### Configuration 

Configure the program by right clicking into the status bar icon and selecting preferences under the menu.

<div align="center">
![Screenshot of the menu](resources/scr_menu.png?raw=true "This is menu")

<div align="left">

- Find: opens the search box.
- Preferences: enters into the preferences window.
- Quit: exits the application

Under the **Preferences window** you can alter the App behaviour and it's saved under user's defaults.


<div align="center">

![Screenshot of the preferences](resources/scr_preferences.png?raw=true "This is the preferences window")

<div align="left">

- System shortcut: set your custom Hotkey, so you can invoke the program from any application.
- Search separator: configure a character to be used as separator, some web sites need the search words separated by a character (i.e. a plus sign).
- URL search prefix: this is the "Prefix", the left part of the URL used when calling your default broser, a pair of examples:
   - Example 1: https://www.google.com/search?q=
   - Example 2: http://www.yourcompany.com/query.cgi?user=


### Search

One your Preferences are set, **click on the status bar icon** or **press your custom shortcut**. Once you see the search box, type the words you want to use and press Enter to trigger the OSX default browser. If you press **ESC**cape it will cancel and dismiss the search window. 

<div align="center">
![Screenshot of the search box](resources/scr_search.png?raw=true "This is the search box")
<div align="left">




#### Credits


This project uses the MASShortcut.framework (by [shpakovski/MASShortcut
](https://github.com/shpakovski/MASShortcut)) in order to support hotkeys.


#### Copyright

lupa is licensed under the 2-clause BSD license.
