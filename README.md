## Introduction

Project 'lupa' (spanish word for magnifying glass), authored by Luis Palacios, 2015


Really simple App that offers a way of launching your default browser with a URL formed by concatenating a preset "Prefix" plus the contents of a "Search Field". The "Prefix" is stored under the OSX User Defaults. The "Search Field" is typed by the user. 


### Use Case

You can find probably dozen of use cases, some examples could be: Search in Google, search people in an enterprise Web Directory, etc.


### Configuration 

Configure the program by right clicking into the status bar icon and selecting preferences under the menu

<div align="center">
![Screenshot of the preferences](resources/scr_menu.png?raw=true "This is menu")

![Screenshot of the preferences](resources/scr_preferences.png?raw=true "This is the preferences window")
<div align="left">

#### URL Prefix

You only need to do this once to set the URL prefix, as this will be stored in your user's defaults.

- Set the URL search prefix 
   - Example 1: https://www.google.com/search?q=
   - Example 2: http://www.yourcompany.com/query.cgi?user=



#### HotKey

- Set the System hotkey you want to kickoff the Search Box



### Search

Search: Click on the status bar icon on press the HotKey

- Type the text in the "Search Field" and press Enter (or Cancel to dismiss)
- If you press Enter will trigger the default browser towards the formed URL. 



#### Credit MASShortcut.framework


This project uses the MASShortcut.framework (by [shpakovski/MASShortcut
](https://github.com/shpakovski/MASShortcut)) in order to support hotkeys.
