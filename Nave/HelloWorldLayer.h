//
//  HelloWorldLayer.h
//  Nave
//
//  Created by Luis Felipe Perez on 2/11/14.
//  Copyright Dataminas Tecnologia e Sistemas 2014. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "GADInterstitial.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

typedef enum {
    kEndReasonWin,
    kEndReasonLose
} EndReason;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GADInterstitialDelegate>
{
    
    GADInterstitial *adBanner_;
    
    id stickRunAction;
    id stickJumpAction;
    
    bool firstTime;
    
    CCSpriteBatchNode *_batchNode;
    CCSprite *_stick;
    CCParallaxNode *_backgroundNode;
    
    CCSprite *_ground1;
    CCSprite *_ground2;
    
    CCSprite *_mountain11;
    CCSprite *_mountain12;
    
    CCSprite *_mountain21;
    CCSprite *_mountain22;
    
    CCSprite *_mountain31;
    CCSprite *_mountain32;
    
    CGPoint velocity;
    
    CGPoint newPosition;

    float _stickPointsPerSecY;
    CCArray *_asteroids;
    CCArray *_lifesArray;
    
    int _nextAsteroid;
    double _nextAsteroidSpawn;
    
    CCArray *_stickLasers;
    int _nextShipLaser;
    
    int _lifes;
    
    CCLabelTTF *_blocksLabel;
    
    int _blocks;

    // Add inside @interface
    double _gameOverTime;
    bool _gameOver;
    
    bool _gameEnded;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
@property (nonatomic, retain) id stickRunAction;

@end
