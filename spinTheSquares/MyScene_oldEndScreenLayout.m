//
//  MyScene.m
//  dumpTruck
//
//  Created by Rijul Gupta on 4/9/14.
//  Copyright (c) 2014 Rijul Gupta. All rights reserved.
//

#import "MyScene.h"
#define   IsIphone5     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


static const uint32_t truckCategory     =  1 << 1;
static const uint32_t floorCategory     =  1 << 2;
static const uint32_t lawnCategory     =  1 << 3;
static const uint32_t dividerCategory     =  1 << 4;
static const uint32_t garbageBagCategory     =  1 << 5;
static const uint32_t carCategory     =  1 << 6;
static const uint32_t fakeSquareCategory     =  1 << 7;

@interface MyScene () <SKPhysicsContactDelegate>


@property (nonatomic) SKSpriteNode * dumpTruck;
@property (nonatomic) SKSpriteNode * fakeSquare;

@property (nonatomic) NSMutableArray * bagArray;

@property (nonatomic) NSMutableArray * obstacleArray;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastSpawnTimeIntervalEgg;
@property (nonatomic) NSTimeInterval lastSpawnTimeIntervalPoop;
@property (nonatomic) NSTimeInterval lastSpawnTimeIntervalTree;

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;


@property (nonatomic) SKSpriteNode * gameOverOverlay;

@property int sizeChanger;
@property double spinChanger;

@property BOOL gameIsOver;

@property (nonatomic) UIColor *truckColor;
@property (nonatomic) UIColor *bagColor;
@property (nonatomic) UIColor *obstacleColor;
@property (nonatomic) UIColor *backColor;


@property BOOL canMultiplyPoints;
@property (nonatomic) NSNumber *pointMultiplyer;
@property int xTouchInput;

@property BOOL gameHasStarted;
@end

@implementation MyScene
@synthesize currentLeaderBoard;


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        _gameHasStarted = false;
        [self setupGame];
        
    }
    return self;
}

-(void)setupGame{
    
    _gameIsOver = false;
    _sizeChanger = round(self.size.width/320);
    
    self.physicsWorld.gravity = CGVectorMake(0, -10*_sizeChanger);
    
    self.physicsWorld.contactDelegate = self;
    
    
    _globalFriction = 20.0;
    _globalLinearDamping = 6;
    _sideSize = 60;
    _spinChanger = 1;
    _score = 0;
    _xTouchInput = 0;
    _positionSize = round((self.size.width)/3.0);
    
    
    // _leftLawnArray = [[NSMutableArray alloc] init];
    // _rightLawnArray = [[NSMutableArray alloc] init];
    _bagArray = [[NSMutableArray alloc] init];
    
    _obstacleArray = [[NSMutableArray alloc] init];
    
    
    
    _dumpTruck = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake((80*_sizeChanger), 80*_sizeChanger)];
    self.dumpTruck.position = CGPointMake(120, 120*_sizeChanger);
    _dumpTruck.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_dumpTruck.size]; // 1
    _dumpTruck.physicsBody.dynamic = NO;
    _dumpTruck.physicsBody.categoryBitMask = truckCategory;
    _dumpTruck.physicsBody.contactTestBitMask = garbageBagCategory | carCategory;
    _dumpTruck.physicsBody.collisionBitMask = garbageBagCategory | carCategory;
    
    
    [self addChild:_dumpTruck];
    _dumpTruck.zPosition = 5;
    
    
    
    
    _fakeSquare = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake((125*_sizeChanger), 125*_sizeChanger)];
    _fakeSquare.position = CGPointMake(220, self.size.height + _fakeSquare.size.height);
    _fakeSquare.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_dumpTruck.size]; // 1
    _fakeSquare.physicsBody.dynamic = NO;
    _fakeSquare.physicsBody.categoryBitMask = fakeSquareCategory;
    _fakeSquare.physicsBody.contactTestBitMask = carCategory;
    _fakeSquare.physicsBody.collisionBitMask = carCategory;
    
    
    [self addChild:_fakeSquare];
    _fakeSquare.zPosition = 5;
    
    
    SKSpriteNode * floor = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(400, 25)];
    floor.position = CGPointMake(140, -200);
    floor.name = @"floorNode";
    floor.zPosition = 1;
    // floor.physicsBody.dynamic = NO;
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.categoryBitMask = floorCategory;
    floor.physicsBody.contactTestBitMask = lawnCategory | dividerCategory;
    floor.physicsBody.collisionBitMask = lawnCategory | dividerCategory;
    [self addChild:floor];
    
    
    
 
    
    
    adMobinterstitial_ = [[GADInterstitial alloc] init];
    
    adMobinterstitial_.adUnitID = @"ca-app-pub-4658531991803126/9744176090";
    [adMobinterstitial_ setDelegate:self];
    
    _canMultiplyPoints = FALSE;
    
    
    _pointMultiplyer = [[NSUserDefaults standardUserDefaults] objectForKey:@"pointMultiplyer"];
    
    if([_pointMultiplyer intValue] <= 1){
        _pointMultiplyer = [NSNumber numberWithInt:1];
        [[NSUserDefaults standardUserDefaults] setObject:_pointMultiplyer forKey:@"pointMultiplyer"];
    }
    
   // [self runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"backgroundTheme3.mp3" waitForCompletion:NO]]];

    
    
    [self addLawns];
    //  [self addLineDividers];
    
    [self runTruck:1];
    [self setColor];
    
    [self spinSquare];
  //  [self updateScoreLabel:0];
    
    NSError *error;
    
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"backgroundTheme3" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    self.backgroundMusicPlayer.volume = 0.15;
    [self.backgroundMusicPlayer play];
    
    
    if(self.size.width == 320 && self.size.height == 480){
    SKSpriteNode *instructions = [SKSpriteNode spriteNodeWithImageNamed:@"instructions_66.png"];
    instructions.size = self.size;
    instructions.position = CGPointMake(self.size.width/2, self.size.height/2);
    instructions.zPosition = 1000;
        instructions.name = @"instructionsNode";
    [self addChild:instructions];
    }
    else if (self.size.width == 320 && self.size.height == 568){
        SKSpriteNode *instructions = [SKSpriteNode spriteNodeWithImageNamed:@"instructions_56.png"];
        instructions.size = self.size;
        instructions.position = CGPointMake(self.size.width/2, self.size.height/2);
        instructions.zPosition = 1000;
        instructions.name = @"instructionsNode";
        [self addChild:instructions];
    }
    else if (self.size.width == 768 && self.size.height == 1024){
        SKSpriteNode *instructions = [SKSpriteNode spriteNodeWithImageNamed:@"instructions_75.png"];
        instructions.size = self.size;
        instructions.position = CGPointMake(self.size.width/2, self.size.height/2);
        instructions.zPosition = 1000;
        instructions.name = @"instructionsNode";
        [self addChild:instructions];
    }
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Main Gameplay View Started"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    
    
    NSDate *WaysAgo = [[NSDate date] dateByAddingTimeInterval: -86400.0*30];//one month ago
    
    [[NSUserDefaults standardUserDefaults] setObject:WaysAgo forKey:@"lastTimeSharedForIncrease"];

    
    
}

-(void)removeInstructions{
    _gameHasStarted = TRUE;
    
    SKSpriteNode *instructions = (SKSpriteNode *)[self childNodeWithName:@"instructionsNode"];
    SKAction *quickFade = [SKAction fadeAlphaTo:0 duration:0.1];
    
    [instructions runAction:quickFade completion:^{
        [instructions removeFromParent];
    }];
    self.backgroundMusicPlayer.volume = 0.0;

    
    [self addLawns];
    //  [self addLineDividers];
    
    [self runTruck:1];
    [self setColor];
    
    [self spinSquare];
    [self updateScoreLabel:0];
    [self moveFakeSquare];
    
    
}

