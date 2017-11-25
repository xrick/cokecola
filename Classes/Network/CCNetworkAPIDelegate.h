//
//  CCNetworkAPIDelegate.h
//  coke
//
//  Created by Franky on 2/5/11.
//  Copyright 2011 Zoaks Co., Ltd. All rights reserved.
//

@class CCNetworkAPI;

@protocol CCNetworkAPIDelegate <NSObject>
@optional
- (void)request:(CCNetworkAPI *)request didRegister:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailRegisterWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didRestart:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailRestartWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didClose:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailCloseWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetDiscountForLogo:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetDiscountForLogoWithError:(NSError *)error;

//- (void)request:(CCNetworkAPI *)request didGetDiscount:(NSDictionary *)dict;
//- (void)request:(CCNetworkAPI *)request didFailGetDiscountWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetCoke:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetCokeWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetAllMissions:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetAllMissionsWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetStore:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetStoreWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetAllCokes:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetAllCokesWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didUpdateMissionStatus:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailUpdateMissionStatusWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didSaveCoke:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailSaveCokeWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didDelCoupon:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailDelCouponWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetBrands:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetBrandsWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetSumRanking:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetSumRankingWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetStyleRanking:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetStyleRankingWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetMissionRanking:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetMissionRankingWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetSingleCoke:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetSingleCokeWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetMissionStore:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetMissionStoreWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didGetDiscountTime:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetDiscountTimeWithError:(NSError *)error;
/*第二階段*/
- (void)request:(CCNetworkAPI *)request didGetMissionPages:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailGetMissionPagesWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didLoginFB:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailLoginFBWithError:(NSError *)error;

- (void)request:(CCNetworkAPI *)request didSaveProfile:(NSDictionary *)dict;
- (void)request:(CCNetworkAPI *)request didFailSaveProfileWithError:(NSError *)error;

// Error handle
- (void)request:(CCNetwork *)request hadStatusCodeError:(int)errorCode;
@end