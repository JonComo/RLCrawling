//
//  RLNet.m
//  RLCrawling
//
//  Created by Jon Como on 12/19/15.
//  Copyright © 2015 Jon Como. All rights reserved.
//

#import "RLNet.h"

@interface RLNet ()

@property (nonatomic, strong) NSMutableArray *values, *rewards, *policy;
@property (nonatomic, assign) double gamma;

@end

@implementation RLNet

- (instancetype)initWithStates:(NSUInteger)count gamma:(double)gamma {
    if (self = [super init]) {
        // init
        self.states = count;
        self.currentState = 0;
        self.gamma = gamma;
        
        self.policy = [NSMutableArray array];
        self.values = [NSMutableArray array];
        self.rewards = [NSMutableArray array];
        
        for (int i = 0; i<count; i++) {
            [self.values addObject:@0.0];
            [self.rewards addObject:@0.0];
            
            NSMutableArray *dist = [NSMutableArray array];
            [self.policy addObject:dist];
            for (int j = 0; j<count; j++) {
                [dist addObject:@(1.0 / count)];
            }
        }
    }
    
    return self;
}

-(NSUInteger)transitionFromState:(NSUInteger)state {
    NSUInteger nextState = [self randomStateFromDist:self.policy[state]];
    
    return nextState;
}

-(void)receiveRewardObservation:(double)reward {
    self.rewards[self.currentState] = @(reward);
}

- (void)updatePolicy {
    
    for (int i = 0; i<self.states; i++) {
        self.values[i] = @([self valueOfState:i]);
    }
    
    for (int i = 0; i<self.states; i++) {
        double expsum = 0.0;
        for (int j = 0; j<self.states; j++) {
            expsum += exp([self.values[j] doubleValue]);
        }
        
        for (int j = 0; j<self.states; j++) {
            self.policy[i][j] = @(exp([self.values[j] doubleValue])/expsum);
        }
    }
}

- (NSUInteger)randomStateFromDist:(NSArray *)dist {
    double rand = (float)(arc4random()%100) / 100.f;
    double sum = 0.0;
    
    for (int i = 0; i<dist.count-1; i++) {
        NSNumber *prob = dist[i];
        sum += [prob doubleValue];
        if (sum > rand) {
            return i;
        }
    }
    
    return dist.count-1;
}

- (double)valueOfState:(NSUInteger)state {
    NSArray *dist = self.policy[state];
    double weighted_sum = 0.0;
    for (int i = 0; i<dist.count-1; i++) {
        weighted_sum += [self.values[i] doubleValue] * [dist[i] doubleValue];
    }
    
    return [self.rewards[state] doubleValue] + self.gamma * weighted_sum;
}

- (UIImage *)renderPolicy {
    
}

@end
