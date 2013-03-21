//
//  VNViewController.m
//  VoiceNavigation
//
//  Created by Kishikawa Katsumi on 12/03/09.
//  Copyright (c) 2012 Kishikawa Katsumi. All rights reserved.
//

#import "VNViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RobotKit/RobotKit.h"
#import "RobotUIKit/RobotUIKit.h"

@interface VNViewController (private)
-(BOOL)hasString:(NSString *)string Search:(NSString *)searchText;
@end

static const NSTimeInterval VNDictationRepeatInterval = 3.0;

@interface VNViewController () {
    float count;
    CADisplayLink *displayLink;
}

@property (nonatomic, retain) id dictationController;

@end

@implementation VNViewController

@synthesize searchBar;
@synthesize webView;
@synthesize dictationView;
@synthesize resultLabel;
@synthesize micImageView;
@synthesize dictationIndicator;
@synthesize timerView;

@synthesize textInputView;
@synthesize dictationController;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.searchBar = nil;
    self.webView = nil;
    self.dictationView = nil;
    self.resultLabel = nil;
    self.micImageView = nil;
    self.dictationIndicator = nil;
    self.timerView = nil;
    
    self.textInputView = nil;
    self.dictationController = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];

    dictationView.layer.cornerRadius = 8.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationWillEnterForeground:) 
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidEnterBackground:) 
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(dictationRecordingDidEnd:) 
                                                 name:VNDictationRecordingDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(dictationRecognitionSucceeded:) 
                                                 name:VNDictationRecognitionSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(dictationRecognitionFailed:) 
                                                 name:VNDictationRecognitionFailedNotification object:nil];
    /*Register for application lifecycle notifications so we known when to connect and disconnect from the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [self keyboardWillShow:nil];
    /*Only start the blinking loop when the view loads*/
    robotOnline = NO;
    
    calibrateHandler = [[RUICalibrateGestureHandler alloc] initWithView:self.view];

}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    
    if (![textInputView isFirstResponder]) {
        [textInputView becomeFirstResponder];
    }
}

- (void)viewDidUnload {
    NSLog(@"viewDidUnload");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

#pragma mark -

- (void)resetProgress {
    NSLog(@"resetProgress");
    count = 0.0f;
    [timerView setProgress:count animated:NO];
}

- (void)showWaitingServerProcessIndicator {
    NSLog(@"showWaitingServerProcessIndicator");
    [dictationIndicator startAnimating];
    micImageView.hidden = YES;
}

- (void)hideWaitingServerProcessIndicator {
    NSLog(@"hideWaitingServerProcessIndicator");
    [dictationIndicator stopAnimating];
}

- (void)startDictation {
    NSLog(@"startDictation");
    [dictationController performSelector:@selector(startDictation)];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimer:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self resetProgress];
    micImageView.hidden = NO;
    resultLabel.text = nil;
}

- (void)stopDictation {
    NSLog(@"stopDictation");
    [dictationController performSelector:@selector(stopDictation)];
    
    [displayLink invalidate];
    displayLink = nil;
    
    [self showWaitingServerProcessIndicator];
    micImageView.hidden = YES;
}

- (void)cancelDictation {
    NSLog(@"cancelDictation");
    [dictationController performSelector:@selector(cancelDictation)];
    
    [displayLink invalidate];
    displayLink = nil;
    
    [self resetProgress];
    micImageView.hidden = NO;
    resultLabel.text = nil;
}

#pragma mark -

- (NSString *)wholeTestWithDictationResult:(NSArray *)dictationResult {
    NSLog(@"wholeTestWithDictationResult");
    NSMutableString *text = [NSMutableString string];
    for (UIDictationPhrase *phrase in dictationResult) {
        [text appendString:phrase.text];
    }
    
    return text;
}

