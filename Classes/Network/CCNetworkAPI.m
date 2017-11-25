//
//  CCNetworkAPI.m
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

#import "CCNetworkAPI.h"
#import "CJSONDeserializer.h"


@implementation CCNetworkAPI
@synthesize delegate = _delegate;

- (id) init
{
	self = [super init];
	if (self != nil) {
		credentials = [CCNetworkCredentials sharedManager];
	}
	return self;
}

+ (id)requestToURL:(NSURL *)url delegate:(id)del
{
    CCNetworkAPI *request = [[CCNetworkAPI alloc] init];
    [request setUrl:url];
    [request setDelegate:del];
    return request;
}

/* 手機APP剛安裝好的時候 */
- (void)registerToServer
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"register_sec" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
//		NSLog(@"register raw:%@",[req responseString]);
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didRegister:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didRegister:dict];
		}
		[_responseData release];
		_responseData = nil;
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailRegisterWithError:)]) {
			[self.delegate request:self didFailRegisterWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 手機APP重新啟動時(目前用來記錄User的登入登出使用情況) */
- (void)restart
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"restart_sec" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didRestart:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didRestart:dict];
		}
		[_responseData release];
		_responseData = nil;
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailRestartWithError:)]) {
			[self.delegate request:self didFailRestartWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 手機APP關閉時(目前用來記錄User的登入登出使用情況) */
- (void)closeToServer
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"close" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didClose:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didClose:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailCloseWithError:)]) {
			[self.delegate request:self didFailCloseWithError:err];
		}
	}];
	//[self sendRequest:req];
	[req setTimeOutSeconds:15];
	[req setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
	[req setUseSessionPersistence:NO];
	[req setShouldContinueWhenAppEntersBackground:YES];	
	[req startSynchronous];
}

