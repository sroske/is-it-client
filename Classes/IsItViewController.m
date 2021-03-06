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

@implementation IsItViewController

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

- (void) dealloc 
{
    [currentQuestion release];
    [nextQuestion release];
    [super dealloc];
}

#pragma mark initialization

- (void) viewDidLoad
{
    initialAnswer = YES;
    
	currentQuestion = [[QuestionViewController alloc] initWithNibName: @"QuestionViewController" bundle: nil];
    [currentQuestion setTarget: self];
    [currentQuestion setAction: @selector(answerFadedIn:)];
	nextQuestion = [[QuestionViewController alloc] initWithNibName: @"QuestionViewController" bundle: nil];
    [nextQuestion setTarget: self];
    [nextQuestion setAction: @selector(answerFadedIn:)];
  
	[scrollView addSubview: currentQuestion.view];
	[scrollView addSubview: nextQuestion.view];
  
    scrollView.contentOffset = CGPointMake(0, 0);

    // set up the title screen as the first question
    [self applyNewIndex: 0 questionController: currentQuestion];
    [self applyNewIndex: 1 questionController: nextQuestion];

    [self setupIndicator];
    
    [self startIndicating];
    [scrollView setScrollEnabled: NO];
    
    // now fetch the other questions from the server
    [NSThread detachNewThreadSelector: @selector(retrieveQuestions:) 
                             toTarget: self 
                           withObject: [NSNumber numberWithInteger: YES]];
}

#pragma mark Loading indicator

- (void) setupIndicator
{
  // add indicator
  CGRect frame = indicator.frame;
  frame.origin.x = 320 / 2 - frame.size.width / 2;
  frame.origin.y = 260;
  indicator.frame = frame;
  [scrollView addSubview: indicator];
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

- (void) retrieveQuestions: (BOOL) firstRun
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [[Datasource sharedDatasource] retrieveMoreQuestions];
    
    [self performSelectorOnMainThread: @selector(completedRetrieval:) 
                           withObject: [NSNumber numberWithInteger: firstRun]
                        waitUntilDone: NO];
    [pool release];
}

- (void) completedRetrieval: (BOOL) firstRun
{
    // resize the scrollview's content as needed
    NSInteger widthCount = [[Datasource sharedDatasource] questionCount];
    if (widthCount == 0) widthCount = 1;
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * widthCount, 
                                        scrollView.frame.size.height);
    
    // if this is the first time we retrieved these questions,
    // we need to load the first non-title screen question
    if (firstRun)
    {
        [self applyNewIndex: 1 questionController: nextQuestion];
    }
    [self stopIndicating];
    [scrollView setScrollEnabled: YES];
    [currentQuestion fadeInAnswer];
}

#pragma mark Question view manipulation

- (void) answerFadedIn: (NSNumber *) index
{
    if ([index intValue] == 0)
    {
        [scrollView setContentOffset: CGPointMake(scrollView.frame.size.width, 0.0) 
                            animated: YES];
    }
}

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
    // if we have "ended" on the first question and we haven't shown an initialAnswer
    // this means it is the progrommatic setContentOffset from answerFadedIn:
    // so we will call scrollViewDidEndDecelerating manually just this once.
    if (fractionalPage == 1.00 && initialAnswer)
    {
        initialAnswer = NO;
        [self scrollViewDidEndDecelerating: sender];
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

    if ([[Datasource sharedDatasource] isLoadingScreen: currentQuestion.questionIndex])
    {
        [scrollView setScrollEnabled: NO];
        [self startIndicating];
        [NSThread detachNewThreadSelector: @selector(retrieveQuestions:) 
                                 toTarget: self 
                               withObject: [NSNumber numberWithInteger: NO]];
    }
    else
    {
        [currentQuestion fadeInAnswer];
    }
}

@end
