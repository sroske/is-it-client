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

//#define QUESTIONS_URL @"http://google.com/%i"
//#define QUESTIONS_URL @"http://localhost:3000/questions/random/%i.js"
#define QUESTIONS_URL @"http://www.isitanapp.com/questions/random/%i.js"

@interface Datasource (Private)

- (void) appendStaticQuestions;
- (void) appendLastQuestion;
- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer;
- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer
       andLoadingScreen: (BOOL) loadingScreen;

@end

@implementation Datasource

SYNTHESIZE_SINGLETON_FOR_CLASS(Datasource);

- (id)init
{
	self = [super init];
	if (self != nil)
	{
        appendedLastQuestion = NO;
        lastRetrieveSucceeded = YES;
        currentPage = 1;
        displayedStates = [[NSMutableArray alloc] init];
        questions = [[NSMutableArray alloc] init];
        loadingScreens = [[NSMutableArray alloc] init];
        [self appendQuestion: @"Is it an App?" withAnswer: YES];
	}
	return self;
}

- (void) dealloc
{
    [displayedStates release];
    [questions release];
    [loadingScreens release];
    [super dealloc];
}

// exposing this for the DS consumers' benefit
- (NSInteger) questionsCountPerPage
{
  return QUESTIONS_PER_PAGE;
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
	NSString *jsonData = [[[NSString alloc] initWithContentsOfURL: jsonURL] autorelease];	
	if (jsonData == nil)
	{
        [self appendStaticQuestions];
        [self appendLastQuestion];
        lastRetrieveSucceeded = NO;
	}
	else 
	{
        NSArray *fetched = [[jsonData JSONValue] shuffledArray];
        for (int i = 0; i < [fetched count]; i++)
        {
            [questions addObject: [fetched objectAtIndex: i]];
            [displayedStates addObject: [NSNumber numberWithInteger: 0]];
            [loadingScreens addObject: [NSNumber numberWithInteger: 0]];
            
            if ([fetched count] >= QUESTIONS_PER_PAGE && i == (QUESTIONS_PER_PAGE / 2))
            {
                [self appendQuestion: @"Have more questions been loaded?" withAnswer: YES andLoadingScreen: YES];
            }
        }
        // if we received less than a whole pages worth of questions, add the last question
        if ([fetched count] < QUESTIONS_PER_PAGE)
        {
          [self appendLastQuestion];
        }
        NSLog(@"added another %i questions, total: %i", [fetched count], [questions count]);
        lastRetrieveSucceeded = YES;
        currentPage += 1;
	}
	//[jsonData release];	
  
    return lastRetrieveSucceeded;
}

- (BOOL) displayedYet: (NSInteger) index
{
    if (index >= 0 && index < [displayedStates count])
    {
        return [[displayedStates objectAtIndex: index] intValue] == 1;        
    }
    return NO;
}
- (void) setHasBeenDisplayed: (NSInteger) index
{
    if (index >= 0 && index < [displayedStates count])
    {
        [displayedStates replaceObjectAtIndex: index withObject: [NSNumber numberWithInteger: 1]];
    }    
}

- (BOOL) isLoadingScreen: (NSInteger) index
{
    if (index >= 0 && index < [loadingScreens count])
    {
        return [[loadingScreens objectAtIndex: index] intValue] == 1;        
    }
    return NO;
}

- (void) cleanupOldQuestions
{
  // TODO, clear out some of the older question entries to free up memory
}

#pragma mark Private
    
- (void) appendStaticQuestions
{
    [self appendQuestion: @"Is life fair?" withAnswer: NO];
    [self appendQuestion: @"Are you awesome?" withAnswer: NO];
    [self appendQuestion: @"Am I tired?" withAnswer: YES];
    [self appendQuestion: @"Is my computer on?" withAnswer: YES];
    [self appendQuestion: @"Has the Large Hadron Collider destroyed the world yet?" withAnswer: NO];
    [self appendQuestion: @"Is Helvetica the best font?" withAnswer: NO];
    [self appendQuestion: @"Is Barack Obama Muslin?" withAnswer: NO];
    [self appendQuestion: @"Do websites need to look exactly the same in every browser?" withAnswer: NO];
    [self appendQuestion: @"Does Internet Explorer suck?" withAnswer: YES];
    [self appendQuestion: @"Is it ok to use Comic Sans yet?" withAnswer: NO];
    [self appendQuestion: @"Is 0.999... equal to 1?" withAnswer: YES];
    [self appendQuestion: @"Is it secret, is it safe?" withAnswer: YES];
    [self appendQuestion: @"Do all your base belong to us?" withAnswer: YES];
    [self appendQuestion: @"Is Keyboard Cat alive and well?" withAnswer: NO];
    [self appendQuestion: @"I know, right?" withAnswer: NO];
}

- (void) appendLastQuestion
{
    if (appendedLastQuestion) return;
    [self appendQuestion: @"Is this the last question?" withAnswer: YES];
    appendedLastQuestion = YES;
}

- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer
{
    [self appendQuestion: question withAnswer: answer andLoadingScreen: NO];
}

- (void) appendQuestion: (NSString *) question
             withAnswer: (BOOL) answer
       andLoadingScreen: (BOOL) loadingScreen
{
    NSArray *keys = [NSArray arrayWithObjects: @"question", @"answer", nil];
    NSArray *objects = [NSArray arrayWithObjects: question, answer ? @"1" : @"0", nil];
    [questions addObject: [NSDictionary dictionaryWithObjects: objects forKeys: keys]];
    [displayedStates addObject: [NSNumber numberWithInteger: 0]];
    [loadingScreens addObject: [NSNumber numberWithInteger: loadingScreen]];
}

@end
