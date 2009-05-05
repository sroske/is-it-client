//
//  IsItViewController.m
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright Bitgun 2009. All rights reserved.
//

#import <JSON/JSON.h>
#import "IsItViewController.h"
#import "QuestionViewController.h"

@implementation IsItViewController

@synthesize questions, controllers;

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
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[self.controllers release];
	[self.questions release];
}


- (void) dealloc 
{
  [super dealloc];
}

#pragma mark initialization

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad 
{
  [super viewDidLoad];
	[self retrieveQuestions];
	NSLog(@"loaded questions: %@", questions);
	
	// hiding the navigation bar
	self.navigationController.navigationBarHidden = YES;
	
  // view controllers are created lazily
  // in the meantime, load the array with placeholders which will be replaced on demand
  self.controllers = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [self.questions count]; i++) {
    [self.controllers addObject: [NSNull null]];
  }
	
  // a page is the width of the scroll view
  scrollView.pagingEnabled = YES;
  scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [self.questions count], scrollView.frame.size.height);
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.scrollsToTop = NO;
  scrollView.delegate = self;
	
  [self loadQuestion: 0];
  [self loadQuestion: 1];
}

- (void) retrieveQuestions
{
	NSURL *jsonURL = [NSURL URLWithString: @"http://is-it.bitgun.com/random.js"];
	
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL: jsonURL];	
	if (jsonData == nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Webservice Down" 
                                                    message: @"The webservice you are accessing is down. Please try again later." 
                                                   delegate: self 
                                          cancelButtonTitle: @"OK" 
                                          otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
	else 
	{
		self.questions = [jsonData JSONValue]; 
	}
	[jsonData release];	
}

#pragma mark paging

- (void) loadQuestion: (int) index
{
  if (index < 0) return;
  if (index >= [self.questions count]) return;
	
  // replace the placeholder if necessary
  QuestionViewController *controller = (QuestionViewController *) [self.controllers objectAtIndex: index];
  if ((NSNull *) controller == [NSNull null]) 
	{
		NSDictionary *itemAtIndex = (NSDictionary *) [self.questions objectAtIndex: index];
    controller = [[QuestionViewController alloc] initWithQuestion: [itemAtIndex objectForKey: @"question"] 
                                                        andAnswer: [[itemAtIndex objectForKey: @"answer"] boolValue]];
    [self.controllers replaceObjectAtIndex: index withObject: controller];
    [controller release];
  }
	
  // add the controller's view to the scroll view
  if (controller.view.superview == nil) {
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    controller.view.frame = frame;
    [scrollView addSubview: controller.view];
  }
}

#pragma mark UIScrollViewDelegate

- (void) scrollViewDidScroll: (UIScrollView *) sender 
{
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = scrollView.frame.size.width;
  int currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
  // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
  [self loadQuestion: currentIndex - 1];
  [self loadQuestion: currentIndex];
  [self loadQuestion: currentIndex + 1];
}

@end
