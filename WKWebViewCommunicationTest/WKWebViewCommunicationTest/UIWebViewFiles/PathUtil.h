//
//  PathUtil.h
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kContentStoreName                   @"contentstore"
#define kContentZipStoreName                @"contentzipstore"
#define kContentFileName                    @"content"

#define OfflineMode         0

@interface PathUtil : NSObject

+(NSString*)appDocumentDirectoryPath;
+(NSString *)scormAdaptorPath:(int)mode;
+(NSString *)iosLoaderPath;
+(NSString *)loadingHTMLPath:(int)mode;

@end
