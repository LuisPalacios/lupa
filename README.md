# Introduction

Project 'lupa' (spanish word for magnifying glass), authored by Luis Palacios, 2015


This is an small utility that offers a very simple way of launching your default browser with a very specific URL. This URL will be formed concatenating "Prefix" + "Search Field". The "Prefix" is a stored string under the Defaults user settings. The "Search Field" is typed by the user. 


## Use Case

While you could probably find multiple use cases, mine is simple: App to quickly perform web Directory searches in my enterprise. 


## Howto 


Preferences: Right click on the status bar and select preferences under the menu

- Set the enterprise URL search prefix when searching for people using my browser.
- It may be something similar to: http://www.sample.com/query.cgi?user=
- This Prefix is stored in your user's defaults.
- You only need to do this once. 

Search: Click on the status bar icon

- Type the text in the "Search Field"
- Type the name I want to search and press enter.
- It will trigger the default browser towards a URL formed with the "prefix + search field"


### Credit

This project uses the MASShortcut.framework (by [shpakovski/MASShortcut
](https://github.com/shpakovski/MASShortcut)) in order to support hotkeys.
