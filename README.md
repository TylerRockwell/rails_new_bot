### Rails New Bot

A small script for starting a new Rails App.

### Installation

1. Fork the repo, or copy the script or whatever you want to do to get the code on your computer
2. `gem install thor`
3. Copy `rails_new_bot.thor` into your new rails app
4. `thor list` to get a list of available commands
5. `thor rails_bot:command` to run that command.

### Make Script Available on the System

If you don't want to copy the script to every new app you make, just install it

1. Navigate to the folder containing the script
2. `thor install rails_new_bot.thor`
3. The source will be displayed and thor will ask if you want to continue
4. Enter `rails_bot` at the next prompt
5. You can now use `thor rails_bot:command` in any folder

### What's New?

* Now fights harder against Spring and no longer hangs during generator installs
* Addressed a bug that caused a duplicate table error when migrating for the first time