- (void)processDictationText:(NSString *)text {
    NSLog(@"processDictationText");
    resultLabel.text = text;
    //NSLog(@"text=%@",text);
    NSLog(@"text");
    if ([text hasSuffix:[NSString stringWithUTF8String:"を検索"]]) {
        text = [text substringToIndex:[text length] - 3];

        searchBar.text = text; 
        NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/m?q=%@&ie=UTF-8&oe=UTF-8&client=safari",
                                                 [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [webView loadRequest:[NSURLRequest requestWithURL:searchURL]];
    } else if ([self hasString:text Search:@"とまれ"] || [self hasString:text Search:@"止"]) {
        NSLog(@"止まれ");
        [RKRollCommand sendStop];
        //[webView goBack];
    } else if ([self hasString:text Search:@"戻れ"]) {
        NSLog(@"戻る");
        [RKRollCommand sendCommandWithHeading:180.0 velocity:0.5];
        //[webView goBack];
    } else if ([self hasString:text Search:@"進め"]) {
        NSLog(@"進む");
        [RKRollCommand sendCommandWithHeading:0.0 velocity:0.5];
        //[webView goForward];
    } else if ([self hasString:text Search:@"お前の血は何色だ"]) {
        NSLog(@"お前の血は何色だ");
        [self changeColorRed:NULL];
    } else if ([self hasString:text Search:@"青"]) {
        NSLog(@"青");
        [self changeColorBlue:NULL];
    } else if ([self hasString:text Search:@"赤"] || [self hasString:text Search:@"あか"]) {
        NSLog(@"赤");
        [self changeColorRed:NULL];
    } else if ([self hasString:text Search:@"緑"]) {
        NSLog(@"緑");
        [self changeColorGreen:NULL];
    }
    //[RKRollCommand sendCommandWithHeading:0.0 velocity:0.5];
}

-(BOOL)hasString:(NSString *)string Search:(NSString *)searchText{
    NSRange range = [string rangeOfString:searchText];
    if (range.location != NSNotFound) {
        return TRUE;
    }
    return FALSE;
}

#pragma mark -

- (void)onTimer:(CADisplayLink *)sender {
    //NSLog(@"onTimer");
    count += sender.duration / 3.0;
    [timerView setProgress:count animated:YES];
    if (count >= 1.0f) {        
        [self stopDictation];
    }
}

#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    self.dictationController = [NSClassFromString(@"UIDictationController") performSelector:@selector(sharedInstance)];
    if (dictationController) {
        [self startDictation];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSLog(@"applicationWillEnterForeground");
    [self startDictation];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    NSLog(@"applicationDidEnterBackground");
    [self cancelDictation];
}

#pragma mark -

- (void)dictationRecordingDidEnd:(NSNotification *)notification {
    NSLog(@"dictationRecordingDidEnd");
}

- (void)dictationRecognitionSucceeded:(NSNotification *)notification {
    NSLog(@"dictationRecognitionSucceeded");
    NSDictionary *userInfo = notification.userInfo;
    NSArray *dictationResult = [userInfo objectForKey:VNDictationResultKey];
    
    NSString *text = [self wholeTestWithDictationResult:dictationResult];
    [self processDictationText:text];
    
    [self hideWaitingServerProcessIndicator];
    
    [self performSelector:@selector(startDictation) withObject:nil afterDelay:VNDictationRepeatInterval];
}

- (void)dictationRecognitionFailed:(NSNotification *)notification {
    NSLog(@"dictationRecognitionFailed");
    resultLabel.text = @"-";
    
    [self hideWaitingServerProcessIndicator];
    
    [self performSelector:@selector(startDictation) withObject:nil afterDelay:VNDictationRepeatInterval];
}


#pragma mark -
#pragma mark RobotUIKit

-(void)appWillResignActive:(NSNotification*)notification {
    /*When the application is entering the background we need to close the connection to the robot*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKDeviceConnectionOnlineNotification object:nil];
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
}

-(void)appDidBecomeActive:(NSNotification*)notification {
    /*When the application becomes active after entering the background we try to connect to the robot*/
    [self setupRobotConnection];
}

- (void)handleRobotOnline {
    /*The robot is now online, we can begin sending commands*/
    
    robotOnline = YES;
}

-(void)setupRobotConnection {
    /*Try to connect to the robot*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRobotOnline) name:RKDeviceConnectionOnlineNotification object:nil];
    if ([[RKRobotProvider sharedRobotProvider] isRobotUnderControl]) {
        [[RKRobotProvider sharedRobotProvider] openRobotConnection];        
    }
}

#pragma mark -
#pragma mark Interface interaction


-(IBAction)zeroPressed:(id)sender {
    NSLog(@"zeroPressed");
    [RKRollCommand sendCommandWithHeading:0.0 velocity:0.5];
}

-(IBAction)ninetyPressed:(id)sender {
    NSLog(@"ninetyPressed");
    [RKRollCommand sendCommandWithHeading:90.0 velocity:0.5];
}

-(IBAction)oneEightyPressed:(id)sender {
    NSLog(@"oneEightyPressed");
    [RKRollCommand sendCommandWithHeading:180.0 velocity:0.5];
}

-(IBAction)twoSeventyPressed:(id)sender {
    NSLog(@"twoSeventyPressed");
    [RKRollCommand sendCommandWithHeading:270.0 velocity:0.5];
}

-(IBAction)stopPressed:(id)sender {
    NSLog(@"stopPressed");
    //The sendStop method sends a roll command with zero velocity and the last heading to make Sphero stop
    [RKRollCommand sendStop];
}

-(IBAction)turn:(id)sender {
    NSLog(@"turn");
}

-(IBAction)changeColorRed:(id)sender {
    NSLog(@"changeColorRed");
    [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
}
-(IBAction)changeColorGreen:(id)sender {
    NSLog(@"changeColorGreen");
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:1.0 blue:0.0];
}
-(IBAction)changeColorBlue:(id)sender {
    NSLog(@"changeColorBlue");
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:1.0];
}


@end