/* 影像辨識完畢後，取得為可樂LOGO時 */
- (void)getDiscountForLogoWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat flag:(NSString *)flag
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_discount" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:credentials.facebookID forKey:@"user_facebook_id"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lon] forKey:@"user_longitude"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lat] forKey:@"user_latitude"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetDiscountForLogo:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetDiscountForLogo:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetDiscountForLogoWithError:)]) {
			[self.delegate request:self didFailGetDiscountForLogoWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 在APP開啟狀態下，每5分鐘取得優惠訊息時 */
- (void)getDiscountTimeWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_discount_time" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:credentials.facebookID forKey:@"user_facebook_id"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lon] forKey:@"user_longitude"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lat] forKey:@"user_latitude"];
	
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetDiscountTime:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetDiscountTime:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetDiscountTimeWithError:)]) {
			[self.delegate request:self didFailGetDiscountTimeWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 回傳某店中某一種類的可樂瓶給使用者(店家抓距離最近者), 需比對coke_amount table,如果可樂瓶該日限量或總限量到達時，則不回傳該可樂瓶樣式 */
- (void)getCokeWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat brand:(int)brand
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_coke" forKey:@"page"];

	[req setPostValue:[NSString stringWithFormat:@"%d",brand] forKey:@"brand"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:[[NSNumber numberWithDouble:lon] stringValue] forKey:@"user_longitude"];
	[req setPostValue:[[NSNumber numberWithDouble:lat] stringValue] forKey:@"user_latitude"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetCoke:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:_responseData error:nil];
			[self.delegate request:self didGetCoke:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetCokeWithError:)]) {
			[self.delegate request:self didFailGetCokeWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 回傳目前server有的任務列表,抓取任務 if ( mission_end_time > (now – 72 hour) ) */
/*
- (void)getAllMissionsWithSort:(CCMissionSort)sort
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_all_missions" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	if (sort == CCMissionSortNew) {
		[req setPostValue:@"new" forKey:@"sort"];
	}
	else if (sort == CCMissionSortEnd) {
		[req setPostValue:@"end" forKey:@"sort"];
	}
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetAllMissions:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetAllMissions:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetAllMissionsWithError:)]) {
			[self.delegate request:self didFailGetAllMissionsWithError:err];
		}
	}];
	[self sendRequest:req];
}
*/
/* 給予使用者所在經緯度座標，回傳附近店家資訊 */
- (void)getStoreWithLongtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_store" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lon] forKey:@"user_longitude"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lat] forKey:@"user_latitude"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetStore:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetStore:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetStoreWithError:)]) {
			[self.delegate request:self didFailGetStoreWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 回傳目前所有可樂瓶的種類(陣列) */
- (void)getAllCokes
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_all_cokes" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetAllCokes:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetAllCokes:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetAllCokesWithError:)]) {
			[self.delegate request:self didFailGetAllCokesWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 回傳使用者選擇任務的進度 */
/*
- (void)updateMissionStatusWithMissionID:(NSString *)missionID
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"update_mission_status" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:missionID forKey:@"mission_id"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didUpdateMissionStatus:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didUpdateMissionStatus:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailUpdateMissionStatusWithError:)]) {
			[self.delegate request:self didFailUpdateMissionStatusWithError:err];
		}
	}];
	[self sendRequest:req];
}
*/
/* 當使用者取得某種可樂時(按收藏此瓶身時)，更新資訊至user_cokes  table，
 並確認是否產生優惠卷給使用者需比對coupoun_amount table，
 如果coupoun達到當日限量或總限量到達時，則不回傳該coupoun，
 上述步驟做完後，回傳Response內的資訊給使用者儲存 */
- (void)saveCokeWithCokeID:(NSString *)cokeID
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"save_coke" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:cokeID forKey:@"coke_id"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didSaveCoke:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didSaveCoke:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailSaveCokeWithError:)]) {
			[self.delegate request:self didFailSaveCokeWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 使用完優惠卷後，當店員按下刪除該優惠卷按鈕時 */
- (void)delCouponWithUserCokesID:(NSString *)cokesID
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"del_coupoun" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:cokesID forKey:@"user_cokes_id"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didDelCoupon:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didDelCoupon:dict];

		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailDelCouponWithError:)]) {
			[self.delegate request:self didFailDelCouponWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 取得目前所有可辨識之品牌 */
- (void)getBrands
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_brands" forKey:@"page"];
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetBrands:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetBrands:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetBrandsWithError:)]) {
			[self.delegate request:self didFailGetBrandsWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 取得 user收集可樂瓶總數之排行榜 */
- (void)getSumRankingWithAction:(CCRankingAction)action
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_sum_ranking" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultFBIdKey] forKey:@"user_facebook_id"];
//	NSLog(@"facebookID:%@",[[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultFBIdKey]);
	if (action == CCRankingActionAll) {
		[req setPostValue:@"all" forKey:@"action"];
	}
	else if (action == CCRankingActionMe) {
		[req setPostValue:@"me" forKey:@"action"];
	}

	[req setDelegate:self];
	[req setCompletionBlock:^{
//        NSLog(@"getSumRankingWithAction:%@",[req responseString]);
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetSumRanking:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetSumRanking:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetSumRankingWithError:)]) {
			[self.delegate request:self didFailGetSumRankingWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 取得玩家收集可樂瓶種類之排行榜 */
- (void)getStyleRankingWithAction:(CCRankingAction)action
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_style_ranking" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultFBIdKey] forKey:@"user_facebook_id"];
//	NSLog(@"facebookID:%@",[[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultFBIdKey]);
	if (action == CCRankingActionAll) {
		[req setPostValue:@"all" forKey:@"action"];
	}
	else if (action == CCRankingActionMe) {
		[req setPostValue:@"me" forKey:@"action"];
	}
	
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetStyleRanking:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetStyleRanking:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetStyleRankingWithError:)]) {
			[self.delegate request:self didFailGetStyleRankingWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 取得玩家完成任務數量之排行榜 */
- (void)getMissionRankingWithAction:(CCRankingAction)action
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_mission_ranking" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultFBIdKey] forKey:@"user_facebook_id"];
//	NSLog(@"facebookID:%@",[[NSUserDefaults standardUserDefaults] valueForKey:UserDefaultFBIdKey]);
	if (action == CCRankingActionAll) {
		[req setPostValue:@"all" forKey:@"action"];
	}
	else if (action == CCRankingActionMe) {
		[req setPostValue:@"me" forKey:@"action"];
	}
	
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetMissionRanking:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetMissionRanking:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetMissionRankingWithError:)]) {
			[self.delegate request:self didFailGetMissionRankingWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 取得單一可樂瓶資訊 */
- (void)getSingleCokeWithCokeID:(NSString *)cokeId action:(CCSingleCokeAction)action
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_single_coke" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	NSLog(@"getting with: user_iphone_id:%@, cokeid:%@",credentials.UDID,cokeId);
	[req setPostValue:cokeId forKey:@"coke_id"];
//	[req setPostValue:@"1234567" forKey:@"user_iphone_id"];
//	[req setPostValue:@"101" forKey:@"coke_id"];

	if (action == CCSingleCokeActionCoupoun) {
		[req setPostValue:@"coupoun" forKey:@"action"];
	}
	else if (action == CCSingleCokeActionDescription) {
		[req setPostValue:@"description" forKey:@"action"];
	}
	else if (action == CCSingleCokeActionStyle) {
		[req setPostValue:@"style" forKey:@"action"];
	}
	
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetSingleCoke:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:_responseData error:nil];
			[self.delegate request:self didGetSingleCoke:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetSingleCokeWithError:)]) {
			[self.delegate request:self didFailGetSingleCokeWithError:err];
		}
	}];
	[self sendRequest:req];
}

