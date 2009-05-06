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
  IBOutlet UIActivityIndicatorView *indicator;
	NSMutableArray *controllers;
	NSMutableArray *questions;
  BOOL lastRetrieveSucceeded;
  int currentPage;
}

@property (nonatomic, retain) NSMutableArray *controllers;
@property (nonatomic, retain) NSMutableArray *questions;

- (void) setupIndicator;
- (void) retrieveFirstRunQuestions;
- (void) retrieveQuestions: (BOOL) firstRun;
- (void) loadQuestion: (int) index;
- (void) fadeInAnswer: (int) index;
- (void) addLastQuestion;
- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer;

@end

