//
//  AppInfoViewController.m
//  XBMC Remote
//
//  Created by Giovanni Messina on 16/4/12.
//  Copyright (c) 2012 joethefox inc.All rights reserved.
//

#import "AppInfoViewController.h"
#import "AppDelegate.h"
#import "Utilities.h"

@interface AppInfoViewController ()

@end

@implementation UITextView (DisableCopyPaste)

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end

@implementation AppInfoViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = 0;
    appName.text = @"Official Kodi Remote";
    appVersion.text = [Utilities getAppVersionString];
    appDescription.text = LOCALIZED_STR(@"Official Kodi Remote app uses artwork downloaded from your Kodi server or from the internet when your Kodi server refers to it. To unleash the beauty of artwork use Kodi's \"Universal Scraper\" or other scraper add-ons.\n\nKodi logo, Zappy mascot and Official Kodi Remote icons are property of Kodi Foundation.\nhttp://www.kodi.tv/contribute\n\n - Team Kodi");
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
