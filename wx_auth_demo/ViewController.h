

#import <UIKit/UIKit.h>

#import "WXApi.h"

@interface ViewController : UIViewController<WXApiDelegate>

-(IBAction)clickAuthButton:(id)sender;
-(IBAction)clickShareButton:(id)sender;
@end

