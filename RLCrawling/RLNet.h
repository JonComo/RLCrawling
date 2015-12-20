//
//  RLNet.h
//  RLCrawling
//
//  Created by Jon Como on 12/19/15.
//  Copyright © 2015 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLNet : NSObject

@property (nonatomic, assign) NSUInteger states;
@property (nonatomic, assign) NSUInteger currentState;

- (instancetype)initWithStates:(NSUInteger)count gamma:(double)gamma;

- (NSUInteger)transitionFromState:(NSUInteger)state;
- (void)receiveRewardObservation:(double)reward;
- (void)updatePolicy;

- (UIImage *)renderPolicy;

@end