-(void)addLawns{
    
    
    if(_gameIsOver == false && _gameHasStarted == TRUE){
     //   int maxCount = 10;
     //   int maxVel = -100;
        
        
        CGVector velocity = CGVectorMake(0, -1);
        
        if(_bagArray.count > 0){
            SKSpriteNode *testNode = [_bagArray objectAtIndex:(_bagArray.count - 1)];
            velocity = testNode.physicsBody.velocity;
        }
        
        //if(arc4random()%(10 + _score) != -1)
        SKSpriteNode * bag = [SKSpriteNode spriteNodeWithColor:_bagColor size:CGSizeMake(57*_sizeChanger, 57*_sizeChanger)];
        bag.position = CGPointMake(bag.size.width/2*_sizeChanger, -bag.size.height*_sizeChanger);
        //bag.color = [UIColor blackColor];
        [self addChild:bag];
        [_bagArray addObject:bag];
        
        bag.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bag.size];
        bag.physicsBody.categoryBitMask = garbageBagCategory;
        bag.physicsBody.collisionBitMask = truckCategory;
        bag.physicsBody.dynamic = YES;
        bag.physicsBody.velocity = velocity;
        bag.physicsBody.friction = _globalFriction;
        bag.physicsBody.linearDamping = _globalLinearDamping;
        
        
        int num = arc4random()%2;
        
        if(num == 0) bag.position = CGPointMake((_positionSize/2 - 0*bag.size.width*_sizeChanger/2), 600*_sizeChanger);
        else  bag.position = CGPointMake((self.size.width - (_positionSize/2 - 0*bag.size.width*_sizeChanger/2)), 600*_sizeChanger);
        
    }
    
    
    
    
}


-(void)addCar{
    
    
    
    if(_gameIsOver == false && _gameHasStarted == TRUE){

        

        int posSize = round(self.size.width/(40*_sizeChanger));

        for (int i = 0 ; i < posSize; i++) {
        
            int pointMult = [_pointMultiplyer integerValue];
            int checkNum = (11 - floor(_score/(40.0*pointMult))); //max at 400
            if(checkNum <=1) checkNum = 1;
            //checkNum = 1;
            int chanceToAddSquare = arc4random()%checkNum;
            if(chanceToAddSquare == 0){
        
        

                SKSpriteNode * car1Node = [SKSpriteNode spriteNodeWithColor:_obstacleColor size:CGSizeMake(40*_sizeChanger, 40*_sizeChanger)];
        
        CGVector velocity = CGVectorMake(0, -1);
        
        if(_bagArray.count > 0){
            SKSpriteNode *testNode = [_bagArray objectAtIndex:(_bagArray.count - 1)];
            velocity = testNode.physicsBody.velocity;
        }
        
        
        
        
        
        car1Node.zPosition = 10;
        [self addChild:car1Node];
        [_obstacleArray addObject:car1Node];
        
        car1Node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:car1Node.size];
        car1Node.physicsBody.categoryBitMask = carCategory;
        car1Node.physicsBody.collisionBitMask = truckCategory;
        car1Node.physicsBody.dynamic = YES;
        car1Node.physicsBody.velocity = velocity;
        car1Node.physicsBody.friction = _globalFriction;
        
        double dampChanger = (arc4random()%20-10.0)/20.0;
        car1Node.physicsBody.linearDamping = _globalLinearDamping +dampChanger*0;
        
    //    int number = (_positionSize)/2;
        
      //  int position = arc4random()%6;
   //     int leftVRight = -car1Node.size.width/2 + (position%2)*car1Node.size.width;

                int rand = i;//= arc4random()%posSize;
        
        //    rand = i;
        //car1Node.position = CGPointMake((_positionSize - 20)*(position - 1) + number, 550*_sizeChanger);
      //  car1Node.position = CGPointMake(_positionSize*floor(position/2) + number + leftVRight, 600*_sizeChanger);
        car1Node.position = CGPointMake(rand*car1Node.frame.size.width + car1Node.frame.size.width/2, 700*_sizeChanger);
            }

    }
    }
}

-(void)moveFakeSquare{
    
    
    if(_gameIsOver == false && _gameHasStarted == true){
    int xPos = (arc4random()%28 + 2)*10;
    double duration = (arc4random()%10 + 1)/15.0;
    SKAction *moveSquare = [SKAction moveToX:xPos duration:duration];
    
    [_fakeSquare runAction:moveSquare completion:^{
        [self moveFakeSquare];
    }];
    }
    
}

-(void)runTruck:(int)position{
    
    if(_gameIsOver == false && _gameHasStarted == TRUE){
        double duration = 0.05;

        
        
        int number = _positionSize/2;// round((_positionSize - _dumpTruck.size.width)/2.0);
        SKAction *runTruck = [SKAction moveTo:CGPointMake(_positionSize*(position - 1) + number, _dumpTruck.position.y) duration:duration];
        
        [_dumpTruck runAction:runTruck];
    }
}


