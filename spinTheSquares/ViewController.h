#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
#import <StoreKit/StoreKit.h>

#import "GADBannerView.h"


@interface ViewController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate>{
    BOOL bannerIsVisible;
    
}


@property (nonatomic, strong) GADBannerView *admobBannerView;

@property (nonatomic) ADBannerView *adView;

@property (nonatomic, retain) CAEmitterLayer *adEmitter;




@end
