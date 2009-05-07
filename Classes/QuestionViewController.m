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

@synthesize questionIndex;

- (void) setQuestionIndex: (NSInteger) newQuestionIndex
{
	questionIndex = newQuestionIndex;
	if (questionIndex >= 0 && questionIndex < [[Datasource sharedDatasource] questionCount])
	{
		NSDictionary *questionData = [[Datasource sharedDatasource] dataForQuestion: questionIndex];
		questionLabel.text = [questionData objectForKey: @"question"];
		answerLabel.text = [[questionData objectForKey: @"answer"] boolValue] == YES ? @"YES" : @"NO";
	}
}

- (void) fadeOutAnswer
{ 
	[answerLabel setAlpha: 0];
}

- (void) fadeInAnswer
{
  [UIView beginAnimations: @"answerFadeIn" context: NULL];
	[UIView setAnimationDuration: 0.5f];
  [UIView setAnimationDelay: 0.2f];
  [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];

	[answerLabel setAlpha: 1];
	
	[UIView commitAnimations];
}

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad 
{
  [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