-(void)setColor{
    
    _truckColor = [self colorWithHexString:@"3FFF39"];
    _bagColor = [self colorWithHexString:@"B27812"];
    _obstacleColor = [self colorWithHexString:@"FFA300"];
    _backColor = [self colorWithHexString:@"8314CC"];
    
    int num = arc4random()%31;
    
    if(num == 1){
        
        _truckColor = [self colorWithHexString:@"47BEFF"];
        _bagColor = [self colorWithHexString:@"B2AE12"];
        _obstacleColor = [self colorWithHexString:@"FFF800"];
        _backColor = [self colorWithHexString:@"CC1420"];
        
    }
    if(num == 2){
        
        _truckColor = [self colorWithHexString:@"4D4CFF"];
        _bagColor = [self colorWithHexString:@"36B212"];
        _obstacleColor = [self colorWithHexString:@"39FF00"];
        _backColor = [self colorWithHexString:@"CC5414"];
        
    }
    if(num == 3){
        
        _truckColor = [self colorWithHexString:@"CA4CFF"];
        _bagColor = [self colorWithHexString:@"34B279"];
        _obstacleColor = [self colorWithHexString:@"00FF8A"];
        _backColor = [self colorWithHexString:@"CC9014"];
        
    }
    if(num == 4){
        
        _truckColor = [self colorWithHexString:@"FF2DB8"];
        _bagColor = [self colorWithHexString:@"34AEB2"];
        _obstacleColor = [self colorWithHexString:@"00F5FF"];
        _backColor = [self colorWithHexString:@"CCB114"];
        
    }
    if(num == 5){
        
        _truckColor = [self colorWithHexString:@"FF482D"];
        _bagColor = [self colorWithHexString:@"4A72B2"];
        _obstacleColor = [self colorWithHexString:@"0062FF"];
        _backColor = [self colorWithHexString:@"9DCC14"];
        
    }
    if(num == 6){
        
        _truckColor = [self colorWithHexString:@"FF8834"];
        _bagColor = [self colorWithHexString:@"5D4FB2"];
        _obstacleColor = [self colorWithHexString:@"2A06FF"];
        _backColor = [self colorWithHexString:@"22CC1A"];
        
    }
    if(num == 7){
        
        _truckColor = [self colorWithHexString:@"FF5460"];
        _bagColor = [self colorWithHexString:@"75B08A"];
        _obstacleColor = [self colorWithHexString:@"22475E"];
        _backColor = [self colorWithHexString:@"F0E797"];
        
    }
    if(num == 8){
        
        _truckColor = [self colorWithHexString:@"8E2800"];
        _bagColor = [self colorWithHexString:@"FFB03B"];
        _obstacleColor = [self colorWithHexString:@"468966"];
        _backColor = [self colorWithHexString:@"FFF0A5"];
        
    }
    if(num == 9){
        
        _truckColor = [self colorWithHexString:@"193441"];
        _bagColor = [self colorWithHexString:@"91AA9D"];
        _obstacleColor = [self colorWithHexString:@"D1DBBD"];
        _backColor = [self colorWithHexString:@"FCFFF5"];
        
    }
    if(num == 10){
        
        _truckColor = [self colorWithHexString:@"B9121B"];
        _bagColor = [self colorWithHexString:@"4C1B1B"];
        _obstacleColor = [self colorWithHexString:@"BD8D46"];
        _backColor = [self colorWithHexString:@"F6E497"];
        
    }
    if(num == 11){
        
        _truckColor = [self colorWithHexString:@"D90000"];
        _bagColor = [self colorWithHexString:@"FF8C00"];
        _obstacleColor = [self colorWithHexString:@"04756F"];
        _backColor = [self colorWithHexString:@"2E0927"];
        
    }
    if(num == 12){
        
        _truckColor = [self colorWithHexString:@"3E454C"];
        _bagColor = [self colorWithHexString:@"7ECEFD"];
        _obstacleColor = [self colorWithHexString:@"FFF6E5"];
        _backColor = [self colorWithHexString:@"FF7F66"];
        
    }
    if(num == 13){
        
        _truckColor = [self colorWithHexString:@"354242"];
        _bagColor = [self colorWithHexString:@"FFFF9D"];
        _obstacleColor = [self colorWithHexString:@"C9DE55"];
        _backColor = [self colorWithHexString:@"7D9100"];
        
    }
    if(num == 14){
        
        _truckColor = [self colorWithHexString:@"5A1F00"];
        _bagColor = [self colorWithHexString:@"D1570D"];
        _obstacleColor = [self colorWithHexString:@"477725"];
        _backColor = [self colorWithHexString:@"A9CC66"];
        
    }
    if(num == 15){
        
        _truckColor = [self colorWithHexString:@"FF8000"];
        _bagColor = [self colorWithHexString:@"FFD933"];
        _obstacleColor = [self colorWithHexString:@"8FB359"];
        _backColor = [self colorWithHexString:@"192B33"];
        
    }
    if(num == 16){
        
        _truckColor = [self colorWithHexString:@"52656B"];
        _bagColor = [self colorWithHexString:@"FF3B77"];
        _obstacleColor = [self colorWithHexString:@"CDFF00"];
        _backColor = [self colorWithHexString:@"B8B89F"];
        
    }
    if(num == 17){
        
        _truckColor = [self colorWithHexString:@"730046"];
        _bagColor = [self colorWithHexString:@"BFBB11"];
        _obstacleColor = [self colorWithHexString:@"E88801"];
        _backColor = [self colorWithHexString:@"C93C00"];
        
    }
    if(num == 18){
        
        _truckColor = [self colorWithHexString:@"ADD5F7"];
        _bagColor = [self colorWithHexString:@"4E7AC7"];
        _obstacleColor = [self colorWithHexString:@"35478C"];
        _backColor = [self colorWithHexString:@"16193B"];
        
    }
    if(num == 19){
        
        _truckColor = [self colorWithHexString:@"E5B96F"];
        _bagColor = [self colorWithHexString:@"F2D99C"];
        _obstacleColor = [self colorWithHexString:@"CC2738"];
        _backColor = [self colorWithHexString:@"690011"];
        
    }
    if(num == 20){
        
        _truckColor = [self colorWithHexString:@"9768D1"];
        _bagColor = [self colorWithHexString:@"553285"];
        _obstacleColor = [self colorWithHexString:@"36175E"];
        _backColor = [self colorWithHexString:@"25064D"];
        
    }
    if(num == 21){
        
        _truckColor = [self colorWithHexString:@"D6655A"];
        _bagColor = [self colorWithHexString:@"DC9C76"];
        _obstacleColor = [self colorWithHexString:@"D6CCAD"];
        _backColor = [self colorWithHexString:@"42282F"];
        
    }
    if(num == 22){
        
        _truckColor = [self colorWithHexString:@"FFD462"];
        _bagColor = [self colorWithHexString:@"FC7D49"];
        _obstacleColor = [self colorWithHexString:@"CF423C"];
        _backColor = [self colorWithHexString:@"3F0B1B"];
        
    }
    if(num == 23){
        
        _truckColor = [self colorWithHexString:@"282E33"];
        _bagColor = [self colorWithHexString:@"164852"];
        _obstacleColor = [self colorWithHexString:@"495E67"];
        _backColor = [self colorWithHexString:@"FF3838"];
        
    }
    if(num == 24){
        
        _truckColor = [self colorWithHexString:@"E6DD00"];
        _bagColor = [self colorWithHexString:@"8CB302"];
        _obstacleColor = [self colorWithHexString:@"008C74"];
        _backColor = [self colorWithHexString:@"004C66"];
        
    }
    if(num == 25){
        
        _truckColor = [self colorWithHexString:@"092140"];
        _bagColor = [self colorWithHexString:@"024959"];
        _obstacleColor = [self colorWithHexString:@"F2C777"];
        _backColor = [self colorWithHexString:@"F24738"];
        
    }
    if(num == 26){
        
        _truckColor = [self colorWithHexString:@"3CBAC8"];
        _bagColor = [self colorWithHexString:@"93EDD4"];
        _obstacleColor = [self colorWithHexString:@"F9CB8F"];
        _backColor = [self colorWithHexString:@"F19181"];
        
    }
    if(num == 27){
        
        _truckColor = [self colorWithHexString:@"C98B2F"];
        _bagColor = [self colorWithHexString:@"803C27"];
        _obstacleColor = [self colorWithHexString:@"C56520"];
        _backColor = [self colorWithHexString:@"E1B41B"];
        
    }
    if(num == 28){
        
        _truckColor = [self colorWithHexString:@"BF0404"];
        _bagColor = [self colorWithHexString:@"8C0303"];
        _obstacleColor = [self colorWithHexString:@"590202"];
        _backColor = [self colorWithHexString:@"400101"];
        
    }
    if(num == 29){
        
        _truckColor = [self colorWithHexString:@"302B2F"];
        _bagColor = [self colorWithHexString:@"FFD596"];
        _obstacleColor = [self colorWithHexString:@"FFA600"];
        _backColor = [self colorWithHexString:@"696153"];
        
    }
    if(num == 30){
        
        _truckColor = [self colorWithHexString:@"00717D"];
        _bagColor = [self colorWithHexString:@"F2D8A7"];
        _obstacleColor = [self colorWithHexString:@"A4A66A"];
        _backColor = [self colorWithHexString:@"003647"];
        
    }
    
    
    _obstacleColor = [UIColor whiteColor];
    
    for (int i = 0; i < _bagArray.count; i++) {
        [[_bagArray objectAtIndex:i] setColor:_bagColor];
    }
    for (int j = 0; j < _obstacleArray.count; j++) {
        [[_obstacleArray objectAtIndex:j] setColor:_obstacleColor];
    }
    
    
    [_dumpTruck setColor:_truckColor];
    [self setBackgroundColor:_backColor];
    

    
    // SKLabelNode *scoreLabel = (SKLabelNode *)[self childNodeWithName:@"scoreLabelName"];
    
    // [scoreLabel setColor:_backColor];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



-(void)spinSquare{
    double angle = (1)*M_1_PI;//180 degrees
    double duration = 0.5 - _spinChanger*0.05;
    if(duration <= 0) duration = 0.01;
    
    // duration = 0.01;
    
    SKAction *rotate = [SKAction rotateByAngle:angle duration:duration];
    
    
    [_dumpTruck runAction:rotate completion:^{
        if(_spinChanger > 1) _spinChanger = _spinChanger - 0.1;
        [self spinSquare];
    }];
}


-(void)spinSmallSquare:(SKNode *)node{
   // [self runAction:[SKAction playSoundFileNamed:@"squareHit.mp3" waitForCompletion:NO]];
    [self runAction:[SKAction playSoundFileNamed:@"sfx.wav" waitForCompletion:NO]];

    double angle = (1)*M_1_PI*1;//180*20 degrees
    double duration = 0.5 - _spinChanger*0.05;
    double duration_b = 0.5;
    if(duration <= 0) duration = 0.01;
    
    // duration = 0.01;
    duration = duration * 1;
    
    SKAction *rotate = [SKAction rotateByAngle:angle duration:duration];
    SKAction *moveDown = [SKAction moveByX:0 y:-200*_sizeChanger duration:duration_b];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:_bagColor size:node.frame.size];
    sprite.position = node.position;
    sprite.zPosition = _dumpTruck.zPosition + 1;
    
    
    // node.physicsBody.categoryBitMask = 0;
    // node.physicsBody.contactTestBitMask = 0;
    [self addChild:sprite];
    
    [sprite runAction:[SKAction repeatAction:rotate count:50]];
    [sprite runAction:moveDown completion:^{
        [sprite removeFromParent];
    }];
    
    
    for (int i = 0; i < ceil(_spinChanger/5.0); i ++) {
        
        int randomDeviation1 = arc4random()%50 - 25;
        int randomDeviation2 = arc4random()%50 - 25;
        
        int num2 = [_pointMultiplyer intValue];

        if(num2 <= 1 || num2 == nil) num2 = 1;
        NSString *string = [NSString stringWithFormat:@"plus%d", num2];
        SKSpriteNode *pointSprite = [SKSpriteNode spriteNodeWithImageNamed:string];
        pointSprite.size = CGSizeMake(30*_sizeChanger, 30*_sizeChanger);
        pointSprite.position = sprite.position;
        pointSprite.zPosition = sprite.zPosition;
        [self addChild:pointSprite];
        
        double duration2 = 0.5;
        SKAction *movePoint1_a = [SKAction moveByX:(100 + randomDeviation1)*_sizeChanger y:(-100 + randomDeviation2)*_sizeChanger duration:duration2];
        SKAction *movePoint1_b = [SKAction moveByX:(-100 + randomDeviation1)*_sizeChanger y:(-100 + randomDeviation2)*_sizeChanger duration:duration2];
        SKAction *movePoint1_c = [SKAction moveByX:(0 + randomDeviation1)*_sizeChanger y:(-100 + randomDeviation2)*_sizeChanger duration:duration2];
        
        
        SKAction *movePoint2_a = [SKAction moveByX:30*_sizeChanger y:30*_sizeChanger duration:duration2];
        SKAction *movePoint2_b = [SKAction moveByX:-30*_sizeChanger y:30*_sizeChanger duration:duration2];
        SKAction *movePoint2_c = [SKAction moveByX:0*_sizeChanger y:30*_sizeChanger duration:duration2];
        
        SKNode *testNode = [self childNodeWithName:@"updateCointLabel_totalNode_Node"];
        
        SKSpriteNode *testSprite = (SKSpriteNode *)[testNode childNodeWithName:@"scoreboxNode"];
        CGPoint point = CGPointMake(testSprite.position.x + 10*_sizeChanger, testSprite.position.y + 10*_sizeChanger);
        SKAction *movePoint3_a = [SKAction moveTo:point duration:duration2];
        
        
        SKAction *sequence1 = [SKAction sequence:@[movePoint1_a, movePoint2_a, movePoint3_a]];
        SKAction *sequence2 = [SKAction sequence:@[movePoint1_b, movePoint2_b, movePoint3_a]];
        SKAction *sequence3 = [SKAction sequence:@[movePoint1_c, movePoint2_c, movePoint3_a]];
        
        SKAction *actionToRun;
        
        int num = arc4random()%3;
        if(num == 0) actionToRun = sequence1;
        if(num == 1) actionToRun = sequence2;
        if(num == 2) actionToRun = sequence3;
       // _pointMultiplyer = [NSNumber numberWithInt:10];
        
        _score = _score + 1*[_pointMultiplyer intValue];
        [pointSprite runAction:actionToRun completion:^{
            [self updateScoreLabel:(1*[_pointMultiplyer intValue])];
            [pointSprite removeFromParent];
            [self runAction:[SKAction playSoundFileNamed:@"scoreIncreased.mp3" waitForCompletion:NO]];

        }];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        //int positions = 3;
        
        if(_gameHasStarted == false) [self removeInstructions];
        
        /*
        for(int i = 1; i <= positions; i++)
        {
            if(location.x > (i-1)*round(self.size.width/positions) && location.x < (i)*round(self.size.width/positions))
            {
                NSLog(@"%d", i);
                
                [self runTruck:i];
            }
        }
        */
        
        if(_gameHasStarted == TRUE && _gameIsOver == false){
            _xTouchInput = (location.x - 160)*1.2 + 160;
            
            [self movePlayer];
            
        }
        
        
        SKSpriteNode *node = (SKSpriteNode *)[self nodeAtPoint:location];
        
        if([node.name isEqualToString:@"fbNode"]){
            [self facebook];
            [self runAction:[SKAction playSoundFileNamed:@"buttonClicked.mp3" waitForCompletion:NO]];
          //  [self checkShareDate];
        }
        if([node.name isEqualToString:@"twNode"]){
            [self twitter];
            [self runAction:[SKAction playSoundFileNamed:@"buttonClicked.mp3" waitForCompletion:NO]];
            
        }
        if([node.name isEqualToString:@"leaderboardButtonNode"]){
            [self leaderboard];
            [self runAction:[SKAction playSoundFileNamed:@"buttonClicked.mp3" waitForCompletion:NO]];
        }
        if([node.name isEqualToString:@"rpNode"]){
            [self rowdyPandaLogoClicked];
            [self runAction:[SKAction playSoundFileNamed:@"buttonClicked.mp3" waitForCompletion:NO]];
            
        }
        if([node.name isEqualToString:@"shareBoxNode"] || [node.name isEqualToString:@"shareLabelNode"]){
            [self twitter];
            [self runAction:[SKAction playSoundFileNamed:@"buttonClicked.mp3" waitForCompletion:NO]];
        }
        /*
        if([node.name isEqualToString:@"rpNode"]){
            [self rpButton];
            [self runAction:[SKAction playSoundFileNamed:@"clickButton.wav" waitForCompletion:NO]];
            
        }
        if([node.name isEqualToString:@"revmobNode"]){
            [self revmob];
            [self runAction:[SKAction playSoundFileNamed:@"clickButton.wav" waitForCompletion:NO]];
            
        }

        */
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        /*
        int positions = 3;
        
        for(int i = 1; i <= positions; i++)
        {
            if(location.x > (i-1)*round(self.size.width/positions) && location.x < (i)*round(self.size.width/positions))
            {
                NSLog(@"%d", i);
                
                [self runTruck:i];
            }
        }
        */
        if(_gameHasStarted == TRUE && _gameIsOver == false){
        _xTouchInput = (location.x - 160)*1.2 + 160;
        
        [self movePlayer];
        
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        int positions = 3;
        
        for(int i = 1; i <= positions; i++)
        {
            if(location.x > (i-1)*round(self.size.width/positions) && location.x < (i)*round(self.size.width/positions))
            {
                NSLog(@"%d", i);
                
                [self runTruck:i];
            }
        }
        
        CGPoint checkPoint = CGPointMake(location.x - self.size.width/2, location.y - self.size.height/2);
        SKSpriteNode *node = (SKSpriteNode *)[_gameOverOverlay nodeAtPoint:checkPoint];
        
        if([node.name isEqualToString:@"newgameNode"] && _gameIsOver == true){
            // NSLog(@"lsdkfjkllskdfj");
            

            [_gameOverOverlay removeFromParent];
            _gameHasStarted = false;
          //  [self setupGame];
                [self runAction:[SKAction playSoundFileNamed:@"buttonClicked.mp3" waitForCompletion:NO]];

            SKView * skView = (SKView *)self.view;
            skView.showsFPS = YES;
            skView.showsNodeCount = YES;
            
            // Create and configure the scene.
            SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            
            // Present the scene.
            [skView presentScene:scene];
            
        }
        
    }
}


-(void)movePlayer{
    // if(gameIsPaused == false){
    
    if(_xTouchInput < 0){
        _xTouchInput = 0;
    }
    if(_xTouchInput > 320){
        _xTouchInput = 320;
    }
    // [_player removeAllActions];
    double playerMovesHowFast = 0.02;
    
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(_xTouchInput, self.dumpTruck.position.y) duration:playerMovesHowFast];
    
    NSLog(@"call405");
    [_dumpTruck runAction:actionMove];
    //   }
}




