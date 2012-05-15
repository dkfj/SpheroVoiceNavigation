//
//  VNTextInputView.m
//  VoiceNavigation
//
//  Created by Kishikawa Katsumi on 12/03/10.
//  Copyright (c) 2012 Kishikawa Katsumi. All rights reserved.
//

#import "VNTextInputView.h"

NSString * const VNDictationRecordingDidEndNotification = @"VNDictationRecordingDidEndNotification";
NSString * const VNDictationRecognitionSucceededNotification = @"VNDictationRecognitionSucceededNotification";
NSString * const VNDictationRecognitionFailedNotification = @"VNDictationRecognitionFailedNotification";

NSString * const VNDictationResultKey = @"VNDictationResultKey";

@implementation VNTextInputView

#pragma mark C-

- (BOOL)canBecomeFirstResponder {
    NSLog(@"canBecomeFirstResponder");
    return YES;
}

- (BOOL)resignFirstResponder {
    NSLog(@"resignFirstResponder");
	return [super resignFirstResponder];
}

#pragma mark -

- (UIView *)inputView {
    NSLog(@"inputView");
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

#pragma mark UIKeyInput methods

- (void)deleteBackward {
    NSLog(@"deleteBackward");
    
}

- (BOOL)hasText {
    NSLog(@"hasText");
    return NO;
}

- (void)insertText:(NSString *)text {
    NSLog(@"insertText");
}

#pragma mark UITextInput methods

- (NSString *)textInRange:(UITextRange *)range {
    NSLog(@"textInRange");
    return nil;
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text {
    NSLog(@"replaceRange");
}

/* Text may have a selection, either zero-length (a caret) or ranged.  Editing operations are
 * always performed on the text from this selection.  nil corresponds to no selection. */

- (UITextRange *)selectedTextRange {
    NSLog(@"selectedTextRange");
    return nil;
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange {
    NSLog(@"setSelectedTextRange");    
}

/* If text can be selected, it can be marked. Marked text represents provisionally
 * inserted text that has yet to be confirmed by the user.  It requires unique visual
 * treatment in its display.  If there is any marked text, the selection, whether a
 * caret or an extended range, always resides witihin.
 *
 * Setting marked text either replaces the existing marked text or, if none is present,
 * inserts it from the current selection. */ 

- (UITextRange *)markedTextRange {
    NSLog(@"markedTextRange");    
    return nil;
}

- (NSDictionary *)markedTextStyle {
    NSLog(@"markedTextStyle");    
    return nil;
}

- (void)setMarkedTextStyle:(NSDictionary *)markedTextStyle {
    NSLog(@"setMarkedTextStyle");    
    
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {
    NSLog(@"setMarkedText");    
    
}

- (void)unmarkText {
    NSLog(@"unmarkText");    

}

/* The end and beginning of the the text document. */
- (UITextPosition *)beginningOfDocument {
    NSLog(@"beginningOfDocument");    
    return nil;
}

- (UITextPosition *)endOfDocument {
    NSLog(@"endOfDocument");    
    return nil;
}

- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition {
    NSLog(@"textRangeFromPosition");    
    return nil;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset {
    NSLog(@"positionFromPosition");    
    return nil;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset {
    NSLog(@"positionFromPosition");    
    return nil;
}

/* Simple evaluation of positions */
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other {
    NSLog(@"comparePosition");    
    return 0;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition {
    NSLog(@"offsetFromPosition");    
    return 0;
}

/* A system-provied input delegate is assigned when the system is interested in input changes. */
- (id<UITextInputDelegate>)inputDelegate {
    NSLog(@"inputDelegate");    
    return nil;
}

- (void)setInputDelegate:(id<UITextInputDelegate>)inputDelegate {
    NSLog(@"setInputDelegate");        
}

/* A tokenizer must be provided to inform the text input system about text units of varying granularity. */
- (id<UITextInputTokenizer>)tokenizer {
    NSLog(@"tokenizer");        
    return nil;
}

/* Layout questions. */
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {
    NSLog(@"positionWithinRange");        
    return nil;
}

- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction {
    NSLog(@"characterRangeByExtendingPosition");        
    return nil;
}

/* Writing direction */
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
    NSLog(@"baseWritingDirectionForPosition");        
    return 0;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range {
    NSLog(@"setBaseWritingDirection");        

}

/* Geometry used to provide, for example, a correction rect. */
- (CGRect)firstRectForRange:(UITextRange *)range {
    NSLog(@"firstRectForRange");        
    return CGRectZero;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    NSLog(@"caretRectForPosition");        
    return CGRectZero;
}

/* Hit testing. */
- (UITextPosition *)closestPositionToPoint:(CGPoint)point {
    NSLog(@"closestPositionToPoint");        
    return nil;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range {
    NSLog(@"closestPositionToPoint");        
    return nil;
}

- (UITextRange *)characterRangeAtPoint:(CGPoint)point {
    NSLog(@"characterRangeAtPoint");        
    return nil;
}

#pragma mark -

- (void)insertDictationResult:(NSArray *)dictationResult {
    NSLog(@"insertDictationResult");        
    [[NSNotificationCenter defaultCenter] postNotificationName:VNDictationRecognitionSucceededNotification
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObject:dictationResult forKey:VNDictationResultKey]];
}

- (void)dictationRecordingDidEnd {
    NSLog(@"dictationRecordingDidEnd");        
    [[NSNotificationCenter defaultCenter] postNotificationName:VNDictationRecordingDidEndNotification object:self];
}

- (void)dictationRecognitionFailed {
    NSLog(@"dictationRecognitionFailed");        
    [[NSNotificationCenter defaultCenter] postNotificationName:VNDictationRecognitionFailedNotification object:self];
}

@end
