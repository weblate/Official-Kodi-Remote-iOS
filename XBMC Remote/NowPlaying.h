//
//  NowPlaying.h
//  XBMC Remote
//
//  Created by Giovanni Messina on 24/3/12.
//  Copyright (c) 2012 joethefox inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSJSONRPC.h"
#import "UIImageView+WebCache.h"
#import "RightMenuViewController.h"
#import "OBSlider.h"
#import "MessagesView.h"

@class ShowInfoViewController;
@class RemoteController;
@class DetailViewController;

@interface NowPlaying : UIViewController <UITableViewDataSource, UITableViewDelegate, SDWebImageManagerDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UIView *transitionView;
    IBOutlet UITableView *playlistTableView;
    IBOutlet UILabel *albumName;
    IBOutlet UILabel *songName;
    IBOutlet UILabel *artistName;
    IBOutlet UILabel *currentTime;
    IBOutlet UILabel *duration;
    IBOutlet UIImageView *jewelView;
    IBOutlet UIImageView *thumbnailView;
    IBOutlet UIView *BottomView;
    IBOutlet UIImageView *fullscreenCover;
    IBOutlet UIVisualEffectView *visualEffectView;
    UIView *transitionFromView;
    UIView *transitionToView;
    IBOutlet UIView *nowPlayingView;
    IBOutlet UIView *playlistView;
    IBOutlet UIView *songDetailsView;
    NSTimer *timer;
    NSMutableArray *playlistData;
    IBOutlet UILabel *songCodec;
    __weak IBOutlet UIImageView *songCodecImage;
    IBOutlet UILabel *songBitRate;
    __weak IBOutlet UIImageView *songBitRateImage;
    IBOutlet UILabel *songSampleRate;
    __weak IBOutlet UIImageView *songSampleRateImage;
    __weak IBOutlet UILabel *songNumChannels;
    __weak IBOutlet UIImageView *songNumChanImage;
    __weak IBOutlet UIImageView *hiresImage;
    int playerID;
    int selectedPlayerID;
    IBOutlet UIActivityIndicatorView *activityIndicatorView;
    int playerPlaying;
    BOOL PlayerPaused;
    int musicPartyMode;
    IBOutlet UIButton *editTableButton;
    IBOutlet UIButton *PartyModeButton;
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIView *noFoundView;
    NSIndexPath *storeSelection;
    int slideFrom;
    int numResults;
    IBOutlet UIView *playlistToolbarView;
    int iPadOrigX;
    int iPadOrigY;
    int iPadthumbWidth;
    int iPadthumbHeight;
    IBOutlet UIView *playlistActionView;
    NSString *currentType;
    BOOL nothingIsPlaying;
    IBOutlet UIButton *playlistButton;
    int animationOptionTransition;
    BOOL startFlipDemo;
    IBOutlet OBSlider *ProgressSlider;
    NSIndexPath *selected;
    NSMutableArray *sheetActions;
    BOOL fromItself;
    IBOutlet UIButton *shuffleButton;
    IBOutlet UIButton *repeatButton;
    IBOutlet UIButton *closeButton;
    UIButton *fullscreenToggleButton;
    BOOL shuffled;
    NSString *repeatStatus;
    BOOL updateProgressBar;
    int globalSeconds;
    NSString *lastThumbnail;
    int choosedTab;
    NSString *notificationName;
    __weak IBOutlet UIImageView *playlistLeftShadow;
    __weak IBOutlet UILabel *scrabbingMessage;
    __weak IBOutlet UILabel *scrabbingRate;
    UIView *toolbarBackground;
    UIColor *foundEffectColor;
    UISegmentedControl *playlistSegmentedControl;
    __weak IBOutlet UILabel *noItemsLabel;
    NSString *storeLiveTVTitle;
    NSString *storeClearlogo;
    NSString *storeClearart;
    NSString *storeCurrentLogo;
    CGFloat bottomPadding;
    BOOL waitForInfoLabelsToSettle;
    CGFloat descriptionFontSize;
    int lastPlayerID;
    long lastSelected;
    int currentPlayerID;
    int storePosSeconds;
    long storedItemID;
    MessagesView *messagesView;
}

- (void)setNowPlayingDimension:(CGFloat)width height:(CGFloat)height YPOS:(CGFloat)YPOS fullscreen:(BOOL)isFullscreen;
- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil;
- (IBAction)startVibrate:(id)sender;
- (void)toggleSongDetails;
- (void)updateCurrentLogo;
- (IBAction)changeShuffle:(id)sender;
- (IBAction)changeRepeat:(id)sender;


@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) RemoteController *remoteController;
@property (strong, nonatomic) UIImageView *jewelView;
@property (strong, nonatomic) IBOutlet UIImageView *itemLogoImage;
@property (strong, nonatomic) UIButton *shuffleButton;
@property (strong, nonatomic) UIButton *repeatButton;
@property (strong, nonatomic) UIView *songDetailsView;
@property (strong, nonatomic) OBSlider *ProgressSlider;
@property (strong, nonatomic) UIView *BottomView;
@property (strong, nonatomic) UIView *playlistToolbarView;
@property (strong, nonatomic) IBOutlet UIView *scrabbingView;
@property (strong, nonatomic) IBOutlet UITextView *itemDescription;

@end
