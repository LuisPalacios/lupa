## Introduction

Project 'lupa' (spanish word for magnifying glass), created during the summer of 2015 as an exersise to practice Swift during Xcode 7 and El Capitan betas. I choose something I was playing in the past but wanted to do again with Swift: create an status bar application.

The objective of the App itself is extremely simple. It just offers a way of launching your default browser with a URL formed by concatenating a preset "Prefix" plus the contents of a "Search Field". The "Prefix" is stored under the OSX User Defaults. The "Search Field" is typed by the user. 

You can find probably dozen of use cases, some examples could be: Search in Google, search people in an enterprise Web Directory, etc. My personal use case is searching in my company's directory, reducing significantly the number of keystrokes and mouse movements :-)


> Needs at least Yosemite, it's using *new* `NSStatusBarButton` API introduce in OSX 10.10.


### Configuration 

Configure the program by right clicking into the status bar icon and selecting preferences under the menu

<div align="center">
![Screenshot of the menu](resources/scr_menu.png?raw=true "This is menu")

<div align="left">
You only need to do this once to set the URL prefix, as this will be stored in your user's defaults.

- Find, opens the search box.
- Preferences, enters into the preferences window.
- Help, so the help screen (not yet implemented)
- Quit, quit the application

<div align="center">

![Screenshot of the preferences](resources/scr_preferences.png?raw=true "This is the preferences window")
<div align="left">

You only need to do this once to set the URL prefix, as this will be stored in your user's defaults.

- Set your customer Hostkey
- If you need so, configure a character to be used as separator, some web sites need the search words separated by i.e. a plus sign.
- Test mode is only usefull for developer mode
- Set the URL search prefix 
   - Example 1: https://www.google.com/search?q=
   - Example 2: http://www.yourcompany.com/query.cgi?user=
- Status bar mode is a future feature


#### HotKey

- Set the System hotkey you want to kickoff the Search Box



### Search

Search: Click on the status bar icon or press your custom HotKey


<div align="center">
![Screenshot of the search box](resources/scr_search.png?raw=true "This is the search box")
<div align="left">


Type the text in the "Search Field" and press Enter (or Cancel to dismiss) which will trigger your OSX default browser towards the formed URL. 



#### Credits


This project uses the MASShortcut.framework (by [shpakovski/MASShortcut
](https://github.com/shpakovski/MASShortcut)) in order to support hotkeys.


#### Copyright

MASShortcut is licensed under the 2-clause BSD license.
