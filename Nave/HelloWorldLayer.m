//
//  Created by Luis Felipe Perez on 2/11/14.
//  Copyright Dataminas Tecnologia e Sistemas 2014. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import <Social/Social.h>
#import <Twitter/TWTweetComposeViewController.h>

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

// Add to top of file
#import "CCParallaxNode-Extras.h"

#define kNumAsteroids   15
#define kNumLasers      15
#define kChickenJump    15
#define klifesNumber 3
#define kMinY 67

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer


// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) callStickRunAction{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:12];
    for (int i = 1; i < 7; i++) {
        NSString *file = [NSString stringWithFormat:@"stickman_side_%d.png", i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        [frames addObject:frame];
    }
    for (int i = 5; i > 1; i--) {
        NSString *file = [NSString stringWithFormat:@"stickman_side_%d.png", i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        [frames addObject:frame];
    }
    CCAnimation *walkAnim =[CCAnimation animationWithSpriteFrames:frames delay:0.06f];
    CCAnimate *animate = [CCAnimate actionWithAnimation:walkAnim];
    return     [CCRepeatForever actionWithAction:animate];
}

-(id) init
{
    if( (self=[super init])) {
        
        //admob
        adBanner_ = [[GADInterstitial alloc] init];
        adBanner_.adUnitID = @"ca-app-pub-2766691437061191/5289943461";
        adBanner_.delegate = self;

        //[[CCDirector sharedDirector].view addSubview:adBanner_];
        
        //app
        velocity = CGPointMake(0, -3.0f);
        
        firstTime = true;
        
        _gameEnded = NO;
        [[CCDirector sharedDirector] setDisplayStats:NO];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"stick.png"]; // 1
        [self addChild:_batchNode]; // 2
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"stick.plist"]; // 3
        
        _stick = [CCSprite spriteWithSpriteFrameName:@"stickman_side_1.png"];  // 4
        
        _stick.scale = 0.5;

        stickRunAction = [[self callStickRunAction] retain];
        [stickRunAction setTag:1];
        
        [_stick runAction:stickRunAction];
        
        CGSize winSize = [CCDirector sharedDirector].winSize; // 5
        _stick.position = ccp(winSize.width * 0.1, kMinY); // 6
        [_batchNode addChild:_stick z:1]; // 7
        
        // 1) Create the CCParallaxNode
        _backgroundNode = [CCParallaxNode node];
        [self addChild:_backgroundNode z:-2];
        
        
        _ground1 = [CCSprite spriteWithFile:@"ground.png"];
        _ground2 = [CCSprite spriteWithFile:@"ground.png"];
        
        _mountain11 = [CCSprite spriteWithFile:@"montanha1.png"];
        _mountain12 = [CCSprite spriteWithFile:@"montanha1.png"];
        
        _mountain21 = [CCSprite spriteWithFile:@"montanha2.png"];
        _mountain22 = [CCSprite spriteWithFile:@"montanha2.png"];
        
        _mountain31 = [CCSprite spriteWithFile:@"montanha3.png"];
        _mountain32 = [CCSprite spriteWithFile:@"montanha3.png"];
        
        
        // Determine relative movement speeds for space dust and background
        CGPoint mountai1Speed = ccp(0.08, 0.1);
        CGPoint mountai2Speed = ccp(0.03, 0.1);
        CGPoint mountai3Speed = ccp(0.01, 0.1);
        
        CGPoint groundSpeed = ccp(0.2, 0.1);
    
        float backgroundHeight = 0.75;
        
        //adding ground
        [_backgroundNode addChild:_ground1 z:1 parallaxRatio:groundSpeed positionOffset:ccp(0, 20)];
        [_backgroundNode addChild:_ground2 z:1 parallaxRatio:groundSpeed positionOffset:ccp(_ground1.contentSize.width,20)];
        
        //adding mountains
        [_backgroundNode addChild:_mountain11 z:-1 parallaxRatio:mountai1Speed positionOffset:ccp(0, winSize.height * backgroundHeight)];
        [_backgroundNode addChild:_mountain12 z:-1 parallaxRatio:mountai1Speed positionOffset:ccp(_mountain11.contentSize.width,winSize.height * backgroundHeight)];
        
        [_backgroundNode addChild:_mountain21 z:-2 parallaxRatio:mountai2Speed positionOffset:ccp(0, winSize.height * backgroundHeight)];
        [_backgroundNode addChild:_mountain22 z:-2 parallaxRatio:mountai2Speed positionOffset:ccp(_mountain21.contentSize.width,winSize.height * backgroundHeight)];
        
        [_backgroundNode addChild:_mountain31 z:-3 parallaxRatio:mountai3Speed positionOffset:ccp(0, winSize.height * backgroundHeight)];
        [_backgroundNode addChild:_mountain32 z:-3 parallaxRatio:mountai3Speed positionOffset:ccp(_mountain31.contentSize.width,winSize.height * backgroundHeight)];
        
        
        //adding life images
        _lifesArray = [[CCArray alloc] initWithCapacity:klifesNumber];
        for(int i = 0; i < klifesNumber; ++i) {
            CCSprite *life = [CCSprite spriteWithSpriteFrameName:@"life_icon.png"];
            life.visible = YES;
            [_batchNode addChild:life];
            [_lifesArray addObject:life];
            
            life.position = ccp(winSize.width - 30 - ( i * life.contentSize.width) - (i * 10 * 3) , winSize.height * 0.95);
            life.scale = 0.7;
        }

        // Add to end of init method
        [self scheduleUpdate];
        
        _asteroids = [[CCArray alloc] initWithCapacity:kNumAsteroids];
        for(int i = 0; i < kNumAsteroids; ++i) {
            CCSprite *asteroid = [CCSprite spriteWithSpriteFrameName:@"block.png"];
            asteroid.visible = NO;
            [_batchNode addChild:asteroid];
            [_asteroids addObject:asteroid];
        }
        
        _stickLasers = [[CCArray alloc] initWithCapacity:kNumLasers];
        for(int i = 0; i < kNumLasers; ++i) {
            CCSprite *shipLaser = [CCSprite spriteWithSpriteFrameName:@"life_icon.png"];
            shipLaser.visible = NO;
            [_batchNode addChild:shipLaser];
            [_stickLasers addObject:shipLaser];
        }
        
        self.isTouchEnabled = YES;
        
        // Add at end of init
        _lifes = klifesNumber;
        double curTime = CACurrentMediaTime();
        _gameOverTime = curTime + 200.0;
        
        //asteroids destroyeds
        _blocks = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            _blocksLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Blocks: %i", _blocks ] fntFile:@"Arial-hd.fnt"];
            _blocksLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", _blocks ] fontName:@"Arial" fontSize:50];
        } else {
            //_blocksLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Blocks: %i", _blocks ] fntFile:@"Arial.fnt"];
            _blocksLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", _blocks ] fontName:@"Arial" fontSize:50];
        }
        
