//
//  Datasource.m
//  IsIt
//
//  Created by Shawn Roske on 5/6/09.
//  Copyright 2009 Bitgun. All rights reserved.
//

#import <JSON/JSON.h>
#import "Datasource.h"
#import "SynthesizeSingleton.h"
#import "NSArray-Shuffle.h"

#define QUESTIONS_PER_PAGE 30
#define QUESTIONS_URL @"http://isitanapp.com/questions/random/%i.js"

@interface Datasource (Private)

- (void) appendLastQuestion;
- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer;

@end

@implementation Datasource

SYNTHESIZE_SINGLETON_FOR_CLASS(Datasource);

- (id)init
{
	self = [super init];
	if (self != nil)
	{
    lastRetrieveSucceeded = YES;
    currentPage = 1;
    questions = [[NSMutableArray alloc] init];
    [self appendQuestion: @"Is it an App?" withAnswer: YES];
	}
	return self;
}

- (void) dealloc
{
  [questions release];
  [super dealloc];
}

- (NSInteger) questionCount
{
	return [questions count];
}

- (NSDictionary *) dataForQuestion: (NSInteger) index
{
	return [questions objectAtIndex: index];
}

- (BOOL) retrieveMoreQuestions
{
  if (!lastRetrieveSucceeded) return lastRetrieveSucceeded;

	NSURL *jsonURL = [NSURL URLWithString: [NSString stringWithFormat: QUESTIONS_URL, 
                                          currentPage, nil]];
	NSLog(@"fetching %@", jsonURL);
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL: jsonURL];	
	if (jsonData == nil)
	{
    [self appendLastQuestion];
    lastRetrieveSucceeded = NO;
	}
	else 
	{
    NSArray *fetched = [[jsonData JSONValue] shuffledArray];
    [questions addObjectsFromArray: fetched];
    // if we received less than a whole pages worth of questions, add the last question
    if ([fetched count] < QUESTIONS_PER_PAGE)
    {
      [self appendLastQuestion];
    }
    NSLog(@"added another %i questions, total: %i", [fetched count], [questions count]);
    lastRetrieveSucceeded = YES;
    currentPage += 1;
	}
	[jsonData release];	
  
  return lastRetrieveSucceeded;
}

- (void) cleanupOldQuestions
{
  // TODO, clear out some of the older question entries to free up memory
}

#pragma mark Private

- (void) appendLastQuestion
{
  [self appendQuestion: @"Is this the last question?" withAnswer: YES];
}

- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer
{
  NSArray *keys = [NSArray arrayWithObjects: @"question", @"answer", nil];
  NSArray *objects = [NSArray arrayWithObjects: question, answer ? @"1" : @"0", nil];
  [questions addObject: [NSDictionary dictionaryWithObjects: objects forKeys: keys]];
}

@end
