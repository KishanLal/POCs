//
//  UIWebViewPlayer.h
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIWebViewPlayer: UIViewController  <UIWebViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    int webviewRequestType;
}


@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIView *tocView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tocViewLeading;
@property (nonatomic, strong) IBOutlet UITableView *tocTableView;
@property (nonatomic, strong) NSMutableArray *tocItems;

-(IBAction)exitButtonPressed:(id)sender;
-(IBAction)tocButtonPressed:(id)sender;

@end
