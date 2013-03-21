//
//  VNViewController.h
//  VoiceNavigation
//
//  Created by Kishikawa Katsumi on 12/03/09.
//  Copyright (c) 2012 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VNTextInputView.h"
#import <RobotUIKit/RobotUIKit.h>

@interface VNViewController : UIViewController {
    BOOL robotOnline;
    RUICalibrateGestureHandler *calibrateHandler;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *dictationView;
@property (nonatomic, retain) IBOutlet UILabel *resultLabel;
@property (nonatomic, retain) IBOutlet UIImageView *micImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *dictationIndicator;
@property (nonatomic, retain) IBOutlet UIProgressView *timerView;

@property (nonatomic, retain) IBOutlet VNTextInputView *textInputView;

-(void)setupRobotConnection;
-(void)handleRobotOnline;

//Interface interactions
-(IBAction)zeroPressed:(id)sender;
-(IBAction)ninetyPressed:(id)sender;
-(IBAction)oneEightyPressed:(id)sender;
-(IBAction)twoSeventyPressed:(id)sender;
-(IBAction)stopPressed:(id)sender;
//Interface color
-(IBAction)changeColorRed:(id)sender;
-(IBAction)changeColorGreen:(id)sender;
-(IBAction)changeColorBlue:(id)sender;
@end
