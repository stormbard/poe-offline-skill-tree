//
//  Build.m
//  POEOfflineSkillTree
//
//  Created by Eric Bunton on 12/31/12.
//  Copyright (c) 2012 Eric Bunton. All rights reserved.
//

#import "Build.h"
#import "SkillNode.h"


@implementation Build

@dynamic buildUrl;
@dynamic level;
@dynamic name;
@dynamic activeNodes;

-(void)awakeFromFetch {
    //Calculate attributes
}

-(NSArray *)decodeURL {
    NSLog(@"Parsing url: %@ for build %@", [self buildUrl], [self name]);
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    
    NSString *build = [[[[self buildUrl] substringFromIndex:[POETreeAddress length]]
                        stringByReplacingOccurrencesOfString:@"-" withString:@"+"]
                       stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSLog(@"Build Data String: %@", build);
    NSData *decoded = [build base64DecodedData];
    
    unsigned char *array = (unsigned char *)[decoded bytes];
    
    int charType = ((int)array[4]);
    switch (charType) {
        case 1:
            //mara
            NSLog(@"Marauder");
            [nodes addObject:@"MARAUDER"];
            break;
        case 2:
            //ranger
            NSLog(@"Ranger");
            [nodes addObject:@"RANGER"];
            break;
        case 3:
            //witch
            NSLog(@"Witch");
            [nodes addObject:@"WITCH"];
            break;
        case 4:
            //duelist
            NSLog(@"Duelist");
            [nodes addObject:@"DUELIST"];
            break;
        case 5:
            //templar
            NSLog(@"Templar");
            [nodes addObject:@"TEMPLAR"];
            break;
        case 6:
            //shdow/six
            NSLog(@"Shadow/Six");
            [nodes addObject:@"SIX"];
            break;
        default:
            NSLog(@"Shits fucked up");
            break;
    }
    
    NSLog(@"Decoding skill nodes... %ld", [decoded length]);
    for (int ndx = 6; ndx < [decoded length]; ndx+=2) {
        unsigned char myInt[] = {array[ndx], array[ndx + 1]};
        unsigned short skillId = [Build toInt16:myInt];
        NSLog(@"Adding skill node: %hu", skillId);
        [nodes addObject:[NSNumber numberWithUnsignedShort:skillId]];
    }
    NSLog(@"Now printing skill nodes in build %lu", [nodes count]);
    for (NSNumber *skill in nodes) {
        NSLog(@"%@", skill);
    }
    NSLog(@"Build Parsed");
    return nodes;
}

-(void)encodeURL {
    
}

/*
 Little Endian, most significant bit is the second
 */
+(unsigned short)toInt16:(unsigned char[])bytes {
    return (unsigned short)(bytes[0] << 8 | bytes[1]);
}




@end
