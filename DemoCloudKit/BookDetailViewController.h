//
//  BookDetailViewController.h
//  DemoCloudKit
//
//  Created by HuyTCM1 on 9/9/16.
//  Copyright © 2016 HuyTCM1. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import <UIKit/UIKit.h>

@interface BookDetailViewController : UIViewController

@property (strong, nonatomic) CKRecord *book;

@end
