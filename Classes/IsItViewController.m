//
//  IsItViewController.m
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright Bitgun 2009. All rights reserved.
//

#import "IsItViewController.h"
#import "QuestionViewController.h"
#import "Datasource.h"

#define QUESTIONS_REMAINING_PADDING 15

@implementation IsItViewController

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation 
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
  [[Datasource sharedDatasource] cleanupOldQuestions];
}

- (void) viewDidUnload 
{
  [currentQuestion release];
  [nextQuestion release];
}

/*
- (void) dealloc 
{
  [super dealloc];
}
*/

#pragma mark initialization

- (void) viewDidLoad
{
  lastRetrieveSucceeded = NO;
  
	currentQuestion = [[QuestionViewController alloc] init];
	nextQuestion = [[QuestionViewController alloc] init];
  
	[scrollView addSubview: currentQuestion.view];
	[scrollView addSubview: nextQuestion.view];
  
  scrollView.contentOffset = CGPointMake(0, 0);
  
  // set up the title screen as the first question
  [self applyNewIndex: 0 questionController: currentQuestion];
  [self applyNewIndex: 1 questionController: nextQuestion];
  
  [self setupIndicator];

  // now fetch the other questions from the server
  [NSThread detachNewThreadSelector: @selector(retrieveFirstRunQuestions) 
                           toTarget: self 
                         withObject: nil];
}

#pragma mark Loading indicator

- (void) setupIndicator
{
  // add indicator
  CGRect frame = indicator.frame;
  frame.origin.x = 320 / 2 - frame.size.width / 2;
  frame.origin.y = 265;
  indicator.frame = frame;
  [scrollView addSubview: indicator];
  [self startIndicating];
}

- (void) startIndicating
{
  [UIView beginAnimations: @"indicatorFadeIn" context: NULL];
	[UIView setAnimationDuration: 0.2f];
	[indicator startAnimating];
	[UIView commitAnimations];
}

- (void) stopIndicating
{
  [UIView beginAnimations: @"indicatorFadeOut" context: NULL];
  [UIView setAnimationDuration: 0.2f];
  [indicator stopAnimating];
  [UIView commitAnimations];
}

#pragma mark Question setup and retrieval

- (void) retrieveFirstRunQuestions
{
  [self retrieveQuestions: YES];
}

- (void) retrieveAdditionalQuestions
{
  [self retrieveQuestions: NO];
}

- (void) retrieveQuestions: (BOOL) firstRun
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  lastRetrieveSucceeded = [[Datasource sharedDatasource] retrieveMoreQuestions];
  
  // resize the scrollview's content as needed
  NSInteger widthCount = [[Datasource sharedDatasource] questionCount];
	if (widthCount == 0) widthCount = 1;
	
  scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * widthCount, 
                                      scrollView.frame.size.height);

  // if this is the first time we retrieved these questions,
  // we need to load the first non-title screen question and fade
  // in the title screen answer
  if (firstRun)
  {
    [self stopIndicating];
    [self applyNewIndex: 1 questionController: nextQuestion];
    [currentQuestion fadeInAnswer];
  }
  
  [pool release];
}

#pragma mark Question view manipulation

- (void) applyNewIndex: (NSInteger) newIndex 
    questionController: (QuestionViewController *) questionController
{
	NSInteger questionCount = [[Datasource sharedDatasource] questionCount];
	BOOL outOfBounds = newIndex >= questionCount || newIndex < 0;
  
	if (!outOfBounds)
	{
		CGRect questionFrame = questionController.view.frame;
		questionFrame.origin.y = 0;
		questionFrame.origin.x = scrollView.frame.size.width * newIndex;
		questionController.view.frame = questionFrame;
	}
	else
	{
		CGRect questionFrame = questionController.view.frame;
		questionFrame.origin.y = scrollView.frame.size.height;
		questionController.view.frame = questionFrame;
	}
  
	questionController.questionIndex = newIndex;
}

#pragma mark UIScrollViewDelegate

- (void) scrollViewDidScroll: (UIScrollView *) sender
{
  CGFloat pageWidth = scrollView.frame.size.width;
  float fractionalPage = scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
	
	if (lowerNumber == currentQuestion.questionIndex)
	{
		if (upperNumber != nextQuestion.questionIndex)
		{
			[self applyNewIndex: upperNumber questionController: nextQuestion];
		}
	}
	else if (upperNumber == currentQuestion.questionIndex)
	{
		if (lowerNumber != nextQuestion.questionIndex)
		{
			[self applyNewIndex: lowerNumber questionController: nextQuestion];
		}
	}
	else
	{
		if (lowerNumber == nextQuestion.questionIndex)
		{
			[self applyNewIndex: upperNumber questionController: currentQuestion];
		}
		else if (upperNumber == nextQuestion.questionIndex)
		{
			[self applyNewIndex: lowerNumber questionController: currentQuestion];
		}
		else
		{
			[self applyNewIndex: lowerNumber questionController: currentQuestion];
			[self applyNewIndex: upperNumber questionController: nextQuestion];
		}
	}
}

- (void) scrollViewDidEndDecelerating: (UIScrollView *) sender
{
  CGFloat pageWidth = scrollView.frame.size.width;
  float fractionalPage = scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
  
	if (currentQuestion.questionIndex != nearestNumber)
	{
		QuestionViewController *swapController = currentQuestion;
		currentQuestion = nextQuestion;
		nextQuestion = swapController;
	}
  
  [nextQuestion fadeOutAnswer];
  [currentQuestion fadeInAnswer];
  
  NSLog(@"currentQuestion.questionIndex: %i", currentQuestion.questionIndex);
  // if the last retrieve attempt succeeded, and we need more question try to grab some more
  if (lastRetrieveSucceeded && currentQuestion.questionIndex + 1 > 
      [[Datasource sharedDatasource] questionCount] - QUESTIONS_REMAINING_PADDING)
  {
    [NSThread detachNewThreadSelector: @selector(retrieveAdditionalQuestions) 
                             toTarget: self 
                           withObject: nil];
  }
}

@end
