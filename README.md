sample-ios
==========

Report Tracking from an iOS Client.

Installation notes
----------
To install the Sample SDK in your iOS project, you have two options. 
First option) Drag and drop the whole sample-ios subdirectory into your project.
Alternative ) Drag and drop the libsample-ios.a and the Sample.h into your project.  

For both options, the Sample.h file will be your access point. 

Usage
-----
You can use the sdk on two ways. For pre-defined events use the class methods like 
```
signIn
```
or 
```
registration
```

Also, you can track custom events by calling the track methods. If you take this approach, you should note that only known parameters will be passed to the server.

```
[Sample track:"ios_test_event" category:"test_category" userParams:@{ parameter1: "param" }];
```
