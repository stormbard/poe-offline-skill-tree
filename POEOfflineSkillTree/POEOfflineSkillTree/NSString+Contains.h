//
//  NSString+Contains.h
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/26/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Contains)

-(BOOL)containsString:(NSString *)str;
-(BOOL)containsString:(NSString *)str options:(NSStringCompareOptions) options;

@end