- (void)didBeginContact:(SKPhysicsContact *)contact
{
    
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & floorCategory ) != 0 && (secondBody.categoryBitMask & lawnCategory) != 0)
    {
        
        [secondBody.node removeFromParent];
        //   [_leftLawnArray removeObject:secondBody.node];
        //   [_rightLawnArray removeObject:secondBody.node];
        
        [self addLawns];
    }
    if ((firstBody.categoryBitMask & floorCategory ) != 0 && (secondBody.categoryBitMask & dividerCategory) != 0)
    {
        
        [secondBody.node removeFromParent];
        //  [self addLineDividers];
    }
    if ((firstBody.categoryBitMask & truckCategory ) != 0 && (secondBody.categoryBitMask & garbageBagCategory) != 0)
    {
        [self increaseScore];
        [self spinSmallSquare:secondBody.node];
        [secondBody.node removeFromParent];
        [_bagArray removeObject:secondBody.node];
        
        
        
        
    }
    if ((firstBody.categoryBitMask & truckCategory ) != 0 && (secondBody.categoryBitMask & carCategory) != 0)
    {
        //  [secondBody.node removeFromParent];
        // [_bagArray removeObject:secondBody.node];
        //[self gameOver];
        [self preEndGame:secondBody.node];
        
        
        
        
    }
    if ((firstBody.categoryBitMask & carCategory ) != 0 && (secondBody.categoryBitMask & fakeSquareCategory) != 0)
    {
          [firstBody.node removeFromParent];
         [_obstacleArray removeObject:firstBody.node];

        
        
        
        
    }
    
}


