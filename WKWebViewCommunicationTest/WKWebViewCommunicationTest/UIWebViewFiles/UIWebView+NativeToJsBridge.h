//
//  UIWebView+NativeToJsBridge.h
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (NativeToJsBridge)

-(void)loadHTMLWithScormAdaptor:(NSString*)htmlFilePath;
-(void)nativeToJS:(NSString*)callbackFunction response:(NSString*)response;

@end
