//
//  QuestionViewController.m
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright 2009 Bitgun. All rights reserved.
//

#import "QuestionViewController.h"
#import "Datasource.h"

@implementation QuestionViewController

@synthesize questionIndex, target, action;

- (void) setQuestionIndex: (NSInteger) newQuestionIndex
{
	questionIndex = newQuestionIndex;
	if (questionIndex >= 0 && questionIndex < [[Datasource sharedDatasource] questionCount])
	{
		NSDictionary *questionData = [[Datasource sharedDatasource] dataForQuestion: questionIndex];
		[questionLabel setText: [questionData objectForKey: @"question"]];
        [answerLabel setAlpha: [[Datasource sharedDatasource] displayedYet: questionIndex] ? 1.0 : 0.0];
		[answerLabel setText: [[questionData objectForKey: @"answer"] boolValue] == YES ? @"YES" : @"NO"];
	}
}

- (void) fadeInAnswer
{
    [UIView beginAnimations: @"answerFadeIn" context: NULL];
    [UIView setAnimationDuration: 0.5f];
    [UIView setAnimationDelay: 0.2f];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(answerFadedIn:finished:context:)];

    [answerLabel setAlpha: 1.0];

    [UIView commitAnimations];
}

- (void) answerFadedIn: (NSString *) animationID
              finished: (BOOL) finished
               context: (void *) context
{
    if (![[Datasource sharedDatasource] displayedYet: questionIndex] && [self.target respondsToSelector: self.action])
    {
        [self.target performSelector: self.action withObject: [NSNumber numberWithInteger: self.questionIndex]];
    }
    [[Datasource sharedDatasource] setHasBeenDisplayed: self.questionIndex];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];

    
    questionLabel = [[FontLabel alloc] initWithPoint:CGPointMake(160, 130) 
                                                name:@"MyriadPro-Regular" 
                                                size:24.0f 
                                               color:[UIColor blackColor] 
                                           autoframe:YES];
    [questionLabel setJustify: kCenter];
    [questionLabel setString:@"Is it an App?"];
    [self.view addSubview:questionLabel];
    [questionLabel release];
    
    answerLabel = [[FontLabel alloc] initWithPoint:CGPointMake(160, 200) 
                                                name:@"MyriadPro-Bold" 
                                                size:72.0f 
                                               color:[UIColor blackColor] 
                                           autoframe:YES];
    [answerLabel setJustify: kCenter];
    [answerLabel setString:@"YES"];
    [self.view addSubview:answerLabel];
    [answerLabel release];
}

- (void)viewDidUnload {
    [questionLabel release];
    [answerLabel release];
    [super viewDidLoad];
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
