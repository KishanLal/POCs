//
//  TOCCell.h
//  WKWebViewCommunicationTest
//
//  Created by KISHAN LAL on 11/12/19.
//  Copyright © 2019 KISHAN LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOCCell : UITableViewCell{
    
}

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *itemTitle;

@end
