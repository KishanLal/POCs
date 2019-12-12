//
//  UIWebView+NativeToJsBridge.m
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

#import "UIWebView+NativeToJsBridge.h"
#import "PathUtil.h"

@implementation UIWebView (NativeToJsBridge)

-(void)loadHTMLWithScormAdaptor:(NSString*)htmlFilePath{    
    NSString* scormAdapterPath = [PathUtil scormAdaptorPath:OfflineMode];
    NSString* ios_loaderPath = [PathUtil iosLoaderPath];
    NSString* loadingHtmlPath = [PathUtil loadingHTMLPath:OfflineMode];
    NSError *error;
    NSString *htmlString = [[NSString alloc] initWithFormat:@"<html><head></head><frameset framespacing=\"0\" rows=\"*,0\" frameborder=\"0\" noresize><frame name =\"sco\" src=\"%@\"><frame name=\"adaptor\" src=\"%@?sco_url=%@\"></frameset></html>",loadingHtmlPath,scormAdapterPath,htmlFilePath];
    
    NSLog(@"htmlString::%@",htmlString);
    
    [htmlString writeToFile:ios_loaderPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSURL *url = [NSURL fileURLWithPath:ios_loaderPath];
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)nativeToJS:(NSString*)callbackFunction response:(NSString*)response{
    NSString *jsString = [NSString stringWithFormat:@"parent.adaptor.jsToNativeBridge.%@(%@);",callbackFunction,response];
    [self stringByEvaluatingJavaScriptFromString:jsString];
}

@end
