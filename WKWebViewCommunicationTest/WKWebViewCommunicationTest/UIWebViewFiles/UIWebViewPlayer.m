//
//  UIWebViewPlayer.m
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

#import "UIWebViewPlayer.h"
#import "UIWebView+NativeToJsBridge.h"
#import "PathUtil.h"
#import "TOCCell.h"

#import "WKWebViewCommunicationTest-Swift.h"

#define CONTENTPLAYER_REQUEST_TYPE_LOAD             1
#define CONTENTPLAYER_REQUEST_TYPE_UNLOAD           2
#define CONTENTPLAYER_REQUEST_TYPE_CHANGE_SCO       3

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? true : false)

static NSString * const kJSOverrideWindowCloseForScorm = @"window.close = function () { parent.adaptor.currentlyUsedAPI.FrameworkTerminate('') }";

typedef enum : int {
    eSAViewTOCLeading_iPhone = -250,
    eSAViewTOCLeading_iPad = -310
} eSADims;

@interface UIWebViewPlayer() <UIGestureRecognizerDelegate, UITextFieldDelegate> {
    
}

@end

@implementation UIWebViewPlayer

- (void)viewDidLoad {
    
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:NO];
    self.webView.scrollView.bounces = NO;
        
    //Set third party cookies
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    
    [self.tocTableView registerNib:[UINib nibWithNibName:@"TOCCell" bundle:nil] forCellReuseIdentifier:@"TOCCell"];
    [self.tocTableView setBackgroundColor:[UIColor clearColor]];
    self.tocView.backgroundColor = [UIColor darkGrayColor];
            
    NSString *launchURL = [[PathUtil appDocumentDirectoryPath] stringByAppendingPathComponent:@"contentstore/Test1/index.html"];
    
    webviewRequestType = CONTENTPLAYER_REQUEST_TYPE_LOAD;
    [self.webView loadHTMLWithScormAdaptor:launchURL];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationItem setTitle:@"Test UIWebView"];

    UIBarButtonItem *toc = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"TOC", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showHideTOC)];
    self.navigationItem.leftBarButtonItem = toc;

    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Exit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
    self.navigationItem.rightBarButtonItem = done;
}

-(BOOL)shouldAutorotate {
    NSLog(@"In shouldAutorotate ");
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    NSLog(@"In supportedInterfaceOrientations ");
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)orientationChanged:(NSNotification *)notification {
    NSLog(@"Received orientationChanged notification");
    NSLog(@"currentDevice.orientation: %ld",[UIDevice currentDevice].orientation);
}

#pragma mark UIWebViewDelegate Methods

-(BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL *url = [request URL];
    NSString *urlString = [self decodeURL:[url absoluteString]];
        
    NSLog(@"urlString::%@",urlString);
        
    if ([urlString hasPrefix:@"tonative:::"]){
        NSArray *components = [urlString componentsSeparatedByString:@":::callback:::"];
        NSString *data = [components objectAtIndex:1];
        
        [self processJSRequest:data callback:@"callback"];
        
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webview {
    //Inject JS to override window close for content exit
    [self.webView stringByEvaluatingJavaScriptFromString:kJSOverrideWindowCloseForScorm];
    
    if (webviewRequestType == CONTENTPLAYER_REQUEST_TYPE_UNLOAD)
    {
        [self.webView stringByEvaluatingJavaScriptFromString:@"parent.adaptor.currentlyUsedAPI.FrameworkTerminate('')"];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error::%@",[error localizedDescription]);
    
    //Enable only for debugging
    if (error) {
        
        if ([error respondsToSelector: @selector(code)]) {
            
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                
                if (error.code == NSURLErrorCancelled) {
                    return;
                } else {
                    [self alert:error.localizedDescription title:NSLocalizedString(@"ERROR", nil)];
                }
            }
        }
    }
}

#pragma mark Private Methods

-(void)processJSRequest:(NSString*)data callback:(NSString*)callbackFunction{
    NSLog(@"ProcessJSRequest data:: %@\ncallbackFunction:: %@", data, callbackFunction);
    
    NSString *responseToJS = [data stringByAppendingString:@"UIWebView Player"];
    
    NSLog(@"responseToJS::%@",responseToJS);
    [self.webView nativeToJS:callbackFunction response:[NSString stringWithFormat:@"\"%@\"",responseToJS]];
}

#pragma mark Private Utility Methods

- (NSString *)decodeURL:(NSString *)url{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(CFStringRef)url, CFSTR(""), kCFStringEncodingUTF8));
    return result;
}

- (NSString *)encodeURL:(NSString *)url{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)url,NULL,(CFStringRef)@"!*'();@+$,%#[]",kCFStringEncodingUTF8));
    return result;
}

- (void) exitPlayer {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)handleTOCLabelTap:(UITapGestureRecognizer*)gestureRecognizer{
    [self showHideTOC];
}

-(void)showHideTOC{
    int leadingConstant = IS_IPAD ? eSAViewTOCLeading_iPad : eSAViewTOCLeading_iPhone;
    
    [UIView animateWithDuration:0.01 animations:^{
        if (self.tocViewLeading.constant == leadingConstant) {
            self.tocViewLeading.constant = 0;
        } else {
            self.tocViewLeading.constant = leadingConstant;
        }
    }];
}


#pragma mark - IBAction Methods

-(IBAction)exitButtonPressed:(id)sender {
    NSLog(@"ExitButtonPressed");
    
    webviewRequestType = CONTENTPLAYER_REQUEST_TYPE_UNLOAD;
    [self.webView stringByEvaluatingJavaScriptFromString:@"parent.frames[0].location = 'about:blank';"];
    
    [self exitPlayer];
}

-(IBAction)tocButtonPressed:(id)sender{
    [self showHideTOC];
}

#pragma mark - Private Helper Method

- (void)alert:(NSString *)msg title:(NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:true completion:nil];
    return;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
    static NSString *CellIdentifier = @"TOCCell";
    
    TOCCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.itemTitle.text = @"Reload Test1";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /* this means user is trying to naivgate the toc */
//    webviewRequestType = CONTENTPLAYER_REQUEST_TYPE_CHANGE_SCO;
//    [self.webView stringByEvaluatingJavaScriptFromString:@"parent.frames[0].location = 'about:blank';"];
    
    //Temporarily reload, actually it should work with loading 'about:blank' but that handling is not there
    [self.webView reload];
    [self showHideTOC];
}

@end
