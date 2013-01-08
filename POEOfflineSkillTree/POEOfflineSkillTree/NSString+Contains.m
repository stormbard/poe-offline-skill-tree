//
//  NSString+Contains.m
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/26/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import "NSString+Contains.h"

@implementation NSString (Contains)

-(BOOL)containsString:(NSString *)str {
    return [self containsString:str options:NSLiteralSearch];
}

-(BOOL)containsString:(NSString *)str options:(NSStringCompareOptions) options {
    return [self rangeOfString:str options:options].location != NSNotFound;
}

-(NSString *)replaceFirstOccurance:(NSString *)str
                       replaceWith:(NSString *)replace {
    NSRange replaceRange = [self rangeOfString:str];
    if (replaceRange.location != NSNotFound) {
        return [self stringByReplacingCharactersInRange:replaceRange withString:replace];
    }
    return nil;
}

@end
