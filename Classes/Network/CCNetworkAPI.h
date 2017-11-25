//
//  CCNetworkAPI.h
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCNetwork.h"
#import "CCNetworkAPIDelegate.h"
#import "CCNetworkCredentials.h"

#define kNetworkAPIBaseURL [NSURL URLWithString:@"http://cocacola.hiiir.com/api/active.php"]
//#define kNetworkAPIBaseURL [NSURL URLWithString:@"http://cocacolatest.hiiir.com/api/active.php"]

//API: http://cocacola.hiiir.com/api/active.php
//測試API頁面: http://cocacola.hiiir.com/test/index.php
//後台: http://cocacola.hiiir.com/admin/


#define UserDefaultFBTokenKey @"UserDefaultFBTokenKey"
#define UserDefaultFBIdKey @"UserDefaultFBIdKey"
typedef enum {
	CCSingleCokeActionStyle,
	CCSingleCokeActionCoupoun,
	CCSingleCokeActionDescription,
} CCSingleCokeAction;

typedef enum {
	CCMissionSortNew,
	CCMissionSortEnd,
} CCMissionSort;

typedef enum {
	CCRankingActionAll,
	CCRankingActionMe,
} CCRankingAction;

@interface CCNetworkAPI : CCNetwork 
{
	id <CCNetworkAPIDelegate> _delegate;
	CCNetworkCredentials *credentials;
}
/* 手機APP剛安裝好的時候 */
- (void)registerToServer;
- (void)restart;
/* 手機APP關閉時(目前用來記錄User的登入登出使用情況) */
- (void)closeToServer;
/* 影像辨識完畢後，取得為可樂LOGO時 */
- (void)getDiscountForLogoWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat flag:(NSString *)flag;
/* 在APP開啟狀態下，每5分鐘取得優惠訊息時 */
- (void)getDiscountTimeWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat;
/* 回傳某店中某一種類的可樂瓶給使用者(店家抓距離最近者), 需比對coke_amount table,如果可樂瓶該日限量或總限量到達時，則不回傳該可樂瓶樣式 */
// brand: 1 (7-11), 2(全家), 3(萊爾富), 4(OK便利商店)
- (void)getCokeWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat brand:(int)brand;

/* 回傳目前server有的任務列表,抓取任務 if ( mission_end_time > (now – 72 hour) ) */
//- (void)getAllMissionsWithSort:(CCMissionSort)sort;
/* 給予使用者所在經緯度座標，回傳附近店家資訊 */
- (void)getStoreWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat;
/* 回傳目前所有可樂瓶的種類(陣列) */
- (void)getAllCokes;
/* 回傳使用者選擇任務的進度 */
//- (void)updateMissionStatusWithMissionID:(NSString *)missionID;
/* 當使用者取得某種可樂時(按收藏此瓶身時)，更新資訊至user_cokes  table，
 並確認是否產生優惠卷給使用者需比對coupoun_amount table，
 如果coupoun達到當日限量或總限量到達時，則不回傳該coupoun，
 上述步驟做完後，回傳Response內的資訊給使用者儲存 */
- (void)saveCokeWithCokeID:(NSString *)cokeID;
/* 使用完優惠卷後，當店員按下刪除該優惠卷按鈕時 */
- (void)delCouponWithUserCokesID:(NSString *)cokesID;
/* 取得目前所有可辨識之品牌 */
- (void)getBrands;
/* 取得 user收集可樂瓶總數之排行榜 */
- (void)getSumRankingWithAction:(CCRankingAction)action;
/* 取得玩家收集可樂瓶種類之排行榜 */
- (void)getStyleRankingWithAction:(CCRankingAction)action;
/* 取得玩家完成任務數量之排行榜 */
- (void)getMissionRankingWithAction:(CCRankingAction)action;
/* 取得單一可樂瓶資訊 */
- (void)getSingleCokeWithCokeID:(NSString *)cokeId action:(CCSingleCokeAction)action;
/* 回傳任務的店家資訊 */
- (void)getMissionStoreWithMissionID:(NSString *)missionId longtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat;
/* 第二階段 */
/* 收集趣擷取任務列表, page預設1 */
-(void)getMissionPages:(int)page;
/* 登入facebook後將access token傳回伺服器更新排名 */
-(void)loginFBSync;
/* 任務完成後儲存使用者基本資料 */
-(void)saveProfileWithMissionId:(NSString *)missionId name:(NSString *)name email:(NSString *)email phone:(NSString *)phone;
@property (nonatomic,assign) id <CCNetworkAPIDelegate> delegate;
@end