//        _blocksLabel.alignment = UITextAlignmentRight;
        _blocksLabel.scale = 0.9
        ;
        _blocksLabel.position = ccp(winSize.width * 0.5, winSize.height * 0.9 - (_blocksLabel.contentSize.height / 2));
        
        
        [self addChild:_blocksLabel z:3];
        
        
        
    }
    
    return self;
}

- (void) updatelifes{
    _lifes--;
    if ( _lifes >= 0 ){
        CCSprite * life = _lifesArray.lastObject;
        life.visible = NO;
        [_lifesArray removeLastObject];
    }
}

- (void) updateAsteroidesDestroyeds{
    [_blocksLabel setString:[NSString stringWithFormat:@"%i", _blocks ]];
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}


- (void)restartTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
}

- (void)endScene:(EndReason)endReason {
   
    GADRequest *request = [GADRequest request];
    //request.testDevices = @[ @"b9a4c4edbdae59c2e49ca1b9fee97dc1" ];
    [adBanner_ loadRequest:request];
    
    if (_gameOver) return;
    _gameOver = true;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [self submitScore];
    //
    CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"you_lose.png"];
    background.position = ccp(winSize.width/2 , winSize.height/2 );
    [self addChild:background z:-1];
    
    
    CCSprite *playButton = [CCSprite spriteWithSpriteFrameName:@"play_button.png"];
    CCSprite *playButtonPressed = [CCSprite spriteWithSpriteFrameName:@"play_button_pressed.png"];
    CCMenuItemSprite *startButton = [CCMenuItemSprite itemWithNormalSprite:playButton selectedSprite:playButtonPressed target:self selector:@selector(restartTapped:)];
    startButton.position = ccp(winSize.width/2 - startButton.contentSize.width /2   , winSize.height * 0.4 );
    
    CCSprite *twitterSprite = [CCSprite spriteWithSpriteFrameName:@"twitter_button.png"];
    CCSprite *twitterSpritePressed = [CCSprite spriteWithSpriteFrameName:@"twitter_button.png"];
    CCMenuItemSprite *twitterButton = [CCMenuItemSprite itemWithNormalSprite:twitterSprite selectedSprite:twitterSpritePressed target:self selector:@selector(postToTwitter:)];
    twitterButton.position = ccp(winSize.width/2 + startButton.contentSize.width / 2 + 10 , winSize.height * 0.4 );
    
    CCSprite *leaderSprite = [CCSprite spriteWithSpriteFrameName:@"leader_button.png"];
    CCSprite *leaderSpritePressed = [CCSprite spriteWithSpriteFrameName:@"leader_button_pressed.png"];
    CCMenuItemSprite *leaderButton = [CCMenuItemSprite itemWithNormalSprite:leaderSprite selectedSprite:leaderSpritePressed target:self selector:@selector(displayLeaderBoardAction:)];
    leaderButton.position = ccp(winSize.width/2  , winSize.height * 0.5 );
    
    
    
    CCMenu *menu = [CCMenu menuWithItems:startButton, twitterButton, leaderButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [startButton runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    

    
}

// Add new update method
- (void)update:(ccTime)dt {
    
    //_stick.position = ccpAdd(_stick.position, velocity);
    
    CGPoint backgroundScrollVel = ccp(-1000, 0);
    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
    
    // Add at end of your update method
    NSArray *groundsImage = [NSArray arrayWithObjects:_ground1, _ground2, nil];
    for (CCSprite *ground in groundsImage) {
        if ([_backgroundNode convertToWorldSpace:ground.position].x < -ground.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2 * ground.contentSize.width,0) forChild:ground];
        }
    }
    
    // Add at end of your update method
    NSArray *mountains1Images = [NSArray arrayWithObjects:_mountain11, _mountain12, nil];
    for (CCSprite *mountains in mountains1Images) {
        if ([_backgroundNode convertToWorldSpace:mountains.position].x < -mountains.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2*mountains.contentSize.width,0) forChild:mountains];
        }
    }
    
    // Add at end of your update method
    NSArray *mountains2Images = [NSArray arrayWithObjects:_mountain21, _mountain22, nil];
    for (CCSprite *mountains in mountains2Images) {
        if ([_backgroundNode convertToWorldSpace:mountains.position].x < -mountains.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2*mountains.contentSize.width,0) forChild:mountains];
        }
    }
    
    // Add at end of your update method
    NSArray *mountains3Images = [NSArray arrayWithObjects:_mountain31, _mountain32, nil];
    for (CCSprite *mountains in mountains3Images) {
        if ([_backgroundNode convertToWorldSpace:mountains.position].x < -mountains.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2*mountains.contentSize.width,0) forChild:mountains];
        }
    }
    
    // 4) Add to bottom of update
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float maxY = winSize.height - _stick.contentSize.height/2;
    float minY = kMinY;
    
    float newY = _stick.position.y + (_stickPointsPerSecY * dt);

    newY = MIN(MAX(newY, minY - 15 ), maxY);
    _stick.position = ccp(_stick.position.x, newY);

    //asteroids
    double curTime = CACurrentMediaTime();
    _nextAsteroidSpawn = _nextAsteroidSpawn == 0 ? curTime + 5 : _nextAsteroidSpawn;
    if (curTime > _nextAsteroidSpawn) {

        CCSprite *asteroid = [_asteroids objectAtIndex:_nextAsteroid];
        
//        float randSecs = [self randomValueBetween: 5 andValue:3.0];
        float randSecs =  3;

        _nextAsteroidSpawn = randSecs + curTime;
        
//        float randY = [self randomValueBetween:_ground1.contentSize.height + asteroid.contentSize.height / 2 andValue:winSize.height * 0.3];
        float randY = minY;
        float randDuration = [self randomValueBetween: 0.8 andValue:3];
        

        _nextAsteroid++;
        if (_nextAsteroid >= _asteroids.count) _nextAsteroid = 0;
        
        [asteroid stopAllActions];
        asteroid.position = ccp(winSize.width + asteroid.contentSize.width / 2, randY);
        asteroid.visible = YES;
        [asteroid runAction:[CCSequence actions:
                             [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width - asteroid.contentSize.width, 0)],
                             [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                             nil]];
        
    }
    
    //collision
    if ( !_gameEnded ) {
        for (CCSprite *asteroid in _asteroids) {
            if (!asteroid.visible) continue;
            
            for (CCSprite *shipLaser in _stickLasers) {
                if (!shipLaser.visible) continue;
                
                if (CGRectIntersectsRect(shipLaser.boundingBox, asteroid.boundingBox)) {
                    shipLaser.visible = NO;
                    asteroid.visible = NO;
                    continue;
                }
            }
            
            if (CGRectIntersectsRect(_stick.boundingBox, asteroid.boundingBox)) {
                asteroid.visible = NO;
                [_stick runAction:[CCSequence actions:
                                   [CCBlink actionWithDuration:1 blinks:9],
                                   [CCCallFuncN actionWithTarget:self selector:@selector(setPlayerVisible:)],
                                   nil]];
                
                [self updatelifes];
            }
        }
    }
    // Add at end of update loop
    if (_lifes <= 0) {
        [_stick stopAllActions];
        _stick.visible = FALSE;
        [self endScene:kEndReasonLose];
        _gameEnded = YES;

    } else if (curTime >= _gameOverTime) {
        [self endScene:kEndReasonWin];
        _gameEnded = YES;
    }
    
}

