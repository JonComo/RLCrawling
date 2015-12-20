//
//  ViewController.m
//  RLCrawling
//
//  Created by Jon Como on 12/19/15.
//  Copyright © 2015 Jon Como. All rights reserved.
//

#import "ViewController.h"

#import "RLNet.h"

@import SpriteKit;

@interface ViewController ()

@property (nonatomic, strong) SKScene *scene;

@property (nonatomic, strong) SKSpriteNode *body, *armA, *armB;
@property (nonatomic, strong) SKPhysicsJointPin *pinA, *pinB;

@property (nonatomic, assign) CGFloat targetRotA, targetRotB;

@property (nonatomic, strong) RLNet *net;
@property (nonatomic, assign) CGFloat lastXPos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.net = [[RLNet alloc] initWithStates:16 gamma:.75];
    
    SKView *view = [[SKView alloc] initWithFrame:self.view.bounds];
    self.scene = [[SKScene alloc] initWithSize:self.view.bounds.size];
    self.scene.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    [view presentScene:self.scene];
    
    SKSpriteNode *ground = [self boxAtPosition:CGPointMake(self.scene.size.width/2.f, 120.f) size:CGSizeMake(self.scene.size.width, 10.f)];
    ground.physicsBody.dynamic = NO;
    [self.scene addChild:ground];
    
    CGPoint startPoint = CGPointMake(self.scene.size.width/2.f, self.scene.size.height/2.f);
    
    CGSize bodySize = CGSizeMake(60, 40);
    CGSize armSizeA = CGSizeMake(60, 4);
    CGSize armSizeB = CGSizeMake(30, 4);
    
    self.body = [self boxAtPosition:startPoint size:bodySize];
    self.body.color = [UIColor colorWithRed:.3 green:.2 blue:.8 alpha:1.0];
    self.body.physicsBody.friction = .01f;
    [self.scene addChild:self.body];
    
    self.armA = [self boxAtPosition:CGPointMake(startPoint.x - armSizeA.width, startPoint.y + bodySize.height/2.f) size:armSizeA];
    self.armA.color = [UIColor colorWithRed:.8 green:.2 blue:.2 alpha:1.0];
    [self.scene addChild:self.armA];
    
    self.pinA = [SKPhysicsJointPin jointWithBodyA:self.body.physicsBody bodyB:self.armA.physicsBody anchor:CGPointMake(self.armA.position.x + armSizeA.width/2.f, self.armA.position.y)];
    self.pinA.frictionTorque = 1.f;
    self.pinA.lowerAngleLimit = -0.7;
    self.pinA.upperAngleLimit = 0.7;
    [self.scene.physicsWorld addJoint:self.pinA];
    
    self.armB = [self boxAtPosition:CGPointMake(self.armA.position.x - armSizeA.width/2.f - armSizeB.width/2.f, startPoint.y + bodySize.height/2.f) size:armSizeB];
    self.armB.color = [UIColor colorWithRed:.4 green:.2 blue:.6 alpha:1.0];
    self.armB.physicsBody.friction = 1.0;
    [self.scene addChild:self.armB];
    
    self.pinB = [SKPhysicsJointPin jointWithBodyA:self.armA.physicsBody bodyB:self.armB.physicsBody anchor:CGPointMake(self.armB.position.x + armSizeB.width/2.f, self.armB.position.y)];
    self.pinB.frictionTorque = 1.f;
    [self.scene.physicsWorld addJoint:self.pinB];
    
    NSTimer *runTimer;
    runTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(loop) userInfo:nil repeats:YES];
    
    // Reward
    self.lastXPos = startPoint.x;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTransitionToState:(NSUInteger)state {
    CGFloat rotA = M_PI / 15.f;
    CGFloat rotB = M_PI / 6.f;
    self.targetRotA = (state % 4) * rotA;
    self.targetRotB = (state / 4) * rotB + rotB;
}

- (void)loop {
    static int clock = 0;
    static int transition = 0;
    
    clock += 1;
    if (clock > transition) {
        transition += 10;
        
        double reward = self.lastXPos - self.body.position.x;
        NSLog(@"Reward: %f", reward);
        [self.net receiveRewardObservation:reward];
        [self.net updatePolicy];
        self.lastXPos = self.body.position.x;
        
        self.net.currentState = [self.net transitionFromState:self.net.currentState];
//        self.net.currentState += 1;
//        if (self.net.currentState > 16) {
//            self.net.currentState = 0;
//        }
        [self didTransitionToState:self.net.currentState];
    }
    
    
    CGFloat speed = 1.0f;
    CGFloat padding = .1f;
    
    if (self.armA.zRotation < self.targetRotA - padding) {
        self.pinA.rotationSpeed = speed;
    } else if (self.armA.zRotation > self.targetRotA + padding) {
        self.pinA.rotationSpeed = -speed;
    } else {
        self.pinA.rotationSpeed = 0.f;
    }
    
    if (self.armB.zRotation - self.armA.zRotation < self.targetRotB - padding) {
        self.pinB.rotationSpeed = speed;
    } else if (self.armB.zRotation - self.armA.zRotation > self.targetRotB + padding) {
        self.pinB.rotationSpeed = -speed;
    } else {
        self.pinB.rotationSpeed = 0.f;
    }
}

- (SKSpriteNode *)boxAtPosition:(CGPoint)position size:(CGSize)size {
    SKSpriteNode *box = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size:size];
    box.position = position;
    box.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    return box;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /*
    CGPoint point = [[touches anyObject] locationInNode:self.scene];
    if (point.y < self.scene.size.height/2.f) {
        if (point.x < self.scene.size.width/2.f) {
            self.targetRotA += .2f;
        } else {
            self.targetRotA -= .2f;
        }
    } else {
        if (point.x < self.scene.size.width/2.f) {
            self.targetRotB += .2f;
        } else {
            self.targetRotB -= .2f;
        }
    } */
}

@end
