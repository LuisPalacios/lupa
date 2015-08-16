# Introduction

Project 'lupa' (spanish word for magnifying glass), authored by Luis Palacios, 2015


Really simple App that offers a very simple way of launching your default browser with a URL formed by concatenating a default "Prefix" and content of a "Search Field". The "Prefix" is a stored string under the Defaults user settings. The "Search Field" is typed by the user. 


## Use Case

You can dozen of use cases. Some examples could be: Search in Google, or quickly perform people web Directory searches in your enterprise, etc.


## Configuration 

Preferences: Right click on the status bar and select preferences under the menu

### URL Prefix

- Set the URL search prefix 
   - Example 1: https://www.google.es/?gws_rd=ssl#q=
   - Example 2: http://yourcompany/query.cgi?user=
- This Prefix is stored in your user's defaults.
- You only need to do this once. 


### HotKey

- Set the System hotkey you want to kickoff the Search Box



## Search

Search: Click on the status bar icon on press the HotKey

- Type the text in the "Search Field" and press Enter (or Cancel to dismiss)
- If you press Enter will trigger the default browser towards the formed URL. 



### Credit MASShortcut.framework


This project uses the MASShortcut.framework (by [shpakovski/MASShortcut
](https://github.com/shpakovski/MASShortcut)) in order to support hotkeys.