//This method is fucking sick. Use this all the time.
-(void)shakeEmUp{
    
    int times = 4;
    CGPoint initialPoint = self.position;
    NSInteger amplitudeX = 4;
    NSInteger amplitudeY = 4;
    NSMutableArray * randomActions = [NSMutableArray array];
    for (int i=0; i<times; i++) {
        NSInteger randX = arc4random() % amplitudeX - amplitudeX/2;
        NSInteger randY = arc4random() % amplitudeY - amplitudeY/2;
        SKAction *action = [SKAction moveByX:randX y:randY duration:0.01];
        [randomActions addObject:action];
    }
    
    SKAction *rep = [SKAction sequence:randomActions];
    
    [self runAction:rep completion:^{
        self.position = initialPoint;
    }];
    
    
}

-(void)flashScreen{
    
    SKSpriteNode * flashScreen;
    flashScreen = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:self.size];
    flashScreen.alpha = 0.75;
    flashScreen.position = CGPointMake(flashScreen.size.width/2, flashScreen.size.height/2);
    
    [flashScreen runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.0 duration:0.01], [SKAction removeFromParent]]]];
    
    flashScreen.zPosition = 101;
    [self addChild:flashScreen];
    
}
-(void)increaseScore{
    
    [self setColor];
    //  [self updateScoreLabel];
    //  _score = _score + 1;
    _spinChanger = _spinChanger + 2;
    NSLog(@"%d",_score);
    
    NSLog(@"garbage collected");
    //[self addLineDividers];
    
    //int j =  floor(_score/5.0);
    
    int pointMulti = [_pointMultiplyer integerValue];
    int scoreLevel = floor(_score/(100*pointMulti));
    
    if(scoreLevel >= 1){
    double changePerScore = 0.05;
    int maxDam = 1.5;//these parameters give max damp at 90 clicks
    _globalLinearDamping  = _globalLinearDamping - changePerScore;
    
    if(_globalLinearDamping <= maxDam){
        _globalLinearDamping = maxDam;
    }
    NSLog(@"LINEAR DAMPING - %f", _globalLinearDamping);
    }
    /*
     for(int i = 0; i < _leftLawnArray.count; i++)
     {
     
     SKSpriteNode * node = [_leftLawnArray objectAtIndex:i];
     [node.physicsBody setLinearDamping:_globalLinearDamping];
     }
     
     for(int i = 0; i < _rightLawnArray.count; i++)
     {
     
     SKSpriteNode * node = [_rightLawnArray objectAtIndex:i];
     [node.physicsBody setLinearDamping:_globalLinearDamping];
     }
     */
    for(int i = 0; i < _bagArray.count; i++)
    {
        
        SKSpriteNode * node = [_bagArray objectAtIndex:i];
        [node.physicsBody setLinearDamping:_globalLinearDamping];
    }
    for(int i = 0; i < _obstacleArray.count; i++)
    {
        
        SKSpriteNode * node = [_obstacleArray objectAtIndex:i];
        [node.physicsBody setLinearDamping:_globalLinearDamping];
    }
    
    // [self shakeEmUp];
    
    [self flashScreen];
    
    
}

-(void)updateScoreLabel:(int)num{
    
    NSInteger lastHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
    
//    lastHighScore = 0;
    SKNode *testNode_ForLocalScore = [self childNodeWithName:@"updateCointLabel_totalNode_Node"];
    SKShapeNode *testShape = (SKShapeNode *)[testNode_ForLocalScore childNodeWithName:@"scoreboxNode"];
    SKLabelNode *testLabel = (SKLabelNode *)[testShape childNodeWithName:@"scoreLabelName"];
    int localScore = [testLabel.text intValue] + num;
    
    


    
    SKNode *testNode = [self childNodeWithName:@"updateCointLabel_totalNode_Node"];
    
    if(testNode == nil){
        
    }
    else{
        [testNode removeFromParent];
    }
    SKNode *totalNode = [SKNode node];
    totalNode.name = @"updateCointLabel_totalNode_Node";
    
    int cornerSize = 4*_sizeChanger;
    SKShapeNode* scoreBox = [SKShapeNode node];
    CGPathRef scoreBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 40*_sizeChanger, 40*_sizeChanger), 4, 4, nil);
    [scoreBox setPath:scoreBoxPath];
    scoreBox.strokeColor = scoreBox.fillColor = [UIColor grayColor];
    scoreBox.position = CGPointMake(self.size.width/2 - scoreBox.frame.size.width/2, self.size.height - scoreBox.frame.size.height/2 - 60*_sizeChanger + cornerSize*2);
    scoreBox.zPosition = 100;
    scoreBox.name = @"scoreboxNode";
    CGPathRelease(scoreBoxPath);
    
    NSString *labelString = [NSString stringWithFormat:@"%d", localScore];//[NSString stringWithFormat:@"X %d", _totalCoins];
    
    SKLabelNode * backLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    backLabel.fontColor = _backColor;
    backLabel.fontSize = 26*_sizeChanger;
    backLabel.text = labelString;
    backLabel.name = @"scoreLabelName";
    backLabel.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, scoreBox.frame.size.height/2 - cornerSize - backLabel.frame.size.height/2);
    backLabel.zPosition = 100;
    
    
    if(localScore >= 100){
        backLabel.fontSize = 24*_sizeChanger;
    }
    if(localScore >= 1000){
        backLabel.fontSize = 19*_sizeChanger;
    }
    if(localScore >= 10000){
        backLabel.fontSize = 14*_sizeChanger;
    }
    backLabel.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, scoreBox.frame.size.height/2 - cornerSize - backLabel.frame.size.height/2);
    //  [scoreBox addChild:backLabel];
    
    [scoreBox addChild:backLabel];
    [totalNode addChild:scoreBox];
    
    [self addChild:totalNode];
    
    
    if(_score <= lastHighScore){
        scoreBox.strokeColor = scoreBox.fillColor = [UIColor grayColor];
        backLabel.fontColor = _backColor;

    }
    else{
        [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"high_score"];
        scoreBox.strokeColor = scoreBox.fillColor = _truckColor;
        backLabel.fontColor = _bagColor;
    }
    
    
}

