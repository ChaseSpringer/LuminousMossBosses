//
//  ServerAPI.h
//  DeveloperBuild
//
//  Created by Jamie Frampton Miller on 3/17/15.
//  Copyright (c) 2015 CU Boulder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ServerAPI : NSObject
+ (BOOL) uploadObservation:(NSString*)assetFileName date:(NSString*) date time:(NSString*) time lat:(float) lat lng:(float) lng locationerror:(float) locationerror image:(UIImage*) image;
@end