/* 回傳任務的店家資訊 */

- (void)getMissionStoreWithMissionID:(NSString *)missionId longtitude:(CLLocationDegrees)lon latitude:(CLLocationDegrees)lat
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_mission_store" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:missionId forKey:@"mission_id"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lon] forKey:@"user_longitude"];
	[req setPostValue:[NSString stringWithFormat:@"%f", lat] forKey:@"user_latitude"];
	
	[req setDelegate:self];
	[req setCompletionBlock:^{
//		NSLog(@"getMissionStore raw:%@",[req responseString]);
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetMissionStore:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetMissionStore:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetMissionStoreWithError:)]) {
			[self.delegate request:self didFailGetMissionStoreWithError:err];
		}
	}];
	[self sendRequest:req];
}

/*第二階段*/
/* 收集趣擷取任務列表, page預設1 */
-(void)getMissionPages:(int)page
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"get_mission_pages" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:[NSString stringWithFormat:@"%d",page] forKey:@"at"];
	
	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didGetMissionPages:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didGetMissionPages:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailGetMissionPagesWithError:)]) {
			[self.delegate request:self didFailGetMissionPagesWithError:err];
		}
	}];
	[self sendRequest:req];
}
/* 登入facebook後將access token傳回伺服器更新排名 */
-(void)loginFBSync
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"login_fb" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultFBTokenKey] forKey:@"access_token"];
//	NSLog(@"sending token:%@",[[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultFBTokenKey]);
	[req setDelegate:self];
	[req setCompletionBlock:^{
 //       NSLog(@"loginFBSync raw:%@",[req responseString]);
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didLoginFB:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didLoginFB:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailLoginFBWithError:)]) {
			[self.delegate request:self didFailLoginFBWithError:err];
		}
	}];
//	[self sendRequest:req];
    [req setTimeOutSeconds:30.0f];
	[req setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
	[req setUseSessionPersistence:NO];
	[req setShouldContinueWhenAppEntersBackground:YES];	
	[req startSynchronous];

}
/* 任務完成後儲存使用者基本資料 */
-(void)saveProfileWithMissionId:(NSString *)missionId name:(NSString *)name email:(NSString *)email phone:(NSString *)phone
{
	__block ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:_url];
	[req setRequestMethod:@"POST"];
	[req setPostValue:@"save_profile" forKey:@"page"];
	[req setPostValue:credentials.UDID forKey:@"user_iphone_id"];
	[req setPostValue:missionId forKey:@"mission_id"];
	[req setPostValue:name forKey:@"name"];
	[req setPostValue:email forKey:@"email"];
	[req setPostValue:phone forKey:@"phone"];

	[req setDelegate:self];
	[req setCompletionBlock:^{
		_responseData = [[NSData alloc] initWithData:[req responseData]];
		_responseStatusCode = [req responseStatusCode];
		if (_responseStatusCode >= 400) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(request:hadStatusCodeError:)]) {
				[self.delegate request:self hadStatusCodeError:_responseStatusCode];
			}
			return;
		}
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didSaveProfile:)]) {
			NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:_responseData error:nil];
			[self.delegate request:self didSaveProfile:dict];
		}
	}];
	[req setFailedBlock:^{
		NSError *err = [req error];
		if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailSaveProfileWithError:)]) {
			[self.delegate request:self didFailSaveProfileWithError:err];
		}
	}];
	[self sendRequest:req];
}

@end
