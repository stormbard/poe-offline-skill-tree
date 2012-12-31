//
//  POEOfflineSkillTreeImporter.m
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/26/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import "POEOfflineSkillTreeImporter.h"

@implementation POEOfflineSkillTreeImporter

static POEOfflineSkillTreeImporter *skillTreeImporter = nil;
static SBJsonParser *parser = nil;
static NSString *jsonString = nil;
static NSDictionary *objects = nil;

+(id)skillTreeImporter {
    @synchronized(self) {
        if (skillTreeImporter == nil) {
            skillTreeImporter = [[self alloc] init];
        }
    }
    return skillTreeImporter;
}

-(id) init {
    if (self = [super init]) {
        jsonString = [self getJson];
        parser = [[SBJsonParser alloc] init];
        objects = [parser objectWithString:jsonString];
    }
    return self;
}

-(void) dealloc {
    //ARC does this for me
}

-(NSArray *) getSkillNodeInfo {
    NSLog(@"Creating Skill Tree");
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    NSLog(@"Creating Nodes...");
    for (NSDictionary *skillNode in [objects valueForKey:@"nodes"]) {
        [mutableArray addObject:skillNode];
    }    
    
    return mutableArray;
}

-(NSArray *)getNodeGroupInfo {
    NSLog(@"Creating Node Group Info");
       
    return [objects valueForKey:@"groups"];
}

-(NSDictionary *) getSkillSpriteInfo {
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];    
    NSMutableArray *activeSkillSprites = [[NSMutableArray alloc] init];
    NSMutableArray *inactiveSkillSprites = [[NSMutableArray alloc] init];
    
    NSLog(@"Constructing skill sprite info...");
    
    for (NSString *dataInfo in objects[@"skillSprites"]) {
        if (![dataInfo containsString:@"inactive" options:NSCaseInsensitiveSearch]) {
            NSDictionary *tempObj = objects[@"skillSprites"][dataInfo][3];
            NSString *fileName = tempObj[@"filename"];
            for (NSString *nodeMap in [tempObj[@"coords"] allKeys]) {
                NSMutableArray *temp = [[NSMutableArray alloc] init];
                NSDictionary *rectDict = tempObj[@"coords"][nodeMap];
                NSRect rect = NSMakeRect([rectDict[@"x"] floatValue], [rectDict[@"y"] floatValue],
                                         [rectDict[@"w"] floatValue], [rectDict[@"h"] floatValue]);
                [temp addObject:fileName];
                [temp addObject:nodeMap];
                [temp addObject:NSStringFromRect(rect)];
                [activeSkillSprites addObject:temp];
            }
        }
    }
    [dictionary setValue:activeSkillSprites forKey:@"activeSkillSprites"];
    
    for (NSString *dataInfo in objects[@"skillSprites"]) {
        if ([dataInfo containsString:@"inactive" options:NSCaseInsensitiveSearch]) {
            NSDictionary *tempObj = objects[@"skillSprites"][dataInfo][3];
            NSString *fileName = tempObj[@"filename"];
            for (NSString *nodeMap in [tempObj[@"coords"] allKeys]) {
                NSMutableArray *temp = [[NSMutableArray alloc] init];
                NSDictionary *rectDict = tempObj[@"coords"][nodeMap];
                NSRect rect = NSMakeRect([rectDict[@"x"] floatValue], [rectDict[@"y"] floatValue],
                                         [rectDict[@"w"] floatValue], [rectDict[@"h"] floatValue]);
                [temp addObject:fileName];
                [temp addObject:nodeMap];
                [temp addObject:NSStringFromRect(rect)];
                [inactiveSkillSprites addObject:temp];
            }
        }
    }
    [dictionary setValue:inactiveSkillSprites forKey:@"inactiveSkillSprites"];
    
//    
//    for (NSString *dataInfo in objects[@"skillSprites"]) {
//        if ([dataInfo containsString:@"inactive" options:NSCaseInsensitiveSearch]) {
//            NSDictionary *tempObj = objects[@"skillSprites"][dataInfo][3];
//            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
//            NSRect rect = NSMakeRect([tempObj[@"x"] floatValue], [tempObj[@"y"] floatValue],
//                                     [tempObj[@"w"] floatValue], [tempObj[@"h"] floatValue]);
//            [temp setValue:[NSValue valueWithRect:rect] forKey:tempObj[@"filename"]];
//            [inactiveSkillSprites setValue:temp forKey:dataInfo];
//        }
//        
//    }
//    [dictionary setValue:inactiveSkillSprites forKey:@"inactiveSkillSprites"];
    
    return dictionary;
}

-(NSDictionary *)getAssetInfo {
    NSLog(@"Constructing asset info...");
    NSMutableDictionary *assets = [[NSMutableDictionary alloc] init];
    for (NSString *asset in [objects[@"assets"] allKeys]) {
        if (objects[@"assets"][asset][@"0.3835"]) {
            [assets setValue:objects[@"assets"][asset][@"0.3835"] forKey:asset];
        }
    }
    return assets;
}

-(NSString *) getJson {
    NSLog(@"Retrieving data from PoE website");
    NSString *dataAsString = [NSString alloc];
    
    NSURL *skillTreeUrl = [NSURL URLWithString:POETreeAddress];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:skillTreeUrl
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!data) {
        NSLog(@"Error retreiving data");
        return nil;
    }
    
    NSLog(@"Received %ld bytes", [data length]);
    
    dataAsString = [dataAsString initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:@"var passiveSkillTreeData.*"
                                  options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:dataAsString options:0 range:NSMakeRange(0, [dataAsString length])];
    
    
    jsonString = [dataAsString substringWithRange:[matches[0] range]];
    jsonString = [jsonString substringWithRange:NSMakeRange(27, ([jsonString length] - 29))];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"root" withString:@"main"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    return jsonString;
}

@end
