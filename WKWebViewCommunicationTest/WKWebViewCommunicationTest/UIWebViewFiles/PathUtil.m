//
//  PathUtil.m
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

#import "PathUtil.h"

@implementation PathUtil

#pragma mark General Path Methods

+(NSString*)appDocumentDirectoryPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)scormAdaptorPath:(int)mode{
    if (mode == OfflineMode){
        NSString* scormAdapterPath = [[PathUtil appDocumentDirectoryPath] stringByAppendingPathComponent:@"communication/adaptor.html"];
        return scormAdapterPath;
    }
    return @"";
}

+ (NSString *)iosLoaderPath{
    NSString *iosLoaderPath = [[PathUtil appDocumentDirectoryPath] stringByAppendingPathComponent:@"ios_loader.html"];
    return iosLoaderPath;
}

+ (NSString *)loadingHTMLPath:(int)mode{
    if (mode == OfflineMode){
        NSString* loadingHTMLPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"communication/loading.html"];
        return loadingHTMLPath;
    }
    return @"";
}

@end
