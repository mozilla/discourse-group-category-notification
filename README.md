# group-category-notification
*A plugin to enable automatic subscription to categories based on group membership*

[![Build Status](https://travis-ci.org/mozilla/discourse-group-category-notification.svg?branch=master)](https://travis-ci.org/mozilla/discourse-group-category-notification)

## Usage

This plugin doesn't currently have a UI, interactions must be carried out using `rails c`.

A category can be added with `GroupCategoryNotification.add(group, category)`, and removed with `GroupCategoryNotification.remove(group, category)`.

Added categories will be automatically watched by all current and future members of that group. A user can still go and set their notification level on that category to something different, and the plugin won't override it.

If a category is removed all users in that group watching the category will have their notification level set to regular on their categories, regardless of their preference.

If a group is removed, all users in that group will have their notification level on previously added categories set to regular, regardless of their preference.

## Bug reports

Bug reports should be filed [by following the process described here](https://discourse.mozilla.org/t/where-do-i-file-bug-reports-about-discourse/32078).

## Running tests

Clone this plugin into `plugins/discourse-group-category-notification` in the root of your Discourse source dir.

Use `RAILS_ENV=test rake plugin:spec[discourse-group-category-notification]` to run the tests.
