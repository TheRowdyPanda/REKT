//
//  ViewController.m
//  spinTheSquares
//
//  Created by Rijul Gupta on 6/6/14.
//  Copyright (c) 2014 Rijul Gupta. All rights reserved.
//

#define   IsIphone5     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController
@synthesize admobBannerView = _admobBannerView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;

  //  skView.showsFPS = YES;
  //  skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [self setUpiAd];

    
}



-(void)setUpiAd{
    
//    [self addParticleEmitterUnderneathAdd];
    
    
    _adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    // [_adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    

        _adView.frame = CGRectOffset(_adView.frame, 0, self.view.frame.size.height - _adView.frame.size.height);
    
    [_adView setBackgroundColor:[UIColor whiteColor]];
    [_adView setDelegate:self];
    [self.view addSubview:_adView];
    
    [_adView setAlpha:1.0];
    
    NSDictionary *dictionary = [NSDictionary dictionary];
    NSError *error = [NSError errorWithDomain:@"domain" code:5 userInfo:dictionary];
    [self bannerView:_adView didFailToReceiveAdWithError:error];
    
}




- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
 /*
    int refreshRate = 45;//seconds
    
    [_adView setAlpha:1.0];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (refreshRate) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [_adView removeFromSuperview];
        [self setUpiAd];
    });
  */
    
}




- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //  [_adView setAlpha:0.0];
    
    
    [self.adView removeFromSuperview];
 //   [self fadeParticlesOut:_adEmitter];
   // [self addParticleEmitterUnderneathAdd];
 //   _adEmitter.opacity = 0;
    // 2
    
    
    //  _admobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    _admobBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    
_admobBannerView.frame = CGRectOffset(_admobBannerView.frame, 0, self.view.frame.size.height - _admobBannerView.frame.size.height);

    
    // 3
    self.admobBannerView.adUnitID = @"ca-app-pub-4658531991803126/1919858092";
    self.admobBannerView.rootViewController = self;
    self.admobBannerView.delegate = self;
    
    // 4
    [self.view addSubview:self.admobBannerView];
    [self.admobBannerView loadRequest:[GADRequest request]];
    
 
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    [self.admobBannerView removeFromSuperview];
    
    [self fadeParticlesOut:_adEmitter];
    NSLog(@"ADMOB BANNER FAIL");
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
   // _adEmitter.opacity = 1.0;
    
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
    
    
    
}



-(void)adViewWillDismissScreen:(GADBannerView *)adView{
   // [self fadeParticlesOut:_adEmitter];

    
}
-(void)addParticleEmitterUnderneathAdd{
    
    int yPos;
    

        yPos = self.view.frame.size.height + 5*(self.view.frame.size.width/320);
    CALayer *myLayer = [self.view layer];
    
    if(_adEmitter != nil) [_adEmitter removeFromSuperlayer];
    
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    
	emitterLayer.name = @"emitterLayer";
	emitterLayer.emitterPosition = CGPointMake(150*(self.view.frame.size.width/320), yPos);
	emitterLayer.emitterZPosition = 0;
    
	emitterLayer.emitterSize = CGSizeMake(10.00, 10.00);
	emitterLayer.emitterDepth = 0.00;
    
	emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    
	emitterLayer.emitterMode = kCAEmitterLayerPoints;
    
	emitterLayer.renderMode = kCAEmitterLayerAdditive;
    
	emitterLayer.seed = 3578721279;
    
    
    
	
	// Create the emitter Cell
	CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
	
	emitterCell.name = @"underneath_add_cell";
	emitterCell.enabled = YES;
    
	emitterCell.contents = (id)[[UIImage imageNamed:@"Particles_fire.png"] CGImage];
	emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);
    
	emitterCell.magnificationFilter = kCAFilterLinear;
	emitterCell.minificationFilter = kCAFilterLinear;
	emitterCell.minificationFilterBias = 0.00;
    
	emitterCell.scale = 3.50;
	emitterCell.scaleRange = 0.00;
	emitterCell.scaleSpeed = 0.30;
    
	emitterCell.color = [[UIColor colorWithRed:0.50 green:0.50 blue:0.00 alpha:1.00] CGColor];
	emitterCell.redRange = 0.00;
	emitterCell.greenRange = 0.00;
	emitterCell.blueRange = 0.00;
	emitterCell.alphaRange = 0.00;
    
	emitterCell.redSpeed = 0.00;
	emitterCell.greenSpeed = 0.00;
	emitterCell.blueSpeed = 0.00;
	emitterCell.alphaSpeed = 0.00;
    
	emitterCell.lifetime = 1.50;
	emitterCell.lifetimeRange = 0.00;
	emitterCell.birthRate = 25;
	emitterCell.velocity = 0.00;
	emitterCell.velocityRange = 500.00;
	emitterCell.xAcceleration = 0.00;
	emitterCell.yAcceleration = 0.00;
	emitterCell.zAcceleration = 0.00;
    
	// these values are in radians, in the UI they are in degrees
	emitterCell.spin = 0.000;
	emitterCell.spinRange = 0.000;
	emitterCell.emissionLatitude = 0.000;
	emitterCell.emissionLongitude = 0.000;
	emitterCell.emissionRange = 0.000;
    
    
	
	emitterLayer.emitterCells = @[emitterCell];
    
    emitterLayer.shouldRasterize=YES;
    _adEmitter = emitterLayer;
    [myLayer addSublayer:_adEmitter];
    
    //return emitterLayer;
}

-(void)fadeParticlesOut:(CAEmitterLayer *)emitter{
    
    if(emitter.opacity > 0.01)
    {
        emitter.opacity = emitter.opacity -  0.08;
        double duration = 0.03;
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (duration) * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self fadeParticlesOut:emitter];
        });
    }
    else{
        [emitter removeFromSuperlayer];
        
    }
}




- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
