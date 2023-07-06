## [1.0.0-1] - 2021-03-06

* Initial release

## [1.0.0-4] - 2021-03-11

* Added horizontal scrolling support
* Added code modifiers
* Cleaner padding API

## [1.0.0-6] - 2021-03-12

* Added a temporary fix for https://github.com/flutter/flutter/issues/77929

## [1.0.0-7] - 2021-03-12

* Added a rawText getter to CodeController

## [1.0.0-9] - 2021-04-21

* Removed dependency on flutter_keyboard_visibility

## [1.0.1-0] - 2021-05-22

* TextEditingController.buildTextSpan breaking change migration for flutter 2.2.0

## [1.0.1-1] - 2021-06-04

* Added wrap paramerter to disable horizontal scrolling
  
## [1.0.1-2] - 2021-07-23

* Fixed highlight parsing on web (issue #11)

## [1.0.2] - 2021-07-23

* removeChar & removeSelection methods added
* added onChange callback
* added enabled flag
* fixed middle dot issue

## [1.0.3] - 2022-05-02

* added onTap to CodeField API
* fixed tab behavior in read-only mode
* added setCursor method to CodeController

## [1.0.4] - 2022-06-22

* added isDense to CodeField API as optional parameter
* added smartQuotesType to CodeField API as optional parameter
* added keyboardType to CodeField API as optional parameter
* solves 'enter' linebreak bug
* adds a macos desktop example app

## [1.1.0] - 2022-11-19

* removed webSpaceFix (https://github.com/flutter/flutter/issues/77929)
* fixed #43, #58, #59, #60, #62, #64
* updated dependencies

## [1.1.1] - 2023-07-06

* added hintText and hintStyle to CodeField API as optional parameters