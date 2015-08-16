## Introduction

Project 'lupa' (spanish word for magnifying glass), created during the summer of 2015 as an exersise to practice Swift during Xcode 7 and El Capitan betas. I choose something I was playing in the past but wanted to do again with Swift: create a status bar application.

<div align="center">
![Lupa](resources/dir_128x128.png?raw=true "My lupa")

<div align="left">

The objective of the App itself is extremely simple. It just offers a way of launching your default browser with a URL formed by concatenating a preset "Prefix" plus the contents of a "Search Field". The "Prefix" is stored under the OSX User Defaults. The "Search Field" is typed by the user. 

You can find probably dozen of use cases, some examples could be: Search in Google, search people in an enterprise Web Directory, etc. My personal use case is searching in my company's directory, reducing significantly the number of keystrokes and mouse movements :-)


> Needs at least Yosemite, it's using *new* `NSStatusBarButton` API introduce in OSX 10.10.


### Configuration 

Configure the program by right clicking into the status bar icon and selecting preferences under the menu

<div align="center">
![Screenshot of the menu](resources/scr_menu.png?raw=true "This is menu")

<div align="left">
- Find, opens the search box.
- Preferences, enters into the preferences window.
- Quit, exits the application

You can access the Preferences to setup the App behaviour, only need to do this once as they are saved into your user's defaults.

<div align="center">

![Screenshot of the preferences](resources/scr_preferences.png?raw=true "This is the preferences window")
<div align="left">

- System shortcut: set your custom Hostkey
- Search separator: configure a character to be used as separator, some web sites need the search words separated by i.e. a plus sign.
- URL search prefix 
   - Example 1: https://www.google.com/search?q=
   - Example 2: http://www.yourcompany.com/query.cgi?user=


### Search

**Click on the status bar icon** or **press your custom shortcut**. Once you see the search box, type the words you want to use and press Enter to trigger the OSX default browser. If you press **ESCape** it will cancel and dismiss the search window. 

<div align="center">
![Screenshot of the search box](resources/scr_search.png?raw=true "This is the search box")
<div align="left">




#### Credits


This project uses the MASShortcut.framework (by [shpakovski/MASShortcut
](https://github.com/shpakovski/MASShortcut)) in order to support hotkeys.


#### Copyright

MASShortcut is licensed under the 2-clause BSD license.
