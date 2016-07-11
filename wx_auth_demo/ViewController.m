
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

// 授权域：通俗讲就是接口的使用权限
static NSString *kAuthScope  = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
//static NSString *kAuthOpenID = @"0c806938e2413ce73eef92cc3";
static NSString *kAuthState  = @"xxx";

// 登录授权
-(IBAction)clickAuthButton:(id)sender{
    //构造SendAuthReq结构体
    SendAuthReq* req    =[[SendAuthReq alloc]init];
    req.scope           = kAuthScope;
    req.state           = kAuthState;
    // req.openID          = kAuthOpenID;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

// 简单文本分享
-(IBAction)clickShareButton:(id)sender{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text                = @"简单文本分享测试";
    req.bText               = YES;
    // 目标场景
    // 发送到聊天界面  WXSceneSession
    // 发送到朋友圈    WXSceneTimeline
    // 发送到微信收藏  WXSceneFavorite
    req.scene               = WXSceneSession;
    [WXApi sendReq:req];
}

@end