-(void)preEndGame:(SKNode *)node{
    
    //    [self gameIsOver];
    
    if(_gameIsOver == false){
        _gameIsOver = true;
        [self runAction:[SKAction playSoundFileNamed:@"whiteSquareHit2.mp3" waitForCompletion:NO]];
    double duration = 2.0;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    for (int i = 0; i < _bagArray.count; i++) {
        SKSpriteNode *sprite =  [_bagArray objectAtIndex:i];
        
        sprite.physicsBody.velocity = CGVectorMake(0, 0);
    }
    
    for (int i = 0; i < _obstacleArray.count; i++) {
        SKSpriteNode *sprite =  [_obstacleArray objectAtIndex:i];
        
        sprite.physicsBody.velocity = CGVectorMake(0, 0);
    }
    
    SKAction *actionOnNode = [SKAction rotateByAngle:360 duration:duration];
    
    [node runAction:actionOnNode completion:^{
        [node removeFromParent];
      //  [self gameOver];
    }];
    
    SKEmitterNode *emitter1 = [self addEndgame];
    emitter1.position = CGPointMake(50*_sizeChanger, self.size.height + 50*_sizeChanger);
    
    SKEmitterNode *emitter2 = [self addEndgame];
    emitter2.position = CGPointMake(150*_sizeChanger, self.size.height + 50*_sizeChanger);
    
    SKEmitterNode *emitter3 = [self addEndgame];
    emitter3.position = CGPointMake(250*_sizeChanger, self.size.height + 50*_sizeChanger);
    
    SKEmitterNode *emitter4 = [self addEndgame];
    emitter4.position = CGPointMake(250*_sizeChanger, self.size.height + 50*_sizeChanger);
    
    SKEmitterNode *emitter5 = [self addEndgame];
    emitter5.position = CGPointMake(350*_sizeChanger, self.size.height + 50*_sizeChanger);
    
    [self addChild:emitter1];
    [self addChild:emitter2];
    [self addChild:emitter3];
    [self addChild:emitter4];
    [self addChild:emitter5];

    
    double duration2 = 1.5;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (duration2) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      //  [self dismissNode:emitterSprite];
        [self gameOver];
        
    });
    }
    
}
-(void)gameOver{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Endgame Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    int num = arc4random()%3;
    
    if(num == 1){
        [self revmob];
    }
    else{
    }
    _gameIsOver = true;
    int cornerSize = 15*_sizeChanger;
    int fontSize = 20*_sizeChanger;
    
    int addScreenHeight = 0;
    if(IsIphone5) addScreenHeight = 44;
    double duration = 0.4;
    double duration2 = 0.5;

    [self removeAllChildren];
    
    SKAction *fadeInFirst = [SKAction fadeAlphaTo:1 duration:duration2];
    _gameOverOverlay = [SKSpriteNode spriteNodeWithColor:_truckColor size:self.size];
    _gameOverOverlay.position = CGPointMake(self.size.width/2, self.size.height/2);
    _gameOverOverlay.name = @"gameOverOverlayNode";
    
    [_gameOverOverlay runAction:[SKAction fadeAlphaTo:1 duration:duration] completion:^{
      //  [self removeAllChildren];
    }];
    
    
    [self addChild:_gameOverOverlay];
    _gameOverOverlay.zPosition = 200;
    
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    
    label.fontColor = _bagColor;
    label.fontSize = fontSize + 12*_sizeChanger;
    label.text = @"Game Over!";
    label.position = CGPointMake(0, 200*_sizeChanger + addScreenHeight);
    [_gameOverOverlay addChild:label];
    
    
    
    SKShapeNode* scoreBox = [SKShapeNode node];
    CGPathRef scoreBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 200*_sizeChanger, 80*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [scoreBox setPath:scoreBoxPath];
    scoreBox.lineWidth = 0.5*_sizeChanger;
    scoreBox.strokeColor = _obstacleColor;
    scoreBox.fillColor = _backColor;
    scoreBox.position = CGPointMake(0 - scoreBox.frame.size.width/2 + cornerSize, (120 + addScreenHeight)*_sizeChanger);
    CGPathRelease(scoreBoxPath);
    
    SKLabelNode *scoreLabel1 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel1.fontColor = _bagColor;
    scoreLabel1.fontSize = fontSize - 2*_sizeChanger;
    scoreLabel1.text = @"SCORE";
    scoreLabel1.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 45*_sizeChanger);
    [scoreBox addChild:scoreLabel1];
    
    SKLabelNode *scoreLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel2.fontColor =_bagColor;
    scoreLabel2.fontSize = fontSize;
    scoreLabel2.text = [NSString stringWithFormat:@"%d", _score];
    scoreLabel2.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 29*_sizeChanger);
    [scoreBox addChild:scoreLabel2];
    
    SKLabelNode *scoreLabel3 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel3.fontColor =_bagColor;
    scoreLabel3.fontSize = fontSize - 2*_sizeChanger;
    scoreLabel3.text = @"HIGH SCORE";
    scoreLabel3.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 7*_sizeChanger);
    [scoreBox addChild:scoreLabel3];
    
    NSInteger lastHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
    SKLabelNode *scoreLabel4 = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    scoreLabel4.fontColor =_bagColor;
    scoreLabel4.fontSize = fontSize;
    scoreLabel4.text = [NSString stringWithFormat:@"%ld", (long)lastHighScore];
    scoreLabel4.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, -9*_sizeChanger);
    [scoreBox addChild:scoreLabel4];
    
    [_gameOverOverlay addChild:scoreBox];
    [scoreBox setAlpha:0];
    [scoreBox runAction:fadeInFirst];
    
    
   // lastHighScore = 0;
    
    if(_score > lastHighScore){
        
        scoreLabel1.text = @"NEW HIGH SCORE";
        scoreLabel1.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 45*_sizeChanger);
        scoreLabel3.text = @"CONGRATULATIONS";
        scoreLabel3.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, 7*_sizeChanger);
        scoreLabel4.text = @"________________";
        scoreLabel4.position = CGPointMake(scoreBox.frame.size.width/2 - cornerSize, -9*_sizeChanger);


    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    SKShapeNode* shareBox = [SKShapeNode node];
    CGPathRef shareBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 200*_sizeChanger, 40*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [shareBox setPath:shareBoxPath];
    shareBox.name = @"shareBoxNode";
    shareBox.lineWidth = 0.5*_sizeChanger;
    shareBox.strokeColor = _obstacleColor;
    shareBox.fillColor = _backColor;
    shareBox.position = CGPointMake(0 - shareBox.frame.size.width/2 + cornerSize, (-170 - addScreenHeight)*_sizeChanger);
    CGPathRelease(shareBoxPath);
    
    SKLabelNode *shareLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    shareLabel.name = @"shareLabelNode";
    shareLabel.fontColor = _bagColor;
    shareLabel.fontSize = fontSize - 0*_sizeChanger;
    shareLabel.text = @"SHARE";

    shareLabel.position = CGPointMake(shareBox.frame.size.width/2 - cornerSize, 0 - shareLabel.frame.size.height/2 + cornerSize/2);
    [shareBox addChild:shareLabel];
    
    
    if([self checkShareDate] == TRUE){
        CGPathRef shareBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 270*_sizeChanger, 40*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [shareBox setPath:shareBoxPath];
        shareBox.position = CGPointMake(0 - shareBox.frame.size.width/2 + cornerSize, (-170 - addScreenHeight)*_sizeChanger);

        CGPathRelease(shareBoxPath);
        
        shareLabel.text = @"SHARE FOR MORE POINTS";
            shareLabel.position = CGPointMake(shareBox.frame.size.width/2 - cornerSize, 0 - shareLabel.frame.size.height/2 + cornerSize/2);
    }
    else{
        
    }
    //  shareBox.position = CGPointMake(0, 10*_sizeChanger);
    [_gameOverOverlay addChild:shareBox];
    
    [shareBox setAlpha:0];
    [shareBox runAction:fadeInFirst];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    int squareSize = 50;
   // int spaceSize = (self.size.width - squareSize*4)/5;
  //  int spaceAdjuster = 80;
    
    
    SKSpriteNode *fb = [SKSpriteNode spriteNodeWithImageNamed:@"facebook_128"];
    fb.size = CGSizeMake(75*_sizeChanger, 75*_sizeChanger);
    fb.position = CGPointMake(0 + 60*_sizeChanger, shareBox.position.y - 0 + fb.size.height);
    [_gameOverOverlay addChild:fb];
    fb.name = @"fbNode";
    fb.zPosition = 100;
    //[fb runAction:[SKAction moveByX:0 y:-200*_sizeChanger duration:0.5]];
    [fb setAlpha:0];
    [fb runAction:fadeInFirst];
    
    
    SKSpriteNode *tw = [SKSpriteNode spriteNodeWithImageNamed:@"twitter_128"];
    tw.size = CGSizeMake(75*_sizeChanger, 75*_sizeChanger);
    tw.position = CGPointMake(0 - 60*_sizeChanger,  shareBox.position.y - 0 + tw.size.height);
    [_gameOverOverlay addChild:tw];
    tw.name = @"twNode";
    tw.zPosition = 100;
    // [tw runAction:[SKAction moveByX:0 y:-200*_sizeChanger duration:0.5]];
    [tw setAlpha:0];
    [tw runAction:fadeInFirst];
    
     SKSpriteNode *rp = [SKSpriteNode spriteNodeWithImageNamed:@"squarePandaButton_small"];
     rp.size = CGSizeMake(125*_sizeChanger, 125*_sizeChanger);
     
     rp.position = CGPointMake(18*_sizeChanger + rp.frame.size.width/2, (28 - 0)*_sizeChanger);
     [_gameOverOverlay addChild:rp];
     rp.name = @"rpNode";
     rp.zPosition = 100;
     //[rp runAction:[SKAction moveByX:0 y:-200*_sizeChanger duration:0.5]];
    [rp setAlpha:0];

    
    
    
    SKShapeNode* shareBox2 = [SKShapeNode node];//leaderboard
        CGPathRef shareBox2Path = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 150*_sizeChanger, 50*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [shareBox2 setPath:shareBox2Path];
    shareBox2.lineWidth = 0.5*_sizeChanger;
    shareBox2.strokeColor = _obstacleColor;
    shareBox2.fillColor = _backColor;
    shareBox2.position = CGPointMake(20*_sizeChanger - shareBox2.frame.size.width - 0*cornerSize, (55 - 0)*_sizeChanger);//145
    shareBox2.name = @"leaderboardButtonNode";
    [shareBox2 setAlpha:0];
    CGPathRelease(shareBox2Path);
    
    SKLabelNode *leaderboardLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    leaderboardLabel.fontColor = _bagColor;
    leaderboardLabel.fontSize = fontSize - 2*_sizeChanger;
    leaderboardLabel.text = @"LEADERBOARD";
    leaderboardLabel.name = @"leaderboardButtonNode";
    leaderboardLabel.position = CGPointMake(shareBox2.frame.size.width/2 - cornerSize, 0);
    [shareBox2 addChild:leaderboardLabel];
    
    [_gameOverOverlay addChild:shareBox2];
    
    
    
    
    
    SKShapeNode* newgameBox = [SKShapeNode node];
    CGPathRef newGamePath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 150*_sizeChanger, 50*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
    [newgameBox setPath:newGamePath];
    newgameBox.lineWidth = 0.5*_sizeChanger;
    newgameBox.strokeColor = _obstacleColor;
    newgameBox.fillColor = _backColor;
    newgameBox.position = CGPointMake(20*_sizeChanger - newgameBox.frame.size.width + 0*cornerSize, (-20 - 0)*_sizeChanger);
    newgameBox.name = @"newgameNode";
    [newgameBox setAlpha:0];
    CGPathRelease(newGamePath);

    
    SKLabelNode *newgameLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldMT"];
    newgameLabel.fontColor = _bagColor;
    newgameLabel.fontSize = fontSize + 4*_sizeChanger;
    newgameLabel.text = @"NEW GAME";
    newgameLabel.name = @"newgameNode";
    newgameLabel.position = CGPointMake(newgameBox.frame.size.width/2 - cornerSize,0);
    [newgameBox addChild:newgameLabel];
    
    [_gameOverOverlay addChild:newgameBox];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (duration2*1.5) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //  [self dismissNode:emitterSprite];
       // [self gameOver];
        [shareBox2 runAction:fadeInFirst];
        [newgameBox runAction:fadeInFirst];
        [rp runAction:fadeInFirst];

    });
    
    
    NSLog(@"GAME OVER");
}


