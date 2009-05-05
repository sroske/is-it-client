//
//  IsItViewController.h
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright Bitgun 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IsItViewController : UIViewController <UIScrollViewDelegate> {
  IBOutlet UIScrollView *scrollView;
	NSMutableArray *controllers;
	NSMutableArray *questions;
  BOOL lastRetrieveSucceeded;
}

@property (nonatomic, retain) NSMutableArray *controllers;
@property (nonatomic, retain) NSMutableArray *questions;

- (void) retrieveQuestions;
- (void) loadQuestion: (int) index;
- (void) fadeInAnswer: (int) index;
- (void) addLastQuestion;
- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer;

@end

