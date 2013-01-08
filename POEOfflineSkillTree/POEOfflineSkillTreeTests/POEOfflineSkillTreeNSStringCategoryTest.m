//
//  POEOfflineSkillTreeNSStringCategoryTest.m
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 1/2/13.
//  Copyright (c) 2013 Eric Bunton. All rights reserved.
//

#import "POEOfflineSkillTreeNSStringCategoryTest.h"

@implementation POEOfflineSkillTreeNSStringCategoryTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testReplaceFirstOccuranceMultipleOccurances {
    NSString *testString = nil;
    testString = [@"This is the first occurance #%. This is the next#"
                  replaceFirstOccurance:@"#"                                                                                replaceWith:@"8"];
    NSLog(@"%@", testString);
    STAssertEqualObjects(testString, @"This is the first occurance 8%. This is the next#", @"%@", testString);
}

@end