-(void)leaderboard{
   // [self increasePointMultipler];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Endgame Screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"leaderboard"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    /*
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    int scoreToSend = _score;
    
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            
            currentLeaderBoard = @"highScore_Squares";
            GKScore* score2= [[GKScore alloc] initWithLeaderboardIdentifier:self.currentLeaderBoard];
            score2.value = scoreToSend;
            [GKScore reportScores:@[score2] withCompletionHandler:^(NSError *error) {
                if (error) {
                    // handle error
                }
            }];
            
            
            GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            gameCenterController.gameCenterDelegate = self;
            
            
            UIViewController *vc = self.view.window.rootViewController;
            [vc presentViewController:gameCenterController animated:YES completion:nil];
            // Player was successfully authenticated.
            // Perform additional tasks for the authenticated player.
        }
    }];
    
    */
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)rowdyPandaLogoClicked{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Endgame Screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"Rowdy Panda Logo"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bit.ly/1pfIrb4"]];
    
}
-(void)cbAdClicked{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bit.ly/1pfIrb4"]];
}





-(void)revmob{
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
    //    [_gameOverOverlay removeFromParent];
    //    [self setupGame];
        
    } else {
        NSLog(@"There IS internet connection");
        
        
        RevMobFullscreen *ad = [[RevMobAds session] fullscreen]; // you must retain this object
        [ad loadWithSuccessHandler:^(RevMobFullscreen *fs) {
            [fs showAd];
            NSLog(@"Ad loaded");
            //   [self doVolumeFadeOut:_themePlayer];
            
        } andLoadFailHandler:^(RevMobFullscreen *fs, NSError *error) {
            NSLog(@"Ad error: %@",error);
            [adMobinterstitial_ loadRequest:request];
            
        } onClickHandler:^{
            NSLog(@"Ad clicked");
        } onCloseHandler:^{
            NSLog(@"Ad closed");
         //   [_gameOverOverlay removeFromParent];
         //   [self setupGame];
        }];
        
        
        //    [[RevMobAds session] showFullscreen];
        
        
    }
    
}


//Google admob


- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    
    
    
    [adMobinterstitial_ presentFromRootViewController:self.view.window.rootViewController];
    
    
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    
  //  [_gameOverOverlay removeFromParent];
  //  [self setupGame];
    
    
    
}


-(void)interstitialWillPresentScreen:(GADInterstitial *)ad{
    
    
}
-(void)interstitialWillDismissScreen:(GADInterstitial *)ad{
    
}

-(void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    
    //  [self interstitialDidDismissScreen:ad];
}





-(void)facebook{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Endgame Screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"facebook"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    
    // Check if the Facebook app is installed and we can present the share dialog
    
    /*
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.picture = [NSURL URLWithString:@"http://www.imgur.com/J0vn5uK.png"];
  //  params.link = [NSURL URLWithString:@"https://itunes.apple.com/us/app/sqaures/id886925392?ls=1&mt=8"];
    params.link = [NSURL URLWithString:@"https://www.google.com"];

    params.caption = @"From Rowdy Panda Games";
    NSString *descriptString = [NSString stringWithFormat:@"Get sqaures - the minimalist new hit!"];
    params.linkDescription = descriptString;
    params.name = @"Sqaures";
    */
   // NSURL *appUrl = [NSURL URLWithString:@"https://itunes.apple.com/us/app/sqaures/id886925392?ls=1&mt=8"];
 //   NSURL *appUrl = [NSURL URLWithString:@"https://www.google.com"];

 //   NSURL *picUrl = [NSURL URLWithString:@"http://www.imgur.com/J0vn5uK.png"];
    // If the Facebook app is installed and we can present the share dialog
  /*  if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present share dialog
        
        //    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
        /*
         [FBDialogs presentShareDialogWithLink:appUrl
         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
         if(error) {
         // An error occurred, we need to handle the error
         // See: https://developers.facebook.com/docs/ios/errors
         NSLog(@"Error publishing story: %@", error.description);
         } else {
         // Success
         NSLog(@"result %@", results);
         }
         }];
         *//*
        NSDictionary *clientState = [NSDictionary dictionary];
        [FBDialogs presentShareDialogWithLink:appUrl name:params.name caption:params.caption description:descriptString picture:picUrl clientState:clientState handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
                NSLog(@"Error publishing story: %@", error.description);
            } else {
                // Success
                 if([self checkShareDate] == TRUE)[self increasePointMultipler];
                NSLog(@"result %@", results);
            }
        }];
        
        *//*
        [FBDialogs presentShareDialogWithLink:appUrl
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
    } else {*/
        
        // Present the feed dialog
        
        // Put together the dialog parameters
        NSString *descriptString = [NSString stringWithFormat:@"Get sqaures - the minimalist new hit!"];
       NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Sqaures", @"name",
                                       @"From Rowdy Panda Games", @"caption",
                                       descriptString, @"description",
                                       @"https://itunes.apple.com/us/app/sqaures/id886925392?ls=1&mt=8", @"link",
                                       @"http://imgur.com/J0vn5uK", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  if([self checkShareDate] == TRUE)[self increasePointMultipler];

                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
        
        
    //}
    
    
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}




