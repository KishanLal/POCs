# WKWebViewCommunicationTest - POC to investigate WKWebView Communication issues

## Problem statement

Our app uses UIWebView for rendering e-learnings which we are migrating to WKWebView. It has communication between javascript and swift. Javascript sends data to iOS app using webkit's postMessage or iFrames. Swift process that data and communicates to javascript using evaluateJavaScript function of WKWebView. 

## Our Approach

We use frameset where there are 2 frames. Content runs in 1 frame(sco frame) and 1 adaptor(adaptor frame) runs in different frame. So html looks like this:

<html><head></head><frameset framespacing="0" rows="*,0" frameborder="0" noresize><frame name ="sco" src="/Users/kishanlal/Library/Developer/CoreSimulator/Devices/4FB3D277-7448-461E-A5D2-F4FCCB722E8E/data/Containers/Data/Application/B50088E9-8BB4-4748-92D2-DA17912EA94D/Documents/communication/loading.html"><frame name="adaptor" src="/Users/kishanlal/Library/Developer/CoreSimulator/Devices/4FB3D277-7448-461E-A5D2-F4FCCB722E8E/data/Containers/Data/Application/B50088E9-8BB4-4748-92D2-DA17912EA94D/Documents/communication/adaptor.html?sco_url=/Users/kishanlal/Library/Developer/CoreSimulator/Devices/4FB3D277-7448-461E-A5D2-F4FCCB722E8E/data/Containers/Data/Application/B50088E9-8BB4-4748-92D2-DA17912EA94D/Documents/contentstore/Test1/index.html"></frameset></html>

So Initially loading.html file loads in first frame and adaptor runs in second frame. Once adaptor loads it loads index.html in sco frame which is passed a query param in above string. (This code is written in adaptor.html file)

Now comes the communication part, Content send command to adaptor which interacts with iOS code. So communicate() in communication_layer.js files sends data to iOS code, iOS code process this and send back to javascript using evaluateJavaScript to establish communication. 

In UIWebView, It used to send data back to javascript using stringByEvaluatingJavaScriptFromString method which is synchronous. So data is passed and communication establishes properly. 

In WKWebView evaluateJavaScript is async, so blank data is returned to javascript. This is the problem, we are facing now. 

## POC Overview:

We tried to create demo for both UIWebView and WKWebView behaviour. So created a POC which has 2 entry point. One for UIWebView and other for WKWebView.

So for POC purpose, I am sending "Current Player is: " string to iOS via communicate() function. iOS recieves it and append actual player name in this and send back to javascript using stringByEvaluatingJavaScriptFromString for UIWebView and evaluateJavaScript for WKWebView. Javascript shows alert() with result string.

Expected Output for UIWebView: "Response from swift \n Current Player is: UIWebView Player" (Working fine)

Expected Output for WKWebView: "Response from swift \n Current Player is: WKWebView Player" (Not Working)

It is showing "Response from swift \n Current Player is: Blank". Blank is default value for variable which is set when data is sent back to javascript via evaluateJavaScript.

## Solution tried:

1. POC : Sending data using iFrame and Handling in decidePolicyForNavigationAction delegate. (Not Working)
2. Tried webkit's postmessage using WKScriptMessageHandler and evaluateJavaScript.  (Not Working)
3. Tried JSContext, but WKWebView's context is not shared so this is also not working.  (Not Working)

None of the above solution working. We are blocked due to this. 

## Expected Result:

There should be a way by which I can send data to javascript and calling function should wait untill callback function in javascript is called like it works in UIWebView with stringByEvaluatingJavaScriptFromString method. 

or 

There should be a way by which I can call swift function directly from javascript synchronously.
