## Introduction

Project 'lupa' (spanish word for magnifying glass), created during the summer of 2015 as an exercise to practice Swift with Xcode 7 and El Capitan Betas. Something I was playing with in the past but wanted to do again using Swift: status bar application.

<div align="center">
![Lupa](lupa/lupa/Assets.xcassets/AppIcon.appiconset/Icon-128.png?raw=true "My lupa")

<div align="left">

The original objective of the App was extremely simple: Being able to **launch your default browser** with a URL formed by the concatenation of "Prefix" + "Search Field". The "Prefix" is a preset stored under the OSX User Defaults and the "Search Field" is what the user types in the text field.

Later on I gave it a feature you might find useful, the **silent LDAP search while typing** feature will help you use it as an LDAP client for Directory searching.


<div align="center">
![LDAP silent engine](lupa/lupa/Assets.xcassets/AppIcon.appiconset/scr_ldap.png?raw=true "This is the search engine")

<div align="left">


> Note: "lupa" needs OSX 10.11 or higher, it's using *new* `NSStatusBarButton` API introduce in Yosemite and some other features from El Capitan, so as of now it'll require that version or higher.



### Installation

You can clone the project and open/compile with Xcode (tested Xcode 7).

Alternatively, download a copy of the binary [Lupa-1.2.2.zip](https://github.com/LuisPalacios/lupa/raw/master/download/Lupa-1.2.2.zip), unzip it and place the executable into your PATH (or better /Applications). Double click to execute. I suggest to add it to the startup items, under Users and Groups in System Preferences so you have it always ready.



### Configuration

Configure the program by right clicking into the status bar icon and selecting preferences under the menu.

<div align="center">
![Screenshot of the menu](resources/scr_menu.png?raw=true "This is menu")

<div align="left">

- Find: opens the search box.
- Preferences: enters into the preferences window.
- Quit: exits the application


Under the **Preferences window** you can alter the App behaviour and everything is saved under user's defaults so next run you'll find everything as you left it.


<div align="center">

![Screenshot of the preferences](resources/scr_preferences.png?raw=true "This is the preferences window")

<div align="left">

- System shortcut: set your custom Hotkey, so you can invoke the program from any application.
- Search separator: configure a character to be used as separator, some web sites need the search words separated by a character (i.e. a plus sign).
- URL search prefix: this is the "Prefix", the left part of the URL used when calling your default browser, a pair of examples:
   - Example 1: https://www.google.com/search?q=
   - Example 2: http://www.yourcompany.com/query.cgi?user=
- LDAP Support: Activate it and fill all the fields as you may need in order to connect into your company or personal LDAP Directory.
   -  Pic Mini and Zoom: Program expect to find the small and large version of the user pictures on those url's. Notice that the name of the file must be the 'cn' ldap attribute followed by the graphic extension. For each user found while typing the program will substitute the **<CN>** syntax with the cn attribute and try to download from the url. Don't remove the **<CN>***



#### Import/Export JSON

You'll have the option to import/export to JSON file storing or loading the preferences for easy distribution or simply backup purposes. The format of the file is as follows:


<div align="center">

![JSON import/export option](resources/scr_json.png?raw=true "This is the JSON import/export format")

<div align="left">


### Search

One your Preferences are set, **click on the status bar icon** or **press your custom shortcut**. Once you see the search box, type the words you want to use and press Enter to trigger the OSX default browser, or simply wait few miliseconds for an LDAP search to kickoff. If you press **ESC**cape the search window will dismiss.


<div align="center">
![Screenshot of the search box](resources/scr_search.png?raw=true "This is the search box")
<div align="left">




#### Credits


This project uses the MASShortcut.framework (by [shpakovski/MASShortcut
](https://github.com/shpakovski/MASShortcut)) in order to support hotkeys.


#### Copyright

Licensed under [The MIT license](http://www.opensource.org/licenses/mit-license.php)