-(void)twitter{
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"Endgame Screen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"twitter"
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
    
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                if([self checkShareDate] == TRUE)[self increasePointMultipler];
                break;
        }
    };
    
    //  Set the initial body of the Tweet
   // int score = 10;
    NSString *initialTextString = [NSString stringWithFormat:@"Just got %d in sqaures. From @TheRowdyPanda", _score];
    [tweetSheet setInitialText:initialTextString];
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
    if (![tweetSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/sqaures/id886925392?ls=1&mt=8"]]){
        NSLog(@"Unable to add the URL!");
    }
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"Icon.png"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    
    
    //  Presents the Tweet Sheet to the user
    UIViewController *vc = self.view.window.rootViewController;
    
    [vc presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
    
}




-(void)gameCenter{
    
}

//sets events to happen at a given time interval
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    
    
    self.lastSpawnTimeInterval += timeSinceLast;
    
    
    double timeAddCarInterval = (arc4random()%50 + 5)/10.0;
    
    if(self.lastSpawnTimeInterval > timeAddCarInterval)
    {
        self.lastSpawnTimeInterval = 0;
        
        int j = round(1.0*(1.0 + 1.0/((_score + 1) / 3.0) ));
        if(arc4random()%j == 1){
            // [self addCar];
        }
    }
    
    
}

- (void)update:(NSTimeInterval)currentTime {
    
    
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    //
    //
    
    int size = 10 + round(_score/20.0);
    if(size >= 60) size = 60;

    int num = arc4random()%size;
    
    
    
    if(num == 1){
        [self addLawns];
    }
    
    int pointMulti = [_pointMultiplyer integerValue];
    int checkNum = (60 - round(_score/(15.0*pointMulti)));//max at 1000
    if(checkNum <= 1) checkNum = 1;
    int num2 = arc4random()%checkNum;
    
    if(num2 == 0){
        [self addCar];
    }
    

    if(round(_score/(_pointMultiplyer.integerValue)) <= 250){
        if(arc4random()%8 == 1) [self addCar];
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

-(void)fadeOut:(SKSpriteNode *)node{
    
    
    [node runAction:[SKAction fadeAlphaBy:-0.1 duration:0.05] completion:^{
        
        [self fadeOut:node];
    }];
    
}


-(SKEmitterNode *)addEndgame{
    
    
    SKEmitterNode *emitterSprite = [[SKEmitterNode alloc] init];
    
	emitterSprite.name = @"coin_cell";
    emitterSprite.particleTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"whiteBox.png"]];
    emitterSprite.particleScale = 0.33*_sizeChanger;
   // emitterSprite.frame = CGRectMake(0, 0, 35*_sizeChanger, 35*_sizeChanger);
    //emitterSprite = CGRectMake(100, 100, 100, 100);
    //emitterSprite.enabled = YES;
    
    //	emitterSprite.contents = (id)[[UIImage imageNamed:@"coin.png"] CGImage];
    //	emitterSprite.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);
    
	//emitterSprite.magnificationFilter = kCAFilterLinear;
	//emitterSprite.minificationFilter = kCAFilterLinear;
	//emitterSprite.minificationFilterBias = 0.00;
    /*
	emitterSprite.particleScale = 0.20;
	emitterSprite.particleScaleRange = 0.00;
	emitterSprite.particleScaleSpeed = 0.40;
    */
	//emitterSprite.particleColor = (__bridge UIColor *)([[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00] CGColor]);
	emitterSprite.particleColorRedRange = 0.00;
	emitterSprite.particleColorGreenRange = 0.00;
	emitterSprite.particleColorBlueRange = 0.00;
	emitterSprite.particleColorAlphaRange = 0.00;
    
	emitterSprite.particleColorRedSpeed = 0.00;
	emitterSprite.particleColorBlueSpeed = 0.00;
	emitterSprite.particleColorGreenSpeed = 0.00;
	emitterSprite.particleColorAlphaSpeed = 0.00;
    
	emitterSprite.particleLifetime = 3.00;
	emitterSprite.particleLifetimeRange = 0.00;
	emitterSprite.particleBirthRate = 12;
	emitterSprite.particleSpeed = 0.00;
	emitterSprite.particleSpeedRange = 100.00;
	emitterSprite.xAcceleration = 0.00;
	emitterSprite.yAcceleration = -360.00;
	//emitterSprite.zAcceleration = 0.00;
    
	// these values are in radians, in the UI they are in degrees
	emitterSprite.particleRotation = 0.00;
	emitterSprite.particleRotationRange = 0.000;
	//emitterSprite.emissionLatitude = 0.000;
	//emitterSprite.emissionLongitude = 0.000;
	emitterSprite.emissionAngle = 0.000;
    

    
    double duration = 1.5;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (duration) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissNode:emitterSprite];
        
    });
    
    emitterSprite.zPosition = 200;
    
    return emitterSprite;
    

}

-(void)dismissNode:(SKNode *)node{
    
    double duration = 0.4;
    SKAction *fadeAction = [SKAction fadeAlphaTo:0 duration:duration];
    
    [node runAction:fadeAction completion:^{
        [node removeFromParent];
        
    }];
}


-(BOOL)checkShareDate{
    
    if([_pointMultiplyer intValue] < 10){
    NSDate *lastTimeShared =[[NSUserDefaults standardUserDefaults] objectForKey:@"lastTimeSharedForIncrease"];
    
    
    NSDate *currentDate = [NSDate date];
    NSDate *yesterday = [currentDate dateByAddingTimeInterval: -86400.0];
    
    if(lastTimeShared != nil){


    }
    else{
        NSDate *WaysAgo = [currentDate dateByAddingTimeInterval: -86400.0*30];//one month ago
        
        [[NSUserDefaults standardUserDefaults] setObject:WaysAgo forKey:@"lastTimeSharedForIncrease"];
        lastTimeShared = WaysAgo;
    }

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSTimeInterval differenceBetweenDates_Seconds = [currentDate timeIntervalSinceDate:lastTimeShared];
    NSTimeInterval differenceBetweenDates_Minutes = differenceBetweenDates_Seconds/60;
    NSTimeInterval differenceBetweenDates_Hours = differenceBetweenDates_Minutes/60;

    NSTimeInterval differenceNeededToShare_Hours = 20;
    

    
    if(differenceBetweenDates_Hours >= differenceNeededToShare_Hours){
        
        return TRUE;
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:yesterday forKey:@"lastTimeSharedForIncrease"];
        return FALSE;

    }
    //[[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastTimeSharedForIncrease"];
    }
    else{
        return FALSE;
    }
}



-(void)increasePointMultipler{
    
    NSLog(@"INCREASE MULTIPLYER INCREASE MULTIPLYER");
    

 //   [self gameOver];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastTimeSharedForIncrease"];
    _pointMultiplyer = [NSNumber numberWithInt:([_pointMultiplyer intValue] + 1)];
    [[NSUserDefaults standardUserDefaults] setObject:_pointMultiplyer forKey:@"pointMultiplyer"];


    SKShapeNode *testBox = (SKShapeNode *)[_gameOverOverlay childNodeWithName:@"shareBoxNode"];
    SKLabelNode *testLabel = (SKLabelNode *)[testBox childNodeWithName:@"shareLabelNode"];
    
    testLabel.text = @"SHARE";
    
    int cornerSize = 15*_sizeChanger;

    int addScreenHeight = 0;
    if(IsIphone5) addScreenHeight = 44;
    
    CGPathRef testBoxPath = CGPathCreateWithRoundedRect(CGRectMake(-cornerSize, -cornerSize, 200*_sizeChanger, 40*_sizeChanger), 4*_sizeChanger, 4*_sizeChanger, nil);
        [testBox setPath:testBoxPath];
    
        testBox.position = CGPointMake(0 - testBox.frame.size.width/2 + cornerSize, (70 + addScreenHeight)*_sizeChanger);
    
    testLabel.position = CGPointMake(testBox.frame.size.width/2 - cornerSize, 0 - testLabel.frame.size.height/2 + cornerSize/2);
    
    CGPathRelease(testBoxPath);
}


@end
