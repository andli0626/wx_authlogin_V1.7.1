

#import "AppDelegate.h"
#import "WXApi.h"

#define AppID       @"微信APPID"
#define AppSecret   @"微信APPSecret"

@interface AppDelegate ()<WXApiDelegate,NSURLConnectionDataDelegate>
/**
 *  用来存放服务器返回的所有数据
 */
@property (nonatomic, strong) NSMutableData *responseData;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 向微信注册
    [WXApi registerApp:AppID];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark WXApiDelegate 微信分享的相关回调

// onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面
- (void)onReq:(BaseReq *)req
{
    NSLog(@"onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面");
}

// 如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面
- (void)onResp:(BaseResp *)resp
{
    NSLog(@"回调处理");
    
    // 处理 分享请求 回调
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch (resp.errCode) {
            case WXSuccess:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"分享成功!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
                
            default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"分享失败!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
        }
        
    }
    
    // 处理 登录授权请求 回调
    else if ([resp isKindOfClass:[SendAuthResp class]]) {
        switch (resp.errCode) {
            case WXSuccess:
            {
                // 返回成功，获取Code
                SendAuthResp *sendResp = resp;
                NSString *code = sendResp.code;
                NSLog(@"code=%@",sendResp.code);
                // 根据Code获取AccessToken(有限期2个小时）
                // https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
                //
                // 发起GET请求
                // 2.1.设置请求路径
                NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",AppID,AppSecret,code];
                
                // 转码
                urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                // URL里面不能包含中文
                NSURL *url = [NSURL URLWithString:urlStr];
                
                // 2.2.创建请求对象
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; // 默认就是GET请求
                request.timeoutInterval = 5; // 设置请求超时
                
                // 2.3.发送请求
                [self sendAsync:request];
                
                NSLog(@"---------已经发出请求");
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"微信授权成功!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                
            }
                break;
                
            default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"微信授权失败!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
        }
        
    }
}

// 发送异步：GET请求
- (void)sendAsync:(NSURLRequest *)request
{
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) { // 请求成功
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSString *error = dict[@"errcode"];
            if (error) { // 登录失败
                NSLog(@"请求失败!");
            } else {     // 登录成功
                NSString *access_token  =  dict[@"access_token"]; // 接口调用凭证(有效期2h)
                NSString *openid        =  dict[@"openid"];       // 授权用户唯一标识
                
                NSLog(@"openid=%@"      ,openid);
                NSLog(@"access_token=%@",access_token);
                NSLog(@"请求成功!");
            }
        } else { // 请求失败
            NSLog(@"网络繁忙, 请稍后再试");
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
