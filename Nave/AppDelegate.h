//
//  AppDelegate.h
//  Nave
//
//  Created by Luis Felipe Perez on 2/11/14.
//  Copyright Dataminas Tecnologia e Sistemas 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GCHelper.h"

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