// Add new method
- (void)setInvisible:(CCNode *)node {
    if ( !_gameEnded ){
        if ( node.visible == YES ){
            _blocks++;
            [self updateAsteroidesDestroyeds];
        }
    }
    node.visible = NO;
}

// Add new method
- (void)setPlayerVisible:(CCNode *)node {
    node.visible = YES;
}

-(void) restartActions{
    //stickRunAction = [self callStickRunAction];
    [_stick runAction:stickRunAction];
}

// Add new method
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( !_gameEnded ) {
        
        NSLog(@"stick: %f", _stick.position.y);
        if ( _stick.position.y >= 66 && _stick.position.y <= 68 ){
            
//            [_stick stopAllActions];
            [_stick stopActionByTag:1];
            id jumpAct = [CCJumpBy actionWithDuration:1.0f position:ccp(0, 0) height:55 jumps:1];
            id restartActions = [CCCallFunc actionWithTarget:self selector:@selector(restartActions)]; // to call our method
            [_stick runAction: [CCSequence actions:jumpAct, restartActions,nil] ];
           
        }
        
        
    }
}


- (void) dealloc {
    adBanner_.delegate = nil;
    [adBanner_ release];
    [super dealloc];
}


- (IBAction)postToTwitter:(id)sender {
    
    AppController * app = (((AppController*) [UIApplication sharedApplication].delegate));
    
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    [tweetViewController setInitialText:[NSString stringWithFormat:@"I made %i points playing #jumpyStick for iOS http://bit.ly/1lv7Qhx", _blocks]];
    
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            {
                if (result == TWTweetComposeViewControllerResultDone)
                {
                    //successful
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PPTweetSuccessful" object:nil];
                    
                }
                else if(result == TWTweetComposeViewControllerResultCancelled)
                {
                    //Cancelled
                }
            }
            
            [app.navController dismissModalViewControllerAnimated:YES];
            
            [tweetViewController release];
        });
        
    }];
    
    [app.navController presentModalViewController:tweetViewController animated:YES];
}




-(void)submitScore{
    if (_blocks>0) {
        
        GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:@"topscores"] autorelease];
        
        scoreReporter.value = [[NSNumber numberWithInt:_blocks] longLongValue];
        NSLog(@"posted");
        NSLog(@"%i",_blocks);
        
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                NSLog(@"failed!!!");
                NSLog(@"%i",_blocks);
            }
            else{
                NSLog(@"Succeded");
                
            }
        }];}
}

- (IBAction) displayLeaderBoardAction: (id) sender{
    [self displayLeaderBoard:@"topscores"];
}

-(void)displayLeaderBoard:(NSString *)name
{
    AppController * app = (((AppController*) [UIApplication sharedApplication].delegate));
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != NULL)
    {
        if (name != nil) {//keep category nil and let user see default
            leaderboardController.category = name;
        }
        leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardController.leaderboardDelegate = self;
        [app.navController presentModalViewController: leaderboardController animated: YES];
    }
    
    [leaderboardController release];
    
}

#pragma admob

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"admob");
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [adBanner_ presentFromRootViewController:[app navController]];
}
#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
