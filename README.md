# Redmine Plugin: AutoDeputy

## What it does
Assigns Issues automatically to defined deputies for the assigned user if the user is not available.

This Plugin provides a new Panel (Availability/Deputies) in the Main menu of your Redmine.
In this Panel, two things can be done:

### Set unavailability for User

The User can set an unavailable_from/unavailable_to date. An Issue cant be assigned to an user if its due date is in the unavailable range given for the user

### Set deputies for user

An user can have a set of other users that will act as deputies if the user not available. These can be created for an specific project or for this user in general

## Info

This Plugin was created by Florian Eck for akquinet GmbH.
It is licensed under GNU GENERAL PUBLIC LICENSE.

It has been tested with EasyRedmine, but should also work for regular Redmine installations. If you find any bugs, please file an issue or create a PR.
