//
//  IsItViewController.h
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright Bitgun 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionViewController.h"

@interface IsItViewController : UIViewController <UIScrollViewDelegate> {
  IBOutlet UIScrollView *scrollView;
  IBOutlet UIActivityIndicatorView *indicator;
	QuestionViewController *currentQuestion;
	QuestionViewController *nextQuestion;
  BOOL lastRetrieveSucceeded;
}

- (void) setupIndicator;
- (void) startIndicating;
- (void) stopIndicating;

- (void) retrieveFirstRunQuestions;
- (void) retrieveAdditionalQuestions;
- (void) retrieveQuestions: (BOOL) firstRun;

- (void) applyNewIndex: (NSInteger) newIndex 
    questionController: (QuestionViewController *) questionController;

@end

