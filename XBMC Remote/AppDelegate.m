//
//  AppDelegate.m
//  XBMC Remote
//
//  Created by Giovanni Messina on 23/3/12.
//  Copyright (c) 2012 joethefox inc. All rights reserved.
//

#import "AppDelegate.h"
#import "mainMenu.h"
#import "MasterViewController.h"
#import "ViewControllerIPad.h"
#import "GlobalData.h"
#import "InitialSlidingViewController.h"
#import "UIImageView+WebCache.h"
#import "Utilities.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize windowController = _windowController;
@synthesize dataFilePath;
@synthesize arrayServerList;
@synthesize serverOnLine;
@synthesize serverVersion;
@synthesize serverMinorVersion;
@synthesize obj;
@synthesize playlistArtistAlbums;
@synthesize playlistMovies;
@synthesize playlistMusicVideos;
@synthesize playlistTvShows;
@synthesize playlistPVR;
@synthesize globalSearchMenuLookup;
@synthesize serverName;
@synthesize nowPlayingMenuItems;
@synthesize serverVolume;
@synthesize remoteControlMenuItems;
@synthesize xbmcSettings;

+ (AppDelegate*)instance {
	return (AppDelegate*)UIApplication.sharedApplication.delegate;
}

#pragma mark globals

#define ITEM_MUSIC_PHONE_WIDTH 106.0
#define ITEM_MUSIC_PHONE_HEIGHT 106.0
#define ITEM_MUSIC_PAD_WIDTH 119.0
#define ITEM_MUSIC_PAD_HEIGHT 119.0
#define ITEM_MUSIC_PAD_WIDTH_FULLSCREEN 164.0
#define ITEM_MUSIC_PAD_HEIGHT_FULLSCREEN 164.0

#define ITEM_MOVIE_PHONE_WIDTH 106.0
#define ITEM_MOVIE_PHONE_HEIGHT 151.0
#define ITEM_MOVIE_PAD_WIDTH 119.0
#define ITEM_MOVIE_PAD_HEIGHT 170.0
#define ITEM_MOVIE_PAD_WIDTH_FULLSCREEN 164.0
#define ITEM_MOVIE_PAD_HEIGHT_FULLSCREEN 233.0

#define ITEM_TVSHOW_PHONE_WIDTH 158.0
#define ITEM_TVSHOW_PHONE_HEIGHT (ITEM_TVSHOW_PHONE_WIDTH * 9.0/16.0)
#define ITEM_TVSHOW_PAD_WIDTH 178.0
#define ITEM_TVSHOW_PAD_HEIGHT (ITEM_TVSHOW_PAD_WIDTH * 9.0/16.0)
#define ITEM_TVSHOW_PAD_WIDTH_FULLSCREEN 245.0
#define ITEM_TVSHOW_PAD_HEIGHT_FULLSCREEN (ITEM_TVSHOW_PAD_WIDTH_FULLSCREEN * 9.0/16.0)

#define ITEM_MOVIE_PHONE_HEIGHT_RECENTLY 132.0
#define ITEM_MOVIE_PAD_HEIGHT_RECENTLY 196.0
#define ITEM_MOVIE_PAD_WIDTH_RECENTLY_FULLSCREEN 502.0
#define ITEM_MOVIE_PAD_HEIGHT_RECENTLY_FULLSCREEN 206.0

// Amount of bytes per pixel for images cached in memory (32 bit png)
#define BYTES_PER_PIXEL 4

#pragma mark helper

- (NSDictionary*)itemSizes_Musicfullscreen {
    return @{
        @"iphone": @{
                @"width": @ITEM_MUSIC_PHONE_WIDTH,
                @"height": @ITEM_MUSIC_PHONE_HEIGHT,
            },
        @"ipad": @{
                @"width": @ITEM_MUSIC_PAD_WIDTH,
                @"height": @ITEM_MUSIC_PAD_HEIGHT,
                @"fullscreenWidth": @ITEM_MUSIC_PAD_WIDTH_FULLSCREEN,
                @"fullscreenHeight": @ITEM_MUSIC_PAD_HEIGHT_FULLSCREEN,
            },
    };
}

- (NSDictionary*)itemSizes_Music {
    return @{
        @"iphone": @{
                @"width": @ITEM_MUSIC_PHONE_WIDTH,
                @"height": @ITEM_MUSIC_PHONE_HEIGHT,
            },
        @"ipad": @{
                @"width": @ITEM_MUSIC_PAD_WIDTH,
                @"height": @ITEM_MUSIC_PAD_HEIGHT,
            },
    };
}

- (NSDictionary*)itemSizes_TVShowsfullscreen {
    return @{
        @"iphone": @{
                @"width": @ITEM_TVSHOW_PHONE_WIDTH,
                @"height": @ITEM_TVSHOW_PHONE_HEIGHT,
            },
        @"ipad": @{
                @"width": @ITEM_TVSHOW_PAD_WIDTH,
                @"height": @ITEM_TVSHOW_PAD_HEIGHT,
                @"fullscreenWidth": @ITEM_TVSHOW_PAD_WIDTH_FULLSCREEN,
                @"fullscreenHeight": @ITEM_TVSHOW_PAD_HEIGHT_FULLSCREEN,
            },
    };
}

- (NSDictionary*)itemSizes_MovieRecentlyfullscreen {
    return @{
        @"iphone": @{
                @"width": @"fullWidth",
                @"height": @ITEM_MOVIE_PHONE_HEIGHT_RECENTLY,
            },
        @"ipad": @{
                @"width": @"fullWidth",
                @"height": @ITEM_MOVIE_PAD_HEIGHT_RECENTLY,
                @"fullscreenWidth": @ITEM_MOVIE_PAD_WIDTH_RECENTLY_FULLSCREEN,
                @"fullscreenHeight": @ITEM_MOVIE_PAD_HEIGHT_RECENTLY_FULLSCREEN,
            },
    };
}

- (NSDictionary*)itemSizes_Moviefullscreen {
    return @{
        @"iphone": @{
                @"width": @ITEM_MOVIE_PHONE_WIDTH,
                @"height": @ITEM_MOVIE_PHONE_HEIGHT,
            },
        @"ipad": @{
                @"width": @ITEM_MOVIE_PAD_WIDTH,
                @"height": @ITEM_MOVIE_PAD_HEIGHT,
                @"fullscreenWidth": @ITEM_MOVIE_PAD_WIDTH_FULLSCREEN,
                @"fullscreenHeight": @ITEM_MOVIE_PAD_HEIGHT_FULLSCREEN,
            },
    };
}

- (NSDictionary*)itemSizes_Movie {
    return @{
        @"iphone": @{
                @"width": @ITEM_MOVIE_PHONE_WIDTH,
                @"height": @ITEM_MOVIE_PHONE_HEIGHT,
            },
        @"ipad": @{
                @"width": @ITEM_MOVIE_PAD_WIDTH,
                @"height": @ITEM_MOVIE_PAD_HEIGHT,
            },
    };
}

- (NSDictionary*)watchedListenedString {
    return @{
        @"notWatched": LOCALIZED_STR(@"Not listened"),
        @"watchedOneTime": LOCALIZED_STR(@"Listened one time"),
        @"watchedTimes": LOCALIZED_STR(@"Listened %@ times"),
    };
}

- (NSArray*)action_album {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Play in shuffle mode"),
        LOCALIZED_STR(@"Album Details"),
        LOCALIZED_STR(@"Search Wikipedia"),
    ];
}

- (NSArray*)action_artist {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Play in shuffle mode"),
        LOCALIZED_STR(@"Artist Details"),
        LOCALIZED_STR(@"Search Wikipedia"),
        LOCALIZED_STR(@"Search last.fm charts"),
    ];
}

- (NSArray*)action_filemode_music {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Play in shuffle mode"),
    ];
}

- (NSArray*)action_queue_to_play {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
    ];
}

- (NSArray*)action_pictures {
    return @[
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
    ];
}

- (NSArray*)action_movie {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Movie Details"),
    ];
}

- (NSArray*)action_playlist {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Play in shuffle mode"),
        LOCALIZED_STR(@"Play in party mode"),
        LOCALIZED_STR(@"Show Content"),
    ];
}

- (NSArray*)action_musicvideo {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Music Video Details"),
    ];
}

- (NSArray*)action_episode {
    return @[
        LOCALIZED_STR(@"Queue after current"),
        LOCALIZED_STR(@"Queue"),
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Episode Details"),
    ];
}

- (NSArray*)action_broadcast {
    return @[
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Record"),
        LOCALIZED_STR(@"Broadcast Details"),
    ];
}

- (NSArray*)action_channel {
    return @[
        LOCALIZED_STR(@"Play"),
        LOCALIZED_STR(@"Record"),
        LOCALIZED_STR(@"Channel Guide"),
    ];
}

- (NSDictionary*)modes_icons_empty {
    return @{
        @"modes": @[],
        @"icons": @[],
    };
}

- (NSDictionary*)modes_icons_watched {
    return @{
        @"modes": @[
                @(ViewModeDefault),
                @(ViewModeUnwatched),
                @(ViewModeWatched),
        ],
        @"icons": @[
                @"blank",
                @"st_unchecked",
                @"st_checked",
        ],
    };
}

- (NSDictionary*)modes_icons_listened {
    return @{
        @"modes": @[
                @(ViewModeDefault),
                @(ViewModeNotListened),
                @(ViewModeListened),
        ],
        @"icons": @[
                @"blank",
                @"st_unchecked",
                @"st_checked",
        ],
    };
}

- (NSDictionary*)modes_icons_artiststype {
    return @{
        @"modes": @[
                @(ViewModeDefaultArtists),
                @(ViewModeAlbumArtists),
                @(ViewModeSongArtists),
        ],
        @"icons": @[
                @"blank",
                @"st_album_small",
                @"st_songs_small",
        ],
    };
}

- (NSDictionary*)setColorRed:(double)r Green:(double)g Blue:(double)b {
    return @{
        @"red": @(r),
        @"green": @(g),
        @"blue": @(b),
    };
}

- (NSDictionary*)sortmethod:(NSString*)method order:(NSString*)order ignorearticle:(BOOL)ignore {
    return @{
        @"order": order,
        @"ignorearticle": @(ignore),
        @"method": method,
    };
}

#pragma mark -
#pragma mark init

- (id)init {
	if (self = [super init]) {
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.dataFilePath = docPaths[0];
        NSMutableArray *tempArray = [Utilities unarchivePath:self.dataFilePath file:@"serverList_saved.dat"];
        if (tempArray) {
            [self setArrayServerList:tempArray];
        }
        else {
            arrayServerList = [NSMutableArray new];
        }
        
        // Set the image in-memory cache to 25% of physical memory (but max to 512 MB). maxCost reflects the amount of pixels.
        NSInteger memorySize = [[NSProcessInfo processInfo] physicalMemory];
        NSInteger maxCost = MIN(memorySize / 4, 512 * 1024 * 1024) / BYTES_PER_PIXEL;
        [[SDImageCache sharedImageCache] setMaxMemoryCost:maxCost];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.libraryCachePath = [cachePaths[0] stringByAppendingPathComponent:@"LibraryCache"];
        [fileManager createDirectoryAtPath:self.libraryCachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        self.epgCachePath = [cachePaths[0] stringByAppendingPathComponent:@"EPGDataCache"];
        [fileManager createDirectoryAtPath:self.epgCachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
	return self;
	
}

- (void)registerDefaultsFromSettingsBundle {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if (!bundle) {
        return;
    }

    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[bundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = settings[@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:preferences.count];

    for (NSDictionary *prefSpecification in preferences) {
        NSString *key = prefSpecification[@"Key"];
        if (key) {
            // We can set defaults here as registerDefaults does not overwrite already defined values
            defaultsToRegister[key] = prefSpecification[@"DefaultValue"];
        }
    }

    // Register defaults
    [userDefaults registerDefaults:defaultsToRegister];
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    // iOS 13 and later use appearance for the navigationbar, from iOS 15 this is required as it else defaults to unwanted transparency
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
        appearance.backgroundColor = [Utilities getGrayColor:38 alpha:1.0];
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
    }
    
    // Load user defaults, if not yet set. Avoids need to check for nil.
    [self registerDefaultsFromSettingsBundle];
    
    [self setIdleTimerFromUserDefaults];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    // Set interface style for window
    [self setInterfaceStyleFromUserDefaults];
    
    NSString *filemodeVideoType = @"video";
    NSString *filemodeMusicType = @"music";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"fileType_preference"]) {
        filemodeVideoType = @"files";
        filemodeMusicType = @"files";
    }
    
    obj = [GlobalData getInstance];
    
    int thumbWidth;
    int tvshowHeight;
    CGFloat transform = [Utilities getTransformX];
    if (IS_IPHONE) {
        thumbWidth = (int)(PHONE_TV_SHOWS_BANNER_WIDTH * transform);
        tvshowHeight = (int)(PHONE_TV_SHOWS_BANNER_HEIGHT * transform);
        NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor,
                                                    NSFontAttributeName: [UIFont boldSystemFontOfSize:16]};
        UINavigationBar.appearance.titleTextAttributes = navbarTitleTextAttributes;
    }
    else {
        thumbWidth = (int)(PAD_TV_SHOWS_BANNER_WIDTH * transform);
        tvshowHeight = (int)(PAD_TV_SHOWS_BANNER_HEIGHT * transform);
    }
    
    [self.window makeKeyAndVisible];
    
    mainMenuItems = [NSMutableArray arrayWithCapacity:1];
    __auto_type menu_Music = [mainMenu new];
    __auto_type menu_Movies = [mainMenu new];
    __auto_type menu_Videos = [mainMenu new];
    __auto_type menu_TVShows = [mainMenu new];
    __auto_type menu_Pictures = [mainMenu new];
    __auto_type menu_Favourites = [mainMenu new];
    __auto_type menu_NowPlaying = [mainMenu new];
    __auto_type menu_Remote = [mainMenu new];
    __auto_type menu_Server = [mainMenu new];
    __auto_type menu_LiveTV = [mainMenu new];
    __auto_type menu_Radio = [mainMenu new];
    __auto_type menu_Search = [mainMenu new];

    menu_Music.subItem = [mainMenu new];
    menu_Music.subItem.subItem = [mainMenu new];
    menu_Music.subItem.subItem.subItem = [mainMenu new];

    menu_Movies.subItem = [mainMenu new];
    menu_Movies.subItem.subItem = [mainMenu new];
    
    menu_Videos.subItem = [mainMenu new];
    menu_Videos.subItem.subItem = [mainMenu new];
    
    menu_TVShows.subItem = [mainMenu new];
    menu_TVShows.subItem.subItem = [mainMenu new];
    
    menu_Pictures.subItem = [mainMenu new];
    menu_Pictures.subItem.subItem = [mainMenu new];
    
    menu_LiveTV.subItem = [mainMenu new];
    menu_LiveTV.subItem.subItem = [mainMenu new];
    
    menu_Radio.subItem = [mainMenu new];
    menu_Radio.subItem.subItem = [mainMenu new];

    
#pragma mark - Music
    menu_Music.mainLabel = LOCALIZED_STR(@"Music");
    menu_Music.icon = @"icon_menu_music";
    menu_Music.family = FamilyDetailView;
    menu_Music.enableSection = YES;
    menu_Music.mainButtons = @[
        @"st_album",
        @"st_artist",
        @"st_genre",
        @"st_filemode",
        @"st_music_recently_added",
        @"st_music_recently_added",
        @"st_music_top100",
        @"st_music_top100",
        @"st_music_recently_played",
        @"st_music_recently_played",
        @"st_songs",
        @"st_addons",
        @"st_playlists",
        @"st_music_roles",
    ];
    
    menu_Music.mainMethod = @[
        @[
            @"AudioLibrary.GetAlbums", @"method",
            @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
        ],
        @[
            @"AudioLibrary.GetArtists", @"method",
            @"AudioLibrary.GetArtistDetails", @"extra_info_method",
        ],
        @[
            @"AudioLibrary.GetGenres", @"method",
        ],
        @[
            @"Files.GetSources", @"method",
        ],
        @[
            @"AudioLibrary.GetRecentlyAddedAlbums", @"method",
            @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
        ],
        @[
            @"AudioLibrary.GetRecentlyAddedSongs", @"method",
        ],
        @[
            @"AudioLibrary.GetAlbums", @"method",
            @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
        ],
        @[
            @"AudioLibrary.GetSongs", @"method",
        ],
        @[
            @"AudioLibrary.GetRecentlyPlayedAlbums", @"method",
        ],
        @[
            @"AudioLibrary.GetRecentlyPlayedSongs", @"method",
        ],
        @[
            @"AudioLibrary.GetSongs", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"AudioLibrary.GetRoles", @"method",
        ],
    ];
    
    menu_Music.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"playcount",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"genre",
                        @"description",
                        @"albumlabel",
                        @"fanart",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"art",
                        ],
                },
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Album"),
                        LOCALIZED_STR(@"Artist"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Play count"),
                        LOCALIZED_STR(@"Random"),
                ],
                @"method": @[
                        @"label",
                        @"genre",
                        @"year",
                        @"playcount",
                        @"random",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Albums"), @"label",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            @YES, @"enableLibraryFullScreen",
            [self watchedListenedString], @"watchedListenedStrings",
            [self itemSizes_Musicfullscreen], @"itemSizes",
        ],
            
        @[
            @{
                @"sort": [self sortmethod:@"artist" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"thumbnail",
                        @"genre",
                ]
            }, @"parameters",
            @{
                @"properties": @[
                        @"thumbnail",
                        @"genre",
                        @"instrument",
                        @"style",
                        @"mood",
                        @"born",
                        @"formed",
                        @"description",
                        @"died",
                        @"disbanded",
                        @"yearsactive",
                        @"fanart",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"roles",
                            @"art",
                        ],
                },
            }, @"extra_info_parameters",
            LOCALIZED_STR(@"Artists"), @"label",
            @"nocover_artist", @"defaultThumb",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            @YES, @"enableLibraryFullScreen",
            [self itemSizes_Musicfullscreen], @"itemSizes",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Genres"), @"label",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @0, @"thumbWidth",
            @YES, @"enableLibraryCache",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"music",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"playcount",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"genre",
                        @"description",
                        @"albumlabel",
                        @"fanart",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"art",
                        ],
                },
            }, @"extra_info_parameters",
           LOCALIZED_STR(@"Added Albums"), @"label",
           LOCALIZED_STR(@"Recently added albums"), @"morelabel",
           @YES, @"enableCollectionView",
           [self itemSizes_Music], @"itemSizes",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"album",
                        @"file",
                ],
            }, @"parameters",
           LOCALIZED_STR(@"Added Songs"), @"label",
           LOCALIZED_STR(@"Recently added songs"), @"morelabel",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"playcount" order:@"descending" ignorearticle:NO],
                @"limits": @{
                        @"start": @0,
                        @"end": @100,
                },
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"playcount",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"genre",
                        @"description",
                        @"albumlabel",
                        @"fanart",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Top 100 Albums"),
                        LOCALIZED_STR(@"Album"),
                        LOCALIZED_STR(@"Artist"),
                        LOCALIZED_STR(@"Year"),
                ],
                @"method": @[
                        @"playcount",
                        @"label",
                        @"genre",
                        @"year",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"art",
                        ],
                },
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Top 100 Albums"), @"label",
            LOCALIZED_STR(@"Top 100 Albums"), @"morelabel",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
            
        @[
            @{
                @"sort": [self sortmethod:@"playcount" order:@"descending" ignorearticle:NO],
                @"limits": @{
                        @"start": @0,
                        @"end": @100,
                },
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumid",
                        @"file",
                        @"album",
                ],
            }, @"parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Top 100 Songs"),
                        LOCALIZED_STR(@"Track"),
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Album"),
                        LOCALIZED_STR(@"Artist"),
                        LOCALIZED_STR(@"Rating"),
                        LOCALIZED_STR(@"Year"),
                ],
                @"method": @[
                        @"playcount",
                        @"track",
                        @"label",
                        @"album",
                        @"genre",
                        @"rating",
                        @"year",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Top 100 Songs"), @"label",
            LOCALIZED_STR(@"Top 100 Songs"), @"morelabel",
            @5, @"numberOfStars",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"playcount",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Played albums"), @"label",
            LOCALIZED_STR(@"Recently played albums"), @"morelabel",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"album",
                        @"file",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Played songs"), @"label",
            LOCALIZED_STR(@"Recently played songs"), @"morelabel",
        ],
                            
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"album",
                        @"file",
                ],
            }, @"parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Name"),
                        LOCALIZED_STR(@"Rating"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Play count"),
                        LOCALIZED_STR(@"Track"),
                        LOCALIZED_STR(@"Album"),
                        LOCALIZED_STR(@"Artist"),
                        LOCALIZED_STR(@"Random"),
                ],
                @"method": @[
                        @"label",
                        @"rating",
                        @"year",
                        @"playcount",
                        @"track",
                        @"album",
                        @"genre",
                        @"random",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"All songs"), @"label",
            LOCALIZED_STR(@"All songs"), @"morelabel",
            @YES, @"enableLibraryCache",
            @5, @"numberOfStars",
            [self watchedListenedString], @"watchedListenedStrings",
        ],
                            
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"music",
                @"directory": @"addons://sources/audio",
                @"properties": @[
                        @"thumbnail",
                        @"file",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Music Add-ons"), @"label",
            LOCALIZED_STR(@"Music Add-ons"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"music",
                @"directory": @"special://musicplaylists",
                @"properties": @[
                        @"thumbnail",
                        @"file",
                        @"artist",
                        @"album",
                        @"duration",
                ],
                @"file_properties": @[
                        @"thumbnail",
                        @"file",
                        @"artist",
                        @"album",
                        @"duration",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Music Playlists"), @"label",
            LOCALIZED_STR(@"Music Playlists"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"isMusicPlaylist",
        ],
                            
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                    @"title",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Music Roles"), @"label",
            LOCALIZED_STR(@"Music Roles"), @"morelabel",
            @"nocover_artist", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Music.mainFields = @[
        @{
            @"itemid": @"albums",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"fanart",
            @"row5": @"rating",
            @"row6": @"albumid",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"albumid",
            @"row9": @"albumid",
            @"row10": @"artist",
            @"row11": @"genre",
            @"row12": @"description",
            @"row13": @"albumlabel",
            @"itemid_extra_info": @"albumdetails",
        },
        
        @{
            @"itemid": @"artists",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"yearsactive",
            @"row4": @"genre",
            @"row5": @"disbanded",
            @"row6": @"artistid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"artistid",
            @"row9": @"artistid",
            @"row10": @"formed",
            @"row11": @"artistid",
            @"row12": @"description",
            @"row13": @"instrument",
            @"row14": @"style",
            @"row15": @"mood",
            @"row16": @"born",
            @"row17": @"formed",
            @"row18": @"died",
            @"row19": @"artist",
            @"row20": @"roles",
            @"itemid_extra_info": @"artistdetails",
        },
        
        @{
            @"itemid": @"genres",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"genreid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"genreid",
            @"row9": @"genreid",
        },
        
        @{
            @"itemid": @"sources",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"file",
            @"row9": @"file",
        },
        
        @{
            @"itemid": @"albums",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"fanart",
            @"row5": @"rating",
            @"row6": @"albumid",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"albumid",
            @"row9": @"albumid",
            @"row10": @"artist",
            @"row11": @"genre",
            @"row12": @"description",
            @"row13": @"albumlabel",
            @"itemid_extra_info": @"albumdetails",
        },
                      
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"songid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"artist",
            @"row12": @"album",
            @"row13": @"playcount",
        },
                      
        @{
            @"itemid": @"albums",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"fanart",
            @"row5": @"rating",
            @"row6": @"albumid",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"albumid",
            @"row9": @"albumid",
            @"row10": @"artist",
            @"row11": @"genre",
            @"row12": @"description",
            @"row13": @"albumlabel",
            @"itemid_extra_info": @"albumdetails",
        },
                      
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"songid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"artist",
            @"row12": @"album",
            @"row13": @"duration",
            @"row14": @"rating",
            @"row15": @"playcount",
        },
                      
        @{
            @"itemid": @"albums",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"fanart",
            @"row5": @"rating",
            @"row6": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"albumid",
            @"row9": @"albumid",
            @"row10": @"artist",
        },
                      
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"songid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"artist",
            @"row12": @"album",
        },
                      
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"songid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"artist",
            @"row12": @"album",
            @"row13": @"playcount",
        },
                      
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"file",
            @"row9": @"file",
        },
                      
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                      
        @{
            @"itemid": @"roles",
            @"row1": @"title",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"filetype",
            @"row6": @"roleid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"roleid",
            @"row9": @"roleid",
        },
    ];
    
    menu_Music.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_Music.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Music.defaultThumb = @"nocover_music";
    menu_Music.filterModes = @[
        [self modes_icons_listened],
        [self modes_icons_artiststype],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];

    menu_Music.sheetActions = @[
        [self action_album],
        [self action_artist],
        [self action_filemode_music],
        [self action_queue_to_play],
        [self action_album],
        [self action_queue_to_play],
        [self action_album],
        [self action_queue_to_play],
        [self action_album],
        [self action_queue_to_play],
        [self action_queue_to_play],
        @[],
        [self action_playlist],
        @[],
    ];
    
    menu_Music.subItem.mainMethod = @[
        @[
            @"AudioLibrary.GetSongs", @"method",
            @YES, @"albumView",
        ],
        @[
            @"AudioLibrary.GetAlbums", @"method",
            @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
        ],
        @[
            @"AudioLibrary.GetAlbums", @"method",
            @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"AudioLibrary.GetSongs", @"method",
            @YES, @"albumView",
        ],
        @[],
        @[
            @"AudioLibrary.GetSongs", @"method",
            @YES, @"albumView",
        ],
        @[],
        @[
            @"AudioLibrary.GetSongs", @"method",
            @YES, @"albumView",
        ],
        @[],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
        @[
            @"AudioLibrary.GetArtists", @"method",
            @"AudioLibrary.GetArtistDetails", @"extra_info_method",
        ],
    ];
    
    menu_Music.subItem.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"track" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumartist",
                        @"albumid",
                        @"file",
                        @"fanart",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Songs"), @"label",
        ],
        
        @[
            @{
                @"sort": [self sortmethod:@"year" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"playcount",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"genre",
                        @"description",
                        @"albumlabel",
                        @"fanart",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"art",
                        ],
                },
            }, @"extra_info_parameters",
            LOCALIZED_STR(@"Albums"), @"label",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"playcount",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"genre",
                        @"description",
                        @"albumlabel",
                        @"fanart",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"art",
                        ],
                },
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Album"),
                        LOCALIZED_STR(@"Artist"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Play count"),
                ],
                @"method": @[
                        @"label",
                        @"genre",
                        @"year",
                        @"playcount",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Albums"), @"label",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            [self watchedListenedString], @"watchedListenedStrings",
            [self itemSizes_Music], @"itemSizes",
         ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": filemodeMusicType,
                @"file_properties": @[
                    @"thumbnail",
                    @"art",
                    @"playcount",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"track" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumartist",
                        @"albumid",
                        @"file",
                        @"fanart",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Songs"), @"label",
        ],
                                  
        @[],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"track" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumartist",
                        @"albumid",
                        @"file",
                        @"fanart",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Songs"), @"label",
        ],
                                  
        @[],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"track" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumartist",
                        @"albumid",
                        @"file",
                        @"fanart",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Songs"), @"label",
        ],
                                  
        @[],
        @[],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"file_properties": @[
                    @"thumbnail",
                ],
                @"media": @"music",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Movie], @"itemSizes",
        ],
        
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"file_properties": @[
                        @"thumbnail",
                        @"artist",
                        @"duration",
                ],
                @"media": @"music",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                                  
        @[
            @{
                @"albumartistsonly": @NO,
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"thumbnail",
                        @"genre",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"thumbnail",
                        @"genre",
                        @"instrument",
                        @"style",
                        @"mood",
                        @"born",
                        @"formed",
                        @"description",
                        @"died",
                        @"disbanded",
                        @"yearsactive",
                        @"fanart",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"roles",
                            @"art",
                        ],
                },
            }, @"extra_info_parameters",
            LOCALIZED_STR(@"Artists"), @"label",
            @"nocover_artist", @"defaultThumb",
            @YES, @"enableCollectionView",
            [self itemSizes_Musicfullscreen], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Music.subItem.mainFields = @[
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"albumartist",
        },
                              
        @{
            @"itemid": @"albums",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"fanart",
            @"row5": @"rating",
            @"row6": @"albumid",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"albumid",
            @"row9": @"albumid",
            @"row10": @"artist",
            @"row11": @"genre",
            @"row12": @"description",
            @"row13": @"albumlabel",
            @"itemid_extra_info": @"albumdetails",
        },
                              
        @{
            @"itemid": @"albums",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"fanart",
            @"row5": @"rating",
            @"row6": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"albumid",
            @"row9": @"albumid",
            @"row10": @"playcount",
            @"row11": @"genre",
            @"row12": @"description",
            @"row13": @"albumlabel",
            @"itemid_extra_info": @"albumdetails",
        },
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"albumartist",
        },
                              
        @{},
                              
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"albumartist",
        },
                              
        @{},
                              
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"albumartist",
        },
                              
        @{},
        @{},
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"artists",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"yearsactive",
            @"row4": @"genre",
            @"row5": @"disbanded",
            @"row6": @"artistid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"artistid",
            @"row9": @"artistid",
            @"row10": @"formed",
            @"row11": @"artistid",
            @"row12": @"description",
            @"row13": @"instrument",
            @"row14": @"style",
            @"row15": @"mood",
            @"row16": @"born",
            @"row17": @"formed",
            @"row18": @"died",
            @"row20": @"roles",
            @"itemid_extra_info": @"artistdetails",
        },
    ];
    
    menu_Music.subItem.enableSection = YES;
    menu_Music.subItem.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_Music.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Music.subItem.defaultThumb = @"nocover_music";
    menu_Music.subItem.sheetActions = @[
        [self action_queue_to_play],
        [self action_album],
        [self action_album],
        [self action_filemode_music],
        [self action_queue_to_play],
        @[],
        [self action_queue_to_play],
        @[],
        [self action_queue_to_play],
        @[],
        @[],
        @[],
        [self action_queue_to_play],
        [self action_artist],
    ];
    
    menu_Music.subItem.showRuntime = @[
        @YES,
        @NO,
        @NO,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @NO,
    ];
    
    menu_Music.subItem.subItem.mainMethod = @[
        @[],
        @[
            @"AudioLibrary.GetSongs", @"method",
            @YES, @"albumView",
        ],
        @[
            @"AudioLibrary.GetSongs", @"method",
            @YES, @"albumView",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"AudioLibrary.GetAlbums", @"method",
            @"AudioLibrary.GetAlbumDetails", @"extra_info_method",
        ],
    ];
    
    menu_Music.subItem.subItem.mainParameters = [@[
        @[],

        @[
            @{
                @"sort": [self sortmethod:@"track" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumartist",
                        @"albumid",
                        @"file",
                        @"fanart",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Songs"), @"label",
        ],
          
        @[
            @{
                @"sort": [self sortmethod:@"track" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumartist",
                        @"albumid",
                        @"file",
                        @"fanart",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Songs"), @"label",
        ],
          
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
        ],
        @[
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
        ],
          
        @[
            @{
                @"sort": [self sortmethod:@"year" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"playcount",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"thumbnail",
                        @"artist",
                        @"genre",
                        @"description",
                        @"albumlabel",
                        @"fanart",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                        @"18": @[
                            @"art",
                        ],
                },
            }, @"extra_info_parameters",
            LOCALIZED_STR(@"Albums"), @"label",
            @YES, @"enableCollectionView",
            @"roleid", @"combinedFilter",
            [self itemSizes_Music], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Music.subItem.subItem.mainFields = @[
        @{},
      
        @{
            @"itemid":@"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"albumartist",
        },
                                      
        @{
            @"itemid":@"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"albumartist",
        },
          
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
          
        @{
            @"itemid": @"albums",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"fanart",
            @"row5": @"rating",
            @"row6": @"albumid",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_MUSIC,
            @"row8": @"albumid",
            @"row9": @"albumid",
            @"row10": @"artist",
            @"row11": @"genre",
            @"row12": @"description",
            @"row13": @"albumlabel",
            @"itemid_extra_info": @"albumdetails",
        },
    ];
    
    menu_Music.subItem.subItem.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_Music.subItem.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Music.subItem.subItem.defaultThumb = @"nocover_music";
    menu_Music.subItem.subItem.sheetActions = @[
        @[],
        [self action_queue_to_play],
        [self action_queue_to_play],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        [self action_album],
    ];
    
    menu_Music.subItem.subItem.showRuntime = @[
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @YES,
        @NO,
    ];
    
    menu_Music.subItem.subItem.subItem.mainMethod = @[
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[
            @"AudioLibrary.GetSongs", @"method",
            @YES, @"albumView",
        ],
    ];
    
    menu_Music.subItem.subItem.subItem.mainParameters = [@[
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[
            @{
                @"sort": [self sortmethod:@"track" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"genre",
                        @"year",
                        @"duration",
                        @"track",
                        @"thumbnail",
                        @"rating",
                        @"playcount",
                        @"artist",
                        @"albumartist",
                        @"albumid",
                        @"file",
                        @"fanart",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Songs"), @"label",
        ],
    ] mutableCopy];
    
    menu_Music.subItem.subItem.subItem.mainFields = @[
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{
            @"itemid": @"songs",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"rating",
            @"row6": @"songid",
            @"row7": @"track",
            @"row8": @"albumid",
            @"playlistid": @PLAYERID_MUSIC,
            @"row9": @"songid",
            @"row10": @"file",
            @"row11": @"albumartist",
        },
    ];
    
    menu_Music.subItem.subItem.subItem.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_Music.subItem.subItem.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Music.subItem.subItem.subItem.defaultThumb = @"nocover_music";
    menu_Music.subItem.subItem.subItem.sheetActions = @[
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        [self action_queue_to_play],
    ];
    
    menu_Music.subItem.subItem.subItem.showRuntime = @[
        @YES,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
    ];

#pragma mark - Movies
    menu_Movies.mainLabel = LOCALIZED_STR(@"Movies");
    menu_Movies.icon = @"icon_menu_movies";
    menu_Movies.family = FamilyDetailView;
    menu_Movies.enableSection = YES;
    menu_Movies.noConvertTime = YES;
    menu_Movies.mainButtons = @[
        @"st_movie",
        @"st_movie_genre",
        @"st_movie_set",
        @"st_movie_recently",
        @"st_filemode",
        @"st_addons",
        @"st_playlists",
    ];
    
    menu_Movies.mainMethod = @[
        @[
            @"VideoLibrary.GetMovies", @"method",
            @"VideoLibrary.GetMovieDetails", @"extra_info_method",
        ],
        @[
            @"VideoLibrary.GetGenres", @"method",
        ],
        @[
            @"VideoLibrary.GetMovieSets", @"method",
            @"VideoLibrary.GetMovieSetDetails", @"extra_info_method",
        ],
        @[
            @"VideoLibrary.GetRecentlyAddedMovies", @"method",
            @"VideoLibrary.GetMovieDetails", @"extra_info_method",
        ],
        @[
            @"Files.GetSources", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
    ];
    
    menu_Movies.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"trailer",
                        @"director",
                        @"file",
                        @"dateadded",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"studio",
                        @"director",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"file",
                        @"fanart",
                        @"resume",
                        @"trailer",
                        @"dateadded",
                        @"tagline",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Rating"),
                        LOCALIZED_STR(@"Duration"),
                        LOCALIZED_STR(@"Date added"),
                        LOCALIZED_STR(@"Play count"),
                        LOCALIZED_STR(@"Random"),
                ],
                @"method": @[
                        @"label",
                        @"year",
                        @"rating",
                        @"runtime",
                        @"dateadded",
                        @"playcount",
                        @"random",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Movies"), @"label",
            @YES, @"FrodoExtraArt",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            @YES, @"enableLibraryFullScreen",
            [self itemSizes_Moviefullscreen], @"itemSizes",
        ],
              
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"type": @"movie",
                @"properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Movie Genres"), @"label",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @0, @"thumbWidth",
            @YES, @"enableLibraryCache",
        ],
              
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"thumbnail",
                        @"plot",
                        @"fanart",
                        @"playcount",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                    @"thumbnail",
                    @"plot",
                    @"fanart",
                    @"playcount",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Name"),
                        LOCALIZED_STR(@"Play count"),
                ],
                @"method": @[
                        @"label",
                        @"playcount",
                ],
            }, @"available_sort_methods",
            @YES, @"FrodoExtraArt",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            @"nocover_movie_sets", @"defaultThumb",
            [self itemSizes_Movie], @"itemSizes",
            LOCALIZED_STR(@"Movie Sets"), @"label",
        ],
              
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"trailer",
                        @"fanart",
                        @"file",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Added Movies"), @"label",
            @{
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"studio",
                        @"director",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"file",
                        @"fanart",
                        @"resume",
                        @"trailer",
                        @"dateadded",
                        @"tagline",
                ],
            }, @"extra_info_parameters",
            @YES, @"FrodoExtraArt",
            @YES, @"enableCollectionView",
            @YES, @"collectionViewRecentlyAdded",
            @YES, @"enableLibraryFullScreen",
            [self itemSizes_MovieRecentlyfullscreen], @"itemSizes",
        ],

        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            LOCALIZED_STR(@"Files"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
              
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"directory": @"addons://sources/video",
                @"properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            LOCALIZED_STR(@"Video Add-ons"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],

        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"directory": @"special://videoplaylists",
                @"properties": @[
                        @"thumbnail",
                        @"file",
                ],
                @"file_properties": @[
                        @"thumbnail",
                        @"file",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Playlists"), @"label",
            LOCALIZED_STR(@"Video Playlists"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"isVideoPlaylist",
        ],
    ] mutableCopy];
    
    menu_Movies.mainFields = @[
        @{
            @"itemid": @"movies",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"movieid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"movieid",
            @"row9": @"movieid",
            @"row10": @"playcount",
            @"row11": @"trailer",
            @"row12": @"director",
            @"row13": @"mpaa",
            @"row14": @"votes",
            @"row15": @"studio",
            @"row16": @"cast",
            @"row7": @"file",
            @"row17": @"plot",
            @"row18": @"resume",
            @"row19": @"dateadded",
            @"row20": @"tagline",
            @"itemid_extra_info": @"moviedetails",
        },
                      
        @{
            @"itemid": @"genres",
            @"row1": @"label",
            @"row2": @"label",
            @"row3": @"disable",
            @"row4": @"disable",
            @"row5": @"disable",
            @"row6": @"genre",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"genreid",
        },
                      
        @{
            @"itemid": @"sets",
            @"row1": @"label",
            @"row2": @"disable",
            @"row3": @"disable",
            @"row4": @"disable",
            @"row5": @"disable",
            @"row6": @"setid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"setid",
            @"row9": @"setid",
            @"row10": @"playcount",
            @"row11": @"plot",
            @"itemid_extra_info": @"setdetails",
        },

        @{
            @"itemid": @"movies",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"movieid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"movieid",
            @"row9": @"movieid",
            @"row10": @"playcount",
            @"row11": @"trailer",
            @"row12": @"plot",
            @"row13": @"mpaa",
            @"row14": @"votes",
            @"row15": @"studio",
            @"row16": @"cast",
            @"row7": @"file",
            @"row17": @"director",
            @"row18": @"resume",
            @"row19": @"dateadded",
            @"row20": @"tagline",
            @"itemid_extra_info": @"moviedetails",
        },
                      
        @{
            @"itemid": @"sources",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
        },
                      
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
        },
                      
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
            //@"row11": @"filetype",
        },
    ];
    
    menu_Movies.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Movies.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Movies.defaultThumb = @"nocover_movies";
    menu_Movies.sheetActions = @[
        [self action_movie],
        @[],
        @[LOCALIZED_STR(@"Movie Set Details")],
        [self action_movie],
        [self action_queue_to_play],
        @[],
        [self action_playlist],
    ];
    
    menu_Movies.showInfo = @[
        @YES,
        @NO,
        @NO,
        @YES,
        @NO,
        @NO,
        @NO,
    ];
    
    menu_Movies.filterModes = @[
        [self modes_icons_watched],
        [self modes_icons_empty],
        [self modes_icons_watched],
        [self modes_icons_watched],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];
    
    menu_Movies.subItem.mainMethod = [@[
        @[],
        @[
            @"VideoLibrary.GetMovies", @"method",
            @"VideoLibrary.GetMovieDetails", @"extra_info_method",
        ],
        @[
            @"VideoLibrary.GetMovies", @"method",
            @"VideoLibrary.GetMovieDetails", @"extra_info_method",
        ],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
    ] mutableCopy];
    
    menu_Movies.subItem.noConvertTime = YES;

    menu_Movies.subItem.mainParameters = [@[
        @[],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"trailer",
                        @"file",
                        @"dateadded",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"studio",
                        @"director",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"file",
                        @"fanart",
                        @"resume",
                        @"trailer",
                        @"dateadded",
                        @"tagline",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Rating"),
                        LOCALIZED_STR(@"Duration"),
                        LOCALIZED_STR(@"Date added"),
                        LOCALIZED_STR(@"Play count"),
                ],
                @"method": @[
                        @"label",
                        @"year",
                        @"rating",
                        @"runtime",
                        @"dateadded",
                        @"playcount",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Movies"), @"label",
            @"nocover_movies", @"defaultThumb",
            @YES, @"FrodoExtraArt",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            [self itemSizes_Movie], @"itemSizes",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"year" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"trailer",
                        @"file",
                        @"dateadded",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"studio",
                        @"director",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"file",
                        @"fanart",
                        @"resume",
                        @"trailer",
                        @"dateadded",
                        @"tagline",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Rating"),
                        LOCALIZED_STR(@"Duration"),
                        LOCALIZED_STR(@"Date added"),
                        LOCALIZED_STR(@"Play count"),
                ],
                @"method": @[
                        @"label",
                        @"year",
                        @"rating",
                        @"runtime",
                        @"dateadded",
                        @"playcount",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Movies"), @"label",
            @"nocover_movies", @"defaultThumb",
            @YES, @"FrodoExtraArt",
            @YES, @"enableCollectionView",
            [self itemSizes_Movie], @"itemSizes",
        ],
                                  
        @[],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": filemodeVideoType,
                @"file_properties": @[
                    @"thumbnail",
                    @"art",
                    @"playcount",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"file_properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"file_properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"trailer",
                        @"file",
                        @"dateadded",
                        @"uniqueid",
                        @"studio",
                        @"director",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"fanart",
                        @"resume",
                        @"tagline",
                ],
                @"media": @"video",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @PORTRAIT_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            @YES, @"FrodoExtraArt",
            [self itemSizes_Movie], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Movies.subItem.mainFields = @[
        @{},
                              
        @{
            @"itemid": @"movies",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"movieid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"movieid",
            @"row9": @"movieid",
            @"row10": @"playcount",
            @"row11": @"trailer",
            @"row12": @"plot",
            @"row13": @"mpaa",
            @"row14": @"votes",
            @"row15": @"studio",
            @"row16": @"cast",
            @"row7": @"file",
            @"row17": @"director",
            @"row18": @"resume",
            @"row19": @"dateadded",
            @"row20": @"tagline",
            @"itemid_extra_info": @"moviedetails",
        },
                              
        @{
            @"itemid": @"movies",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"movieid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"movieid",
            @"row9": @"movieid",
            @"row10": @"playcount",
            @"row11": @"trailer",
            @"row12": @"plot",
            @"row13": @"mpaa",
            @"row14": @"votes",
            @"row15": @"studio",
            @"row16": @"cast",
            @"row7": @"file",
            @"row17": @"director",
            @"row18": @"resume",
            @"row19": @"dateadded",
            @"row20": @"tagline",
            @"itemid_extra_info": @"moviedetails",
        },
                              
        @{},
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"row7": @"plugin",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"uniqueid",
            @"row9": @"file",
            @"row10": @"playcount",
            @"row11": @"trailer",
            @"row12": @"plot",
            @"row13": @"mpaa",
            @"row14": @"votes",
            @"row15": @"studio",
            @"row16": @"cast",
            @"row7": @"file",
            @"row17": @"director",
            @"row18": @"resume",
            @"row19": @"dateadded",
            //@"itemid_extra_info": @"moviedetails",
            @"row20": @"tagline",
        },
    ];
    
    menu_Movies.subItem.enableSection = YES;
    menu_Movies.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Movies.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Movies.subItem.defaultThumb = @"nocover_movies";
    menu_Movies.subItem.sheetActions = @[
        @[],
        [self action_movie],
        [self action_movie],
        @[],
        [self action_queue_to_play],
        @[],
        [self action_queue_to_play],
    ];
    
    menu_Movies.subItem.showInfo = @[
        @NO,
        @YES,
        @YES,
        @NO,
        @NO,
        @NO,
        @NO,
    ];
    
    menu_Movies.subItem.filterModes = @[
        [self modes_icons_empty],
        [self modes_icons_watched],
        [self modes_icons_watched],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];

    menu_Movies.subItem.subItem.noConvertTime = YES;
    menu_Movies.subItem.subItem.mainMethod = [@[
        @[],
        @[],
        @[],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
    ] mutableCopy];
    
    menu_Movies.subItem.subItem.mainParameters = [@[
        @[],
        @[],
        @[],
        @[],
        @[],
        @[
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
        @[],
    ] mutableCopy];
    
    menu_Movies.subItem.subItem.mainFields = @[
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
        @{},
    ];
    
    menu_Movies.subItem.subItem.enableSection = NO;
    menu_Movies.subItem.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Movies.subItem.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Movies.subItem.subItem.defaultThumb = @"nocover_filemode";
    menu_Movies.subItem.subItem.sheetActions = @[
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
        @[],
    ];
    
#pragma mark - Videos
    menu_Videos.mainLabel = LOCALIZED_STR(@"Videos");
    menu_Videos.icon = @"icon_menu_videos";
    menu_Videos.family = FamilyDetailView;
    menu_Videos.enableSection = YES;
    menu_Videos.noConvertTime = YES;
    menu_Videos.mainButtons = @[
        @"st_music_videos",
        @"st_movie_recently",
        @"st_filemode",
        @"st_addons",
        @"st_playlists",
    ];
    
    menu_Videos.mainMethod = @[
        @[
            @"VideoLibrary.GetMusicVideos", @"method",
            @"VideoLibrary.GetMusicVideoDetails", @"extra_info_method",
        ],
        @[
            @"VideoLibrary.GetRecentlyAddedMusicVideos", @"method",
            @"VideoLibrary.GetMusicVideoDetails", @"extra_info_method",
        ],
        @[
            @"Files.GetSources", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
    ];
    
    menu_Videos.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"artist",
                        @"year",
                        @"playcount",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"studio",
                        @"director",
                        @"plot",
                        @"file",
                        @"fanart",
                        @"resume",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"artist",
                        @"year",
                        @"playcount",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"studio",
                        @"director",
                        @"plot",
                        @"file",
                        @"fanart",
                        @"resume",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                    @"18": @[
                        @"art",
                    ],
                },
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Artist"),
                        LOCALIZED_STR(@"Genre"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Play count"),
                        LOCALIZED_STR(@"Random"),
                ],
                @"method": @[
                            @"label",
                            @"artist",
                            @"genre",
                            @"year",
                            @"playcount",
                            @"random",
                ],
            }, @"available_sort_methods",
            @{
                @"18": @[
                    @"art",
                ],
            }, @"kodiExtrasPropertiesMinimumVersion",
            LOCALIZED_STR(@"Music Videos"), @"label",
            LOCALIZED_STR(@"Music Videos"), @"morelabel",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            @YES, @"enableLibraryFullScreen",
            [self itemSizes_Moviefullscreen], @"itemSizes",
        ],
              
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                                @"artist",
                                @"year",
                                @"playcount",
                                @"thumbnail",
                                @"genre",
                                @"runtime",
                                @"studio",
                                @"director",
                                @"plot",
                                @"file",
                                @"fanart",
                                @"resume",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"artist",
                        @"year",
                        @"playcount",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"studio",
                        @"director",
                        @"plot",
                        @"file",
                        @"fanart",
                        @"resume",
                ],
                @"kodiExtrasPropertiesMinimumVersion": @{
                    @"18": @[
                        @"art",
                    ],
                },
            }, @"extra_info_parameters",
            @{
                @"18": @[
                    @"art",
                ],
            }, @"kodiExtrasPropertiesMinimumVersion",
            LOCALIZED_STR(@"Added Music Videos"), @"label",
            @YES, @"enableCollectionView",
            @YES, @"collectionViewRecentlyAdded",
            @YES, @"enableLibraryFullScreen",
            [self itemSizes_MovieRecentlyfullscreen], @"itemSizes",
        ],
        
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            LOCALIZED_STR(@"Files"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
              
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"directory": @"addons://sources/video",
                @"properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            LOCALIZED_STR(@"Video Add-ons"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],

        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"directory": @"special://videoplaylists",
                @"properties": @[
                        @"thumbnail",
                        @"file",
                ],
                @"file_properties": @[
                        @"thumbnail",
                        @"file",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Playlists"), @"label",
            LOCALIZED_STR(@"Video Playlists"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"isVideoPlaylist",
        ],
    ] mutableCopy];
    
    menu_Videos.mainFields = @[
        @{
            @"itemid": @"musicvideos",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"musicvideoid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"musicvideoid",
            @"row9": @"musicvideoid",
            @"row10": @"director",
            @"row11": @"artist",
            @"row12": @"plot",
            @"row13": @"playcount",
            @"row14": @"resume",
            @"row15": @"votes",
            @"row16": @"artist",
            @"row7": @"file",
            @"itemid_extra_info": @"musicvideodetails",
        },
        
        @{
            @"itemid": @"musicvideos",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"musicvideoid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"musicvideoid",
            @"row9": @"musicvideoid",
            @"row10": @"director",
            @"row11": @"artist",
            @"row12": @"plot",
            @"row13": @"playcount",
            @"row14": @"resume",
            @"row15": @"votes",
            @"row16": @"artist",
            @"row7": @"file",
            @"itemid_extra_info": @"musicvideodetails",
        },
        
        @{
            @"itemid": @"sources",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
        },
                      
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
        },
                      
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
            //@"row11": @"filetype",
        },
    ];
    
    menu_Videos.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Videos.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Videos.defaultThumb = @"nocover_musicvideos";
    menu_Videos.sheetActions = @[
        [self action_musicvideo],
        [self action_musicvideo],
        [self action_queue_to_play],
        @[],
        [self action_playlist],
    ];
    
    menu_Videos.showInfo = @[
        @YES,
        @YES,
        @NO,
        @NO,
        @NO,
    ];
    
    menu_Videos.filterModes = @[
        [self modes_icons_watched],
        [self modes_icons_watched],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];
    
    menu_Videos.subItem.mainMethod = [@[
        @[],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
    ] mutableCopy];
    
    menu_Videos.subItem.noConvertTime = YES;

    menu_Videos.subItem.mainParameters = [@[
        @[],
        @[],
        
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": filemodeVideoType,
                @"file_properties": @[
                    @"thumbnail",
                    @"art",
                    @"playcount",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"file_properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"file_properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"trailer",
                        @"file",
                        @"dateadded",
                        @"uniqueid",
                        @"studio",
                        @"director",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"fanart",
                        @"resume",
                ],
                @"media": @"video",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @PORTRAIT_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            @YES, @"FrodoExtraArt",
            [self itemSizes_Movie], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Videos.subItem.mainFields = @[
        @{},
        @{},
        
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"row7": @"plugin",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"uniqueid",
            @"row9": @"file",
            @"row10": @"playcount",
            @"row11": @"trailer",
            @"row12": @"plot",
            @"row13": @"mpaa",
            @"row14": @"votes",
            @"row15": @"studio",
            @"row16": @"cast",
            @"row7": @"file",
            @"row17": @"director",
            @"row18": @"resume",
            @"row19": @"dateadded",
            //@"itemid_extra_info": @"moviedetails",
        },
    ];
    
    menu_Videos.subItem.enableSection = YES;
    menu_Videos.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Videos.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Videos.subItem.defaultThumb = @"nocover_musicvideos";
    menu_Videos.subItem.sheetActions = @[
        @[],
        @[],
        [self action_queue_to_play],
        @[],
        [self action_queue_to_play],
    ];
    
    menu_Videos.subItem.filterModes = @[
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];

    menu_Videos.subItem.subItem.noConvertTime = YES;
    menu_Videos.subItem.subItem.mainMethod = [@[
        @[],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
    ] mutableCopy];
    
    menu_Videos.subItem.subItem.mainParameters = [@[
        @[],
        @[],
        @[],
        @[
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
        @[],
    ] mutableCopy];
    
    menu_Videos.subItem.subItem.mainFields = @[
        @{},
        @{},
        @{},
        @{},
        @{},
    ];
    
    menu_Videos.subItem.subItem.enableSection = NO;
    menu_Videos.subItem.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Videos.subItem.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Videos.subItem.subItem.defaultThumb = @"nocover_filemode";
    menu_Videos.subItem.subItem.sheetActions = @[
        @[],
        @[],
        @[],
        @[],
        @[],
    ];
    
#pragma mark - TV Shows
    menu_TVShows.mainLabel = LOCALIZED_STR(@"TV Shows");
    menu_TVShows.icon = @"icon_menu_tvshows";
    menu_TVShows.family = FamilyDetailView;
    menu_TVShows.enableSection = YES;
    menu_TVShows.mainButtons = @[
        @"st_tv",
        @"st_tv_recently",
        @"st_filemode",
        @"st_addons",
        @"st_playlists",
    ];
    
    menu_TVShows.mainMethod = [@[
        @[  @"VideoLibrary.GetTVShows", @"method",
            @"VideoLibrary.GetTVShowDetails", @"extra_info_method",
            @YES, @"tvshowsView",
        ],
        @[
            @"VideoLibrary.GetRecentlyAddedEpisodes", @"method",
            @"VideoLibrary.GetEpisodeDetails", @"extra_info_method",
        ],
        @[
            @"Files.GetSources", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
    ] mutableCopy];
    
    menu_TVShows.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"studio",
                        @"episode",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"studio",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"premiered",
                        @"episode",
                        @"fanart",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Year"),
                        LOCALIZED_STR(@"Rating"),
                        LOCALIZED_STR(@"Random"),
                ],
                @"method": @[
                        @"label",
                        @"year",
                        @"rating",
                        @"random",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"TV Shows"), @"label",
            @YES, @"blackTableSeparator",
            @YES, @"FrodoExtraArt",
            @YES, @"enableLibraryCache",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryFullScreen",
            [self itemSizes_Moviefullscreen], @"itemSizes",
        ],
                            
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"episode",
                        @"thumbnail",
                        @"firstaired",
                        @"playcount",
                        @"showtitle",
                        @"file",
                        @"title",
                        @"season",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"episode",
                        @"thumbnail",
                        @"firstaired",
                        @"runtime",
                        @"plot",
                        @"director",
                        @"writer",
                        @"rating",
                        @"title",
                        @"showtitle",
                        @"season",
                        @"cast",
                        @"file",
                        @"fanart",
                        @"playcount",
                        @"resume",
                ],
            }, @"extra_info_parameters",
            LOCALIZED_STR(@"Added Episodes"), @"label",
            @DEFAULT_ROW_HEIGHT, @"rowHeight",
            @EPISODE_THUMB_WIDTH, @"thumbWidth",
            @"nocover_tvshows_episode", @"defaultThumb",
            @YES, @"FrodoExtraArt",
            //@YES, @"enableCollectionView",
            [self itemSizes_TVShowsfullscreen], @"itemSizes",
        ],
                            
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                            
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"directory": @"addons://sources/video",
                @"properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            LOCALIZED_STR(@"Video Add-ons"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
        
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"directory": @"special://videoplaylists",
                @"properties": @[
                        @"thumbnail",
                        @"file",
                ],
                @"file_properties": @[
                        @"thumbnail",
                        @"file",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Playlists"), @"label",
            LOCALIZED_STR(@"Video Playlists"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"isVideoPlaylist",
        ],
    ] mutableCopy];

    menu_TVShows.mainFields = @[
        @{
            @"itemid": @"tvshows",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"studio",
            @"row5": @"rating",
            @"row6": @"tvshowid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"tvshowid",
            @"row9": @"playcount",
            @"row10": @"mpaa",
            @"row11": @"votes",
            @"row12": @"cast",
            @"row13": @"premiered",
            @"row14": @"episode",
            //@"row7": @"fanart",
            @"row15": @"plot",
            @"row16": @"studio",
            @"itemid_extra_info": @"tvshowdetails",
        },

        @{
            @"itemid": @"episodes",
            @"row1": @"title",
            @"row2": @"showtitle",
            @"row3": @"firstaired",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"episodeid",
            @"row7": @"playcount",
            @"row8": @"episodeid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row9": @"episodeid",
            @"row10": @"season",
            @"row11": @"episode",
            @"row12": @"writer",
            @"row13": @"resume",
            @"row14": @"showtitle",
            @"row15": @"plot",
            @"row16": @"cast",
            @"row17": @"firstaired",
            @"row18": @"season",
            //@"row20": @"file",
            //@"row7": @"file",
            @"itemid_extra_info": @"episodedetails",
        },
                        
        @{
            @"itemid": @"sources",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
        },
                        
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
        },
        
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"artist",
            @"row3": @"year",
            @"row4": @"duration",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
            //@"row11": @"filetype",
        },
    ];
    
    menu_TVShows.rowHeight = tvshowHeight;
    menu_TVShows.thumbWidth = thumbWidth;
    menu_TVShows.defaultThumb = @"nocover_tvshows";
    menu_TVShows.sheetActions = @[
        @[LOCALIZED_STR(@"TV Show Details")],
        [self action_episode],
        [self action_queue_to_play],
        @[],
        [self action_playlist],
    ];
    
    menu_TVShows.showInfo = @[
        @NO,
        @YES,
        @NO,
        @NO,
        @NO,
    ];
    
    menu_TVShows.filterModes = @[
        [self modes_icons_watched],
        [self modes_icons_watched],
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];
    
    menu_TVShows.subItem.mainMethod = [@[
        @[
            @"VideoLibrary.GetEpisodes", @"method",
            @"VideoLibrary.GetEpisodeDetails", @"extra_info_method",
            @YES, @"episodesView",
            @"VideoLibrary.GetSeasons", @"extra_section_method",
        ],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
    ] mutableCopy];
    
    menu_TVShows.subItem.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"episode" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"episode",
                        @"thumbnail",
                        @"firstaired",
                        @"showtitle",
                        @"playcount",
                        @"season",
                        @"tvshowid",
                        @"runtime",
                        @"file",
                        @"title",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"episode",
                        @"thumbnail",
                        @"firstaired",
                        @"runtime",
                        @"plot",
                        @"director",
                        @"writer",
                        @"rating",
                        @"title",
                        @"showtitle",
                        @"season",
                        @"cast",
                        @"fanart",
                        @"resume",
                        @"playcount",
                        @"file",
                ],
            }, @"extra_info_parameters",
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"season",
                        @"thumbnail",
                        @"tvshowid",
                        @"playcount",
                        @"episode",
                        @"art",
                ],
            }, @"extra_section_parameters",
            LOCALIZED_STR(@"Episodes"), @"label",
            @YES, @"disableFilterParameter",
            @YES, @"FrodoExtraArt",
        ],

        @[],
                                    
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": filemodeVideoType,
                @"file_properties": @[
                    @"thumbnail",
                    @"art",
                    @"playcount",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                                    
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"media": @"video",
                @"file_properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
        
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"file_properties": @[
                        @"year",
                        @"playcount",
                        @"rating",
                        @"thumbnail",
                        @"genre",
                        @"runtime",
                        @"trailer",
                        @"file",
                        @"dateadded",
                        @"uniqueid",
                        @"studio",
                        @"director",
                        @"plot",
                        @"mpaa",
                        @"votes",
                        @"cast",
                        @"fanart",
                        @"resume",
                ],
                @"media": @"video",
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @PORTRAIT_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            @YES, @"FrodoExtraArt",
            [self itemSizes_Movie], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_TVShows.subItem.mainFields = @[
        @{
            @"itemid": @"episodes",
            @"row1": @"title",
            @"row2": @"showtitle",
            @"row3": @"firstaired",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"episodeid",
            @"row7": @"playcount",
            @"row8": @"episodeid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row9": @"episodeid",
            @"row10": @"season",
            @"row11": @"tvshowid",
            @"row12": @"file",
            @"row13": @"writer",
            @"row14": @"firstaired",
            @"row15": @"showtitle",
            @"row16": @"cast",
            @"row17": @"director",
            @"row18": @"resume",
            @"row19": @"episode",
            @"row20": @"plot",
            @"itemid_extra_info": @"episodedetails",
            @"itemid_extra_section": @"seasons",
        },

        @[],
                                
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"row7": @"playcount",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                                
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"row7": @"plugin",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
        
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"genre",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"uniqueid",
            @"row9": @"file",
            @"row10": @"playcount",
            @"row11": @"trailer",
            @"row12": @"plot",
            @"row13": @"mpaa",
            @"row14": @"votes",
            @"row15": @"studio",
            @"row16": @"cast",
            @"row7": @"file",
            @"row17": @"director",
            @"row18": @"resume",
            @"row19": @"dateadded",
            //@"itemid_extra_info": @"moviedetails",
        },
    ];
    
    menu_TVShows.subItem.enableSection = YES;
    menu_TVShows.subItem.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_TVShows.subItem.thumbWidth = EPISODE_THUMB_WIDTH;
    menu_TVShows.subItem.defaultThumb = @"nocover_tvshows_episode";
    menu_TVShows.subItem.sheetActions = @[
        [self action_episode],
        @[],
        [self action_queue_to_play],
        @[],
        [self action_queue_to_play],
    ];
    
    menu_TVShows.subItem.showRuntime = @[
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
    ];
    
    menu_TVShows.subItem.noConvertTime = YES;
    menu_TVShows.subItem.showInfo = @[
        @YES,
        @NO,
        @NO,
        @NO,
        @NO,
    ];
    
    menu_TVShows.subItem.subItem.mainMethod = [@[
        @[],
        @[],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[],
    ] mutableCopy];
                                        
    menu_TVShows.subItem.subItem.mainParameters = [@[
        @[],
        @[],
        @[],
        @[
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
        @[],
    ] mutableCopy];
    
    menu_TVShows.subItem.subItem.mainFields = @[
        @[],
        @[],
        @[],
        @[],
        @[],
    ];
        
    menu_TVShows.subItem.subItem.enableSection = NO;
    menu_TVShows.subItem.subItem.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_TVShows.subItem.subItem.thumbWidth = EPISODE_THUMB_WIDTH;
    menu_TVShows.subItem.subItem.defaultThumb = @"nocover_tvshows_episode";
    menu_TVShows.subItem.subItem.sheetActions = @[
        @[],
        @[],
        @[],
        @[],
        @[],
    ];
        
    menu_TVShows.subItem.subItem.showRuntime = @[
        @NO,
        @NO,
        @NO,
        @NO,
        @NO,
    ];
        
    menu_TVShows.subItem.subItem.noConvertTime = YES;

#pragma mark - Live TV
    menu_LiveTV.mainLabel = LOCALIZED_STR(@"Live TV");
    menu_LiveTV.icon = @"icon_menu_livetv";
    menu_LiveTV.family = FamilyDetailView;
    menu_LiveTV.enableSection = YES;
    menu_LiveTV.noConvertTime = YES;
    menu_LiveTV.mainButtons = @[
        @"st_channels",
        @"st_livetv",
        @"st_recordings",
        @"st_timers",
        @"st_timerrules",
    ];
    
    menu_LiveTV.mainMethod = [@[
        @[
            @"PVR.GetChannels", @"method",
            @YES, @"channelListView",
        ],
        @[
            @"PVR.GetChannelGroups", @"method",
        ],
        @[
            @"PVR.GetRecordings", @"method",
            @"PVR.GetRecordingDetails", @"extra_info_method",
        ],
        @[
            @"PVR.GetTimers", @"method",
        ],
        @[
            @"PVR.GetTimers", @"method",
        ],
    ] mutableCopy];
    
    menu_LiveTV.mainParameters = [@[
        @[
            @{
                @"channelgroupid": @"alltv",
                @"properties": @[
                        @"thumbnail",
                        @"channelnumber",
                        @"channel",
                ],
            }, @"parameters",
            @{
                @"17": @[
                    @"isrecording",
                ],
            }, @"kodiExtrasPropertiesMinimumVersion",
            LOCALIZED_STR(@"All channels"), @"label",
            @"nocover_channels", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @LIVETV_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH_SMALL, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                          
        @[
            @{
                @"channeltype": @"tv",
            }, @"parameters",
            LOCALIZED_STR(@"Channel Groups"), @"label",
            LOCALIZED_STR(@"Channel Groups"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],

        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"genre",
                        @"playcount",
                        @"resume",
                        @"channel",
                        @"runtime",
                        @"lifetime",
                        @"icon",
                        @"art",
                        @"streamurl",
                        @"file",
                        @"radio",
                        @"directory",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"genre",
                        @"playcount",
                        @"resume",
                        @"channel",
                        @"runtime",
                        @"lifetime",
                        @"icon",
                        @"art",
                        @"streamurl",
                        @"file",
                        @"directory",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Channel"),
                        LOCALIZED_STR(@"Date"),
                        LOCALIZED_STR(@"Play count"),
                        LOCALIZED_STR(@"Runtime"),
                        LOCALIZED_STR(@"Random"),
                ],
                @"method": @[
                        @"label",
                        @"channel",
                        @"starttime",
                        @"playcount",
                        @"runtime",
                        @"random",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Recordings"), @"label",
            LOCALIZED_STR(@"Recordings"), @"morelabel",
            @"nocover_recording", @"defaultThumb",
            @CHANNEL_EPG_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH_SMALL, @"thumbWidth",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            [self itemSizes_Music], @"itemSizes",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"title",
                        @"summary",
                        @"channelid",
                        @"isradio",
                        @"istimerrule",
                        @"starttime",
                        @"endtime",
                        @"runtime",
                        @"lifetime",
                        @"firstday",
                        @"weekdays",
                        @"priority",
                        @"startmargin",
                        @"endmargin",
                        @"state",
                        @"file",
                        @"isreminder",
                        @"directory",
                ],
            }, @"parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Date"),
                        LOCALIZED_STR(@"Runtime"),
                ],
                @"method": @[
                        @"label",
                        @"starttime",
                        @"runtime",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Timers"), @"label",
            LOCALIZED_STR(@"Timers"), @"morelabel",
            @"nocover_timers", @"defaultThumb",
            @DEFAULT_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
        
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"title",
                        @"summary",
                        @"channelid",
                        @"isradio",
                        @"istimerrule",
                        @"starttime",
                        @"endtime",
                        @"runtime",
                        @"lifetime",
                        @"firstday",
                        @"weekdays",
                        @"priority",
                        @"startmargin",
                        @"endmargin",
                        @"state",
                        @"file",
                        @"isreminder",
                        @"directory",
                ],
            }, @"parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Date"),
                        LOCALIZED_STR(@"Runtime"),
                ],
                @"method": @[
                        @"label",
                        @"starttime",
                        @"runtime",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Timer rules"), @"label",
            LOCALIZED_STR(@"Timer rules"), @"morelabel",
            @"nocover_timerrules", @"defaultThumb",
            @DEFAULT_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_LiveTV.mainFields = @[
        @{
            @"itemid": @"channels",
            @"row1": @"channel",
            @"row2": @"starttime",
            @"row3": @"endtime",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"channelid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"channelid",
            @"row9": @"isrecording",
            @"row10": @"channelnumber",
            @"row11": @"type",
        },
                      
        @{
            @"itemid": @"channelgroups",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"channelgroupid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"channelgroupid",
            @"row9": @"channelgroupid",
        },

        @{
            @"itemid": @"recordings",
            @"row1": @"label",
            @"row2": @"plotoutline",
            @"row3": @"plot",
            @"row4": @"runtime",
            @"row5": @"starttime",
            @"row6": @"recordingid",
            @"row7": @"radio",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"recordingid",
            @"row9": @"recordingid",
            @"row10": @"file",
            @"row11": @"channel",
            @"row12": @"starttime",
            @"row13": @"endtime",
            @"row14": @"playcount",
            @"row15": @"plot",
            @"itemid_extra_info": @"recordingdetails",
        },
                      
        @{
            @"itemid": @"timers",
            @"row1": @"label",
            @"row2": @"summary",
            @"row3": @"plot",
            @"row4": @"runtime",
            @"row5": @"starttime",
            @"row6": @"timerid",
            @"row7": @"isreminder",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"timerid",
            @"row9": @"istimerrule",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row15": @"isradio",
        },
        
        @{
            @"itemid": @"timers",
            @"row1": @"label",
            @"row2": @"summary",
            @"row3": @"plot",
            @"row4": @"runtime",
            @"row5": @"starttime",
            @"row6": @"timerid",
            @"row7": @"isreminder",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"timerid",
            @"row9": @"istimerrule",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row15": @"isradio",
        },
    ];
    
    menu_LiveTV.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_LiveTV.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_LiveTV.defaultThumb = @"nocover_channels";
    menu_LiveTV.sheetActions = @[
        [self action_channel],
        @[],
        [self action_queue_to_play],
        @[LOCALIZED_STR(@"Delete timer")],
        @[LOCALIZED_STR(@"Delete timer")],
    ];
    
    menu_LiveTV.showInfo = @[
        @NO,
        @NO,
        @YES,
        @NO,
        @NO,
    ];
    
    menu_LiveTV.filterModes = @[
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_watched],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];
    
    menu_LiveTV.subItem.mainMethod = [@[
        @[
            @"PVR.GetBroadcasts", @"method",
            @YES, @"channelGuideView",
        ],
        @[
            @"PVR.GetChannels", @"method",
            @YES, @"channelListView",
        ],
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_LiveTV.subItem.noConvertTime = YES;
    
    menu_LiveTV.subItem.mainParameters = [@[
        @[
            @{
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"progresspercentage",
                        @"isactive",
                        @"hastimer",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Live TV"), @"label",
            @"icon_video", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @CHANNEL_EPG_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
            @YES, @"forceActionSheet",
        ],
                                  
        @[
            @{
                @"properties": @[
                        @"thumbnail",
                        @"channelnumber",
                        @"channel",
                ],
            }, @"parameters",
            @{
                @"17": @[
                    @"isrecording",
                ],
            }, @"kodiExtrasPropertiesMinimumVersion",
            LOCALIZED_STR(@"Live TV"), @"label",
            @"nocover_channels", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @LIVETV_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH_SMALL, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                                  
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_LiveTV.subItem.mainFields = @[
        @{
            @"itemid": @"broadcasts",
            @"row1": @"title",
            @"row2": @"plot",
            @"row3": @"broadcastid",
            @"row4": @"broadcastid",
            @"row5": @"starttime",
            @"row6": @"broadcastid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"broadcastid",
            @"row9": @"plotoutline",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row12": @"progresspercentage",
            @"row13": @"isactive",
            @"row14": @"title",
            @"row15": @"hastimer",
        },
                              
        @{
            @"itemid": @"channels",
            @"row1": @"channel",
            @"row2": @"starttime",
            @"row3": @"endtime",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"channelid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"channelid",
            @"row9": @"channelid",
            @"row10": @"channelnumber",
            @"row11": @"type",
        },
                              
        @{},
        @{},
        @{},
    ];
    
    menu_LiveTV.subItem.enableSection = NO;
    menu_LiveTV.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_LiveTV.subItem.thumbWidth = LIVETV_THUMB_WIDTH;
    menu_LiveTV.subItem.defaultThumb = @"nocover_channels";
    menu_LiveTV.subItem.sheetActions = @[
        [self action_broadcast],
        [self action_channel],
        @[],
        @[],
        @[],
    ];
    
    menu_LiveTV.subItem.filterModes = @[
        [self modes_icons_empty],
        [self modes_icons_empty],
        @{},
        @{},
        @{},
    ];
    
    menu_LiveTV.subItem.subItem.noConvertTime = YES;
    menu_LiveTV.subItem.subItem.mainMethod = [@[
        @[],
        @[
            @"PVR.GetBroadcasts", @"method",
            @YES, @"channelGuideView",
        ],
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_LiveTV.subItem.subItem.mainParameters = [@[
        @[],
                                            
         @[
            @{
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"progresspercentage",
                        @"isactive",
                        @"hastimer",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Live TV"), @"label",
            @"icon_video", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @CHANNEL_EPG_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
            @YES, @"forceActionSheet",
        ],
                                            
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_LiveTV.subItem.subItem.mainFields = @[
        @{},
                                        
        @{
            @"itemid": @"broadcasts",
            @"row1": @"title",
            @"row2": @"plot",
            @"row3": @"broadcastid",
            @"row4": @"broadcastid",
            @"row5": @"starttime",
            @"row6": @"broadcastid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"broadcastid",
            @"row9": @"plotoutline",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row12": @"progresspercentage",
            @"row13": @"isactive",
            @"row14": @"title",
            @"row15": @"hastimer",
        },
                                        
        @[],
        @[],
        @[],
    ];
    
    menu_LiveTV.subItem.subItem.enableSection = NO;
    menu_LiveTV.subItem.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_LiveTV.subItem.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_LiveTV.subItem.subItem.defaultThumb = @"nocover_filemode";
    menu_LiveTV.subItem.subItem.sheetActions = @[
        @[],
        [self action_broadcast],
        @[],
        @[],
        @[],
    ];

#pragma mark - Radio
    menu_Radio.mainLabel = LOCALIZED_STR(@"Radio");
    menu_Radio.icon = @"icon_menu_radio";
    menu_Radio.family = FamilyDetailView;
    menu_Radio.enableSection = YES;
    menu_Radio.noConvertTime = YES;
    menu_Radio.mainButtons = @[
        @"st_channels",
        @"st_radio",
        @"st_recordings",
        @"st_timers",
        @"st_timerrules",
    ];
    
    menu_Radio.mainMethod = [@[
        @[
            @"PVR.GetChannels", @"method",
            @YES, @"channelListView",
        ],
        @[
            @"PVR.GetChannelGroups", @"method",
        ],
        @[
            @"PVR.GetRecordings", @"method",
            @"PVR.GetRecordingDetails", @"extra_info_method",
        ],
        @[
            @"PVR.GetTimers", @"method",
        ],
        @[
            @"PVR.GetTimers", @"method",
        ],
    ] mutableCopy];
    
    menu_Radio.mainParameters = [@[
        @[
            @{
                @"channelgroupid": @"allradio",
                @"properties": @[
                        @"thumbnail",
                        @"channelnumber",
                        @"channel",
                ],
            }, @"parameters",
            @{
                @"17": @[
                    @"isrecording",
                ],
            }, @"kodiExtrasPropertiesMinimumVersion",
            LOCALIZED_STR(@"All channels"), @"label",
            @"nocover_channels", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @LIVETV_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH_SMALL, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                          
        @[
            @{
                @"channeltype": @"radio",
            }, @"parameters",
            LOCALIZED_STR(@"Channel Groups"), @"label",
            LOCALIZED_STR(@"Channel Groups"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],

        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"genre",
                        @"playcount",
                        @"resume",
                        @"channel",
                        @"runtime",
                        //@"lifetime", // Unused. Commented for Radio to support different persistence for TV/Radio.
                        @"icon",
                        @"art",
                        @"streamurl",
                        @"file",
                        @"radio",
                        @"directory",
                ],
            }, @"parameters",
            @{
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"genre",
                        @"playcount",
                        @"resume",
                        @"channel",
                        @"runtime",
                        //@"lifetime", // Unused. Commented for Radio to support different persistence for TV/Radio.
                        @"icon",
                        @"art",
                        @"streamurl",
                        @"file",
                        @"directory",
                ],
            }, @"extra_info_parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Channel"),
                        LOCALIZED_STR(@"Date"),
                        LOCALIZED_STR(@"Runtime"),
                        LOCALIZED_STR(@"Random"),
                ],
                @"method": @[
                        @"label",
                        @"channel",
                        @"starttime",
                        @"runtime",
                        @"random",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Recordings"), @"label",
            LOCALIZED_STR(@"Recordings"), @"morelabel",
            @"nocover_recording", @"defaultThumb",
            @CHANNEL_EPG_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH_SMALL, @"thumbWidth",
            @YES, @"enableCollectionView",
            @YES, @"enableLibraryCache",
            [self itemSizes_Music], @"itemSizes",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"title",
                        @"summary",
                        @"channelid",
                        @"isradio",
                        @"istimerrule",
                        @"starttime",
                        @"endtime",
                        @"runtime",
                        //@"lifetime", // Unused. Commented for Radio to support different persistence for TV/Radio.
                        @"firstday",
                        @"weekdays",
                        @"priority",
                        @"startmargin",
                        @"endmargin",
                        @"state",
                        @"file",
                        @"isreminder",
                        @"directory",
                ],
            }, @"parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Date"),
                        LOCALIZED_STR(@"Runtime"),
                ],
                @"method": @[
                        @"label",
                        @"starttime",
                        @"runtime",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Timers"), @"label",
            LOCALIZED_STR(@"Timers"), @"morelabel",
            @"nocover_timers", @"defaultThumb",
            @DEFAULT_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
        
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"properties": @[
                        @"title",
                        @"summary",
                        @"channelid",
                        @"isradio",
                        @"istimerrule",
                        @"starttime",
                        @"endtime",
                        @"runtime",
                        //@"lifetime", // Unused. Commented for Radio to support different persistence for TV/Radio.
                        @"firstday",
                        @"weekdays",
                        @"priority",
                        @"startmargin",
                        @"endmargin",
                        @"state",
                        @"file",
                        @"isreminder",
                        @"directory",
                ],
            }, @"parameters",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Title"),
                        LOCALIZED_STR(@"Date"),
                        LOCALIZED_STR(@"Runtime"),
                ],
                @"method": @[
                        @"label",
                        @"starttime",
                        @"runtime",
                ],
            }, @"available_sort_methods",
            LOCALIZED_STR(@"Timer rules"), @"label",
            LOCALIZED_STR(@"Timer rules"), @"morelabel",
            @"nocover_timerrules", @"defaultThumb",
            @DEFAULT_ROW_HEIGHT, @"rowHeight",
            @DEFAULT_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Radio.mainFields = @[
        @{
            @"itemid": @"channels",
            @"row1": @"channel",
            @"row2": @"starttime",
            @"row3": @"endtime",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"channelid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"channelid",
            @"row9": @"isrecording",
            @"row10": @"channelnumber",
            @"row11": @"type",
        },
                      
        @{
            @"itemid": @"channelgroups",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"channelgroupid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"channelgroupid",
            @"row9": @"channelgroupid",
        },

        @{
            @"itemid": @"recordings",
            @"row1": @"label",
            @"row2": @"plotoutline",
            @"row3": @"plot",
            @"row4": @"runtime",
            @"row5": @"starttime",
            @"row6": @"recordingid",
            @"row7": @"radio",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"recordingid",
            @"row9": @"recordingid",
            @"row10": @"file",
            @"row11": @"channel",
            @"row12": @"starttime",
            @"row13": @"endtime",
            @"row14": @"playcount",
            @"row15": @"plot",
            @"itemid_extra_info": @"recordingdetails",
        },
                      
        @{
            @"itemid": @"timers",
            @"row1": @"label",
            @"row2": @"summary",
            @"row3": @"plot",
            @"row4": @"runtime",
            @"row5": @"starttime",
            @"row6": @"timerid",
            @"row7": @"isreminder",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"timerid",
            @"row9": @"istimerrule",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row15": @"isradio",
        },
        
        @{
            @"itemid": @"timers",
            @"row1": @"label",
            @"row2": @"summary",
            @"row3": @"plot",
            @"row4": @"runtime",
            @"row5": @"starttime",
            @"row6": @"timerid",
            @"row7": @"isreminder",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"timerid",
            @"row9": @"istimerrule",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row15": @"isradio",
        },
    ];
    
    menu_Radio.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Radio.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Radio.defaultThumb = @"nocover_channels";
    menu_Radio.sheetActions = @[
        [self action_channel],
        @[],
        [self action_queue_to_play],
        @[LOCALIZED_STR(@"Delete timer")],
        @[LOCALIZED_STR(@"Delete timer")],
    ];
    
    menu_Radio.showInfo = @[
        @NO,
        @NO,
        @YES,
        @NO,
        @NO,
    ];
    
    menu_Radio.filterModes = @[
        [self modes_icons_empty],
        [self modes_icons_empty],
        [self modes_icons_watched],
        [self modes_icons_empty],
        [self modes_icons_empty],
    ];
    
    menu_Radio.subItem.mainMethod = [@[
        @[
            @"PVR.GetBroadcasts", @"method",
            @YES, @"channelGuideView",
        ],
        @[
            @"PVR.GetChannels", @"method",
            @YES, @"channelListView",
        ],
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_Radio.subItem.noConvertTime = YES;
    
    menu_Radio.subItem.mainParameters = [@[
        @[
            @{
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"progresspercentage",
                        @"isactive",
                        @"hastimer",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Radio"), @"label",
            @"icon_video", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @CHANNEL_EPG_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
            @YES, @"forceActionSheet",
        ],
                                  
        @[
            @{
                @"properties": @[
                        @"thumbnail",
                        @"channelnumber",
                        @"channel",
                ],
            }, @"parameters",
            @{
                @"17": @[
                    @"isrecording",
                ],
            }, @"kodiExtrasPropertiesMinimumVersion",
            LOCALIZED_STR(@"Radio"), @"label",
            @"nocover_channels", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @LIVETV_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH_SMALL, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
                                  
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_Radio.subItem.mainFields = @[
        @{
            @"itemid": @"broadcasts",
            @"row1": @"title",
            @"row2": @"plot",
            @"row3": @"broadcastid",
            @"row4": @"broadcastid",
            @"row5": @"starttime",
            @"row6": @"broadcastid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"broadcastid",
            @"row9": @"plotoutline",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row12": @"progresspercentage",
            @"row13": @"isactive",
            @"row14": @"title",
            @"row15": @"hastimer",
        },
                              
        @{
            @"itemid": @"channels",
            @"row1": @"channel",
            @"row2": @"starttime",
            @"row3": @"endtime",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"channelid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"channelid",
            @"row9": @"channelid",
            @"row10": @"channelnumber",
            @"row11": @"type",
        },
                              
        @{},
        @{},
        @{},
    ];
    
    menu_Radio.subItem.enableSection = NO;
    menu_Radio.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Radio.subItem.thumbWidth = LIVETV_THUMB_WIDTH;
    menu_Radio.subItem.defaultThumb = @"nocover_channels";
    menu_Radio.subItem.sheetActions = @[
        [self action_broadcast],
        [self action_channel],
        @[],
        @[],
        @[],
    ];
    
    menu_Radio.subItem.filterModes = @[
        [self modes_icons_empty],
        [self modes_icons_empty],
        @{},
        @{},
        @{},
    ];
    
    menu_Radio.subItem.subItem.noConvertTime = YES;
    menu_Radio.subItem.subItem.mainMethod = [@[
        @[],
        @[
            @"PVR.GetBroadcasts", @"method",
            @YES, @"channelGuideView",
        ],
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_Radio.subItem.subItem.mainParameters = [@[
        @[],
                                            
         @[
            @{
                @"properties": @[
                        @"title",
                        @"starttime",
                        @"endtime",
                        @"plot",
                        @"plotoutline",
                        @"progresspercentage",
                        @"isactive",
                        @"hastimer",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Radio"), @"label",
            @"icon_video", @"defaultThumb",
            @YES, @"disableFilterParameter",
            @CHANNEL_EPG_ROW_HEIGHT, @"rowHeight",
            @LIVETV_THUMB_WIDTH, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
            @YES, @"forceActionSheet",
        ],
                                            
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    menu_Radio.subItem.subItem.mainFields = @[
        @{},
                                        
        @{
            @"itemid": @"broadcasts",
            @"row1": @"title",
            @"row2": @"plot",
            @"row3": @"broadcastid",
            @"row4": @"broadcastid",
            @"row5": @"starttime",
            @"row6": @"broadcastid",
            @"playlistid": @PLAYERID_VIDEO,
            @"row8": @"broadcastid",
            @"row9": @"plotoutline",
            @"row10": @"starttime",
            @"row11": @"endtime",
            @"row12": @"progresspercentage",
            @"row13": @"isactive",
            @"row14": @"title",
            @"row15": @"hastimer",
        },
                                        
        @[],
        @[],
        @[],
    ];
    
    menu_Radio.subItem.subItem.enableSection = NO;
    menu_Radio.subItem.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Radio.subItem.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Radio.subItem.subItem.defaultThumb = @"nocover_filemode";
    menu_Radio.subItem.subItem.sheetActions = @[
        @[],
        [self action_broadcast],
        @[],
        @[],
        @[],
    ];

#pragma mark - Pictures
    menu_Pictures.mainLabel = LOCALIZED_STR(@"Pictures");
    menu_Pictures.icon = @"icon_menu_pictures";
    menu_Pictures.family = FamilyDetailView;
    menu_Pictures.enableSection = YES;
    menu_Pictures.mainButtons = @[
        @"st_filemode",
        @"st_addons",
    ];
    
    menu_Pictures.mainMethod = [@[
        @[
            @"Files.GetSources", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
    ] mutableCopy];
    
    menu_Pictures.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"pictures",
            }, @"parameters",
            LOCALIZED_STR(@"Pictures"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                          
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"pictures",
                @"directory": @"addons://sources/image",
                @"properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Pictures Add-ons"), @"label",
            LOCALIZED_STR(@"Pictures Add-ons"), @"morelabel",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Pictures.mainFields = @[
        @{
            @"itemid": @"sources",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"file",
            @"row9": @"file",
        },
                      
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"year",
            @"row3": @"year",
            @"row4": @"runtime",
            @"row5": @"rating",
            @"row6": @"file",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"file",
            @"row9": @"file",
        },
    ];
    
    menu_Pictures.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Pictures.defaultThumb = @"nocover_filemode";
    
    menu_Pictures.subItem.mainMethod = [@[
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
    ] mutableCopy];
    
    menu_Pictures.sheetActions = @[
        [self action_pictures],
        @[],
    ];
    
    menu_Pictures.subItem.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"label" order:@"ascending" ignorearticle:NO],
                @"media": @"pictures",
                @"file_properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Files"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
                                  
        @[
            @{
                @"sort": [self sortmethod:@"none" order:@"ascending" ignorearticle:NO],
                @"media": @"pictures",
                @"file_properties": @[
                    @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
        ],
    ] mutableCopy];
    
    menu_Pictures.subItem.mainFields = @[
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
                              
        @{
            @"itemid": @"files",
            @"row1": @"label",
            @"row2": @"filetype",
            @"row3": @"filetype",
            @"row4": @"filetype",
            @"row5": @"filetype",
            @"row6": @"file",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"file",
            @"row9": @"file",
            @"row10": @"filetype",
            @"row11": @"type",
        },
    ];
    
    menu_Pictures.subItem.enableSection = NO;
    menu_Pictures.subItem.rowHeight = PORTRAIT_ROW_HEIGHT;
    menu_Pictures.subItem.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Pictures.subItem.defaultThumb = @"nocover_filemode";
    menu_Pictures.subItem.sheetActions = @[
        [self action_pictures],
        @[],
    ];
    
    menu_Pictures.subItem.subItem.mainMethod = [@[
        @[
            @"Files.GetDirectory", @"method",
        ],
        @[
            @"Files.GetDirectory", @"method",
        ],
    ] mutableCopy];
    
    menu_Pictures.subItem.subItem.mainParameters = [@[
        @[],
        @[],
    ] mutableCopy];
    
    menu_Pictures.subItem.subItem.mainFields = @[
        @[],
        @[],
    ];
    
#pragma mark - Favourites
    menu_Favourites.mainLabel = LOCALIZED_STR(@"Favourites");
    menu_Favourites.icon = @"icon_menu_favourites";
    menu_Favourites.family = FamilyDetailView;
    menu_Favourites.enableSection = YES;
    menu_Favourites.mainButtons = @[
        @"st_filemode",
    ];
    
    menu_Favourites.mainMethod = [@[
        @[
            @"Favourites.GetFavourites", @"method",
        ],
    ] mutableCopy];
    
    menu_Favourites.mainParameters = [@[
        @[
            @{
                @"properties": @[
                        @"thumbnail",
                        @"path",
                        @"window",
                        @"windowparameter",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Favourites"), @"label",
            @"nocover_favourites", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @FILEMODE_THUMB_WIDTH, @"thumbWidth",
            @YES, @"enableCollectionView",
            [self itemSizes_Music], @"itemSizes",
        ],
    ] mutableCopy];
    
    menu_Favourites.mainFields = @[
        @{
            @"itemid": @"favourites",
            @"row1": @"title",
            @"row2": [NSNull null],
            @"row3": [NSNull null],
            @"row4": [NSNull null],
            @"row5": [NSNull null],
            @"row6": @"title",
            @"row7": @"path",
            @"playlistid": @(-1),
            @"row8": @"type",
            @"row9": @"window",
            @"row10": @"windowparameter",
        },
    ];
    
    menu_Favourites.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_Favourites.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Favourites.defaultThumb = @"nocover_filemode";
    
#pragma mark - Now Playing
    menu_NowPlaying.mainLabel = LOCALIZED_STR(@"Now Playing");
    menu_NowPlaying.icon = @"icon_menu_playing";
    menu_NowPlaying.family = FamilyNowPlaying;
    
#pragma mark - Remote Control
    menu_Remote.mainLabel = LOCALIZED_STR(@"Remote Control");
    menu_Remote.icon = @"icon_menu_remote";
    menu_Remote.family = FamilyRemote;
    
#pragma mark - Global Search
    menu_Search.mainLabel = LOCALIZED_STR(@"Global Search");
    menu_Search.icon = @"icon_menu_search";
    menu_Search.family = FamilyDetailView;
    menu_Search.enableSection = YES;
    menu_Search.rowHeight = DEFAULT_ROW_HEIGHT;
    menu_Search.thumbWidth = DEFAULT_THUMB_WIDTH;
    menu_Search.defaultThumb = @"nocover_filemode";
    menu_Search.mainParameters = [@[
        @[
            @{
                @"sort": [self sortmethod:@"itemgroup" order:@"ascending" ignorearticle:NO],
            }, @"parameters",
            LOCALIZED_STR(@"Global Search"), @"label",
            @{
                @"label": @[
                        LOCALIZED_STR(@"Type"),
                        LOCALIZED_STR(@"Name"),
                ],
                @"method": @[
                        @"itemgroup",
                        @"label",
                ],
            }, @"available_sort_methods",
            @YES, @"enableLibraryCache",
        ],
    ] mutableCopy];
    
#pragma mark - XBMC Server Management
    menu_Server.mainLabel = LOCALIZED_STR(@"XBMC Server");
    menu_Server.icon = @"";
    menu_Server.family = FamilyServer;
    
#pragma mark - Playlist Artist Albums
    playlistArtistAlbums = [menu_Music copy];
    playlistArtistAlbums.subItem.disableNowPlaying = YES;
    playlistArtistAlbums.subItem.subItem.disableNowPlaying = YES;
    
#pragma mark - Plalist Movies
    playlistMovies = [menu_Movies copy];
    playlistMovies.subItem.disableNowPlaying = YES;
    playlistMovies.subItem.subItem.disableNowPlaying = YES;
    
#pragma mark - Plalist Movies
    playlistMusicVideos = [menu_Videos copy];
    playlistMusicVideos.subItem.disableNowPlaying = YES;
    playlistMusicVideos.subItem.subItem.disableNowPlaying = YES;
    
#pragma mark - Playlist TV Shows
    playlistTvShows = [menu_TVShows copy];
    playlistTvShows.subItem.disableNowPlaying = YES;
    playlistTvShows.subItem.subItem.disableNowPlaying = YES;

#pragma mark - Playlist PVR
    playlistPVR = [menu_LiveTV copy];
    playlistPVR.subItem.disableNowPlaying = YES;
    playlistPVR.subItem.subItem.disableNowPlaying = YES;
    
#pragma mark - XBMC Settings 
    xbmcSettings = [mainMenu new];
    xbmcSettings.subItem = [mainMenu new];
    xbmcSettings.subItem.subItem = [mainMenu new];
    
    xbmcSettings.mainLabel = LOCALIZED_STR(@"XBMC Settings");
    xbmcSettings.icon = @"icon_menu_settings";
    xbmcSettings.family = FamilyDetailView;
    xbmcSettings.enableSection = YES;
    xbmcSettings.rowHeight = SETTINGS_ROW_HEIGHT;
    xbmcSettings.thumbWidth = SETTINGS_THUMB_WIDTH;
    xbmcSettings.disableNowPlaying = YES;
    xbmcSettings.mainButtons = @[
        @"st_filemode",
        @"st_addons",
        @"st_video_addon",
        @"st_music_addon",
        @"st_kodi_action",
        @"st_kodi_window",
    ];
    
    xbmcSettings.mainMethod = [@[
        @[
            @"Settings.GetSections", @"method",
        ],
        @[
            @"Addons.GetAddons", @"method",
        ],
        @[
            @"Addons.GetAddons", @"method",
        ],
        @[
            @"Addons.GetAddons", @"method",
        ],
        @[
            @"JSONRPC.Introspect", @"method",
        ],
        @[
            @"JSONRPC.Introspect", @"method",
        ],
    ] mutableCopy];
    
    xbmcSettings.mainParameters = [@[
        @[
            @{
                @"level": @"expert",
            }, @"parameters",
            LOCALIZED_STR(@"XBMC Settings"), @"label",
            @(IS_IPHONE), @"animationStartBottomScreen",
            @0, @"thumbWidth",
        ],
                                   
        @[
            @{
                @"type": @"xbmc.addon.executable",
                @"enabled": @YES,
                @"properties": @[
                        @"name",
                        @"version",
                        @"summary",
                        @"thumbnail",
                ],
            }, @"parameters",
             LOCALIZED_STR(@"Programs"), @"label",
             @"nocover_filemode", @"defaultThumb",
             @SETTINGS_ROW_HEIGHT, @"rowHeight",
             @SETTINGS_THUMB_WIDTH_BIG, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
            @YES, @"enableCollectionView",
        ],
                                   
        @[
            @{
                @"type": @"xbmc.addon.video",
                @"enabled": @YES,
                @"properties": @[
                        @"name",
                        @"version",
                        @"summary",
                        @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Video Add-ons"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @SETTINGS_ROW_HEIGHT, @"rowHeight",
            @SETTINGS_THUMB_WIDTH_BIG, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
            @YES, @"enableCollectionView",
        ],
                                   
        @[
            @{
                @"type": @"xbmc.addon.audio",
                @"enabled": @YES,
                @"properties": @[
                        @"name",
                        @"version",
                        @"summary",
                        @"thumbnail",
                ],
            }, @"parameters",
            LOCALIZED_STR(@"Music Add-ons"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @SETTINGS_ROW_HEIGHT, @"rowHeight",
            @SETTINGS_THUMB_WIDTH_BIG, @"thumbWidth",
            [self itemSizes_Music], @"itemSizes",
            @YES, @"enableCollectionView",
        ],
                                   
        @[
            @{
                @"filter": @{
                        @"id": @"Input.ExecuteAction",
                        @"type": @"method",
                },
            }, @"parameters",
            LOCALIZED_STR(@"Kodi actions"), @"label",
            @"default-right-action-icon", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @0, @"thumbWidth",
            LOCALIZED_STR(@"Execute a specific action"), @"morelabel",
        ],
                                   
        @[
            @{
                @"filter": @{
                        @"id": @"GUI.ActivateWindow",
                        @"type": @"method",
                },
            }, @"parameters",
            LOCALIZED_STR(@"Kodi windows"), @"label",
            @"default-right-window-icon", @"defaultThumb",
            @FILEMODE_ROW_HEIGHT, @"rowHeight",
            @0, @"thumbWidth",
            LOCALIZED_STR(@"Activate a specific window"), @"morelabel",
        ],
    ] mutableCopy];
    
    xbmcSettings.mainFields = @[
        @{
            @"itemid": @"sections",
            @"row1": @"label",
            @"row2": @"help",
            @"row3": @"id",
            @"row4": @"id",
            @"row5": @"id",
            @"row6": @"id",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"sectionid",
            @"row9": @"id",
        },
                               
        @{
            @"itemid": @"addons",
            @"row1": @"name",
            @"row2": @"summary",
            @"row3": @"blank",
            @"row4": @"blank",
            @"row5": @"addonid",
            @"row6": @"addonid",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"addonid",
            @"row9": @"addonid",
        },
                               
        @{
            @"itemid": @"addons",
            @"row1": @"name",
            @"row2": @"summary",
            @"row3": @"blank",
            @"row4": @"blank",
            @"row5": @"addonid",
            @"row6": @"addonid",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"addonid",
            @"row9": @"addonid",
        },
                               
        @{
            @"itemid": @"addons",
            @"row1": @"name",
            @"row2": @"summary",
            @"row3": @"blank",
            @"row4": @"blank",
            @"row5": @"addonid",
            @"row6": @"addonid",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"addonid",
            @"row9": @"addonid",
        },
                               
        @{
            @"itemid": @"types",
            @"typename": @"Input.Action",
            @"fieldname": @"enums",
            @"row1": @"name",
            @"row2": @"summary",
            @"row3": @"blank",
            @"row4": @"blank",
            @"row5": @"addonid",
            @"row6": @"addonid",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"addonid",
            @"row9": @"addonid",
        },
                               
        @{
            @"itemid": @"types",
            @"typename": @"GUI.Window",
            @"fieldname": @"enums",
            @"row1": @"name",
            @"row2": @"summary",
            @"row3": @"blank",
            @"row4": @"blank",
            @"row5": @"addonid",
            @"row6": @"addonid",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"addonid",
            @"row9": @"addonid",
        },
    ];
    
    xbmcSettings.sheetActions = @[
        @[],
        @[
            LOCALIZED_STR(@"Execute program"),
            LOCALIZED_STR(@"Add button"),
        ],
        @[
            LOCALIZED_STR(@"Execute video add-on"),
            LOCALIZED_STR(@"Add button"),
        ],
        @[
            LOCALIZED_STR(@"Execute audio add-on"),
            LOCALIZED_STR(@"Add button"),
        ],
        @[
            LOCALIZED_STR(@"Execute action"),
            LOCALIZED_STR(@"Add action button"),
        ],
        @[
            LOCALIZED_STR(@"Activate window"),
            LOCALIZED_STR(@"Add window activation button"),
        ],
    ];
    
    xbmcSettings.subItem.disableNowPlaying = YES;
    xbmcSettings.subItem.mainMethod = [@[
        @[
            @"Settings.GetCategories", @"method",
        ],
        @[],
        @[],
        @[],
        @[],
        @[],
    ] mutableCopy];
    
    xbmcSettings.subItem.mainParameters = [@[
        @[
            LOCALIZED_STR(@"Settings"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @SETTINGS_ROW_HEIGHT, @"rowHeight",
            @0, @"thumbWidth",
        ],

        @[
            @YES, @"forceActionSheet",
        ],

        @[
            @YES, @"forceActionSheet",
        ],

        @[
            @YES, @"forceActionSheet",
        ],

        @[
            @YES, @"forceActionSheet",
        ],

        @[
            @YES, @"forceActionSheet",
        ],
    ] mutableCopy];
    
    xbmcSettings.subItem.mainFields = @[
        @{
            @"itemid": @"categories",
            @"row1": @"label",
            @"row2": @"help",
            @"row3": @"id",
            @"row4": @"id",
            @"row5": @"id",
            @"row6": @"id",
            @"playlistid": @PLAYERID_PICTURES,
            @"row8": @"categoryid",
            @"row9": @"id",
        },
        @{},
        @{},
        @{},
        @{},
        @{},
    ];
    
    xbmcSettings.subItem.rowHeight = SETTINGS_ROW_HEIGHT;
    xbmcSettings.subItem.thumbWidth = SETTINGS_THUMB_WIDTH;
    
    xbmcSettings.subItem.subItem.disableNowPlaying = YES;
    xbmcSettings.subItem.subItem.mainMethod = [@[
        @[
            @"Settings.GetSettings", @"method",
        ],
    ] mutableCopy];
    
    xbmcSettings.subItem.subItem.mainParameters = [@[
        @[
            LOCALIZED_STR(@"Settings"), @"label",
            @"nocover_filemode", @"defaultThumb",
            @SETTINGS_ROW_HEIGHT, @"rowHeight",
            @0, @"thumbWidth",
        ],
    ] mutableCopy];
    
    xbmcSettings.subItem.subItem.mainFields = @[
        @{
            @"itemid": @"settings",
            @"row1": @"label",
            @"row2": @"help",
            @"row3": @"type",
            @"row4": @"default",
            @"row5": @"enabled",
            @"row6": @"id",
            @"playlistid": @PLAYERID_PICTURES,
            @"row7": @"delimiter",
            @"row8": @"id",
            @"row9": @"id",
            @"row10": @"parent",
            @"row11": @"control",
            @"row12": @"value",
            @"row13": @"options",
            @"row14": @"allowempty",
            @"row15": @"addontype",
            @"row16": @"maximum",
            @"row17": @"minimum",
            @"row18": @"step",
            @"row19": @"definition",
        },
    ];
    
    xbmcSettings.subItem.subItem.sheetActions = @[
        @[],
    ];
    
    xbmcSettings.subItem.subItem.rowHeight = SETTINGS_ROW_HEIGHT;
    xbmcSettings.subItem.subItem.thumbWidth = SETTINGS_THUMB_WIDTH;
    
#pragma mark - Now Playing Right Menu
    nowPlayingMenuItems = [NSMutableArray arrayWithCapacity:1];
    __auto_type nowPlayingItem1 = [mainMenu new];
    nowPlayingItem1.mainLabel = @"EmbeddedRemote";
    nowPlayingItem1.family = FamilyNowPlaying;
    nowPlayingItem1.mainMethod = @[
        @{
            @"offline": @[],
                   
            @"online": @[
                @{
                    @"label": @"VolumeControl",
                    @"icon": @"volume",
                },
                @{
                    @"label": LOCALIZED_STR(@"Keyboard"),
                    @"icon": @"keyboard_icon",
                },
                @{
                    @"label": @"RemoteControl",
                },
            ],
        },
    ];
    
    [nowPlayingMenuItems addObject:nowPlayingItem1];
    
#pragma mark - Remote Control Right Menu
    remoteControlMenuItems = [NSMutableArray arrayWithCapacity:1];
    __auto_type remoteControlItem1 = [mainMenu new];
    remoteControlItem1.mainLabel = @"RemoteControl";
    remoteControlItem1.family = FamilyRemote;
    remoteControlItem1.enableSection = YES;

    remoteControlItem1.mainMethod = @[
        @{
            @"offline": @[
                @{
                    @"label": LOCALIZED_STR(@"LED Torch"),
                    @"icon": @"torch",
                },
            ],
                                   
            @"online": @[
                @{
                    @"label": @"VolumeControl",
                    @"icon": @"volume",
                },
                @{
                    @"label": LOCALIZED_STR(@"Keyboard"),
                    @"icon": @"keyboard_icon",
                    @"revealViewTop": @YES,
                },
                @{
                    @"label": LOCALIZED_STR(@"Button Pad/Gesture Zone"),
                    @"icon": @"buttons-gestures",
                },
                @{
                    @"label": LOCALIZED_STR(@"Help Screen"),
                    @"icon": @"button_info",
                },
                @{
                    @"label": LOCALIZED_STR(@"LED Torch"),
                    @"icon": @"torch",
                },
            ],
        },
    ];
    
    [remoteControlMenuItems addObject:remoteControlItem1];
    
//    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProximityChangeNotification:) name:UIDeviceProximityStateDidChangeNotification object:nil];

#pragma mark - Build and Initialize menu structure
    
    // Build menu
    if (IS_IPHONE) {
        [mainMenuItems addObject:menu_Server];
    }
    if ([self isMenuEntryEnabled:@"menu_music"]) {
        [mainMenuItems addObject:menu_Music];
    }
    if ([self isMenuEntryEnabled:@"menu_movies"]) {
        [mainMenuItems addObject:menu_Movies];
    }
    if ([self isMenuEntryEnabled:@"menu_videos"]) {
        [mainMenuItems addObject:menu_Videos];
    }
    if ([self isMenuEntryEnabled:@"menu_tvshows"]) {
        [mainMenuItems addObject:menu_TVShows];
    }
    if ([self isMenuEntryEnabled:@"menu_pictures"]) {
        [mainMenuItems addObject:menu_Pictures];
    }
    if ([self isMenuEntryEnabled:@"menu_livetv"]) {
        [mainMenuItems addObject:menu_LiveTV];
    }
    if ([self isMenuEntryEnabled:@"menu_radio"]) {
        [mainMenuItems addObject:menu_Radio];
    }
    if ([self isMenuEntryEnabled:@"menu_favourites"]) {
        [mainMenuItems addObject:menu_Favourites];
    }
    if ([self isMenuEntryEnabled:@"menu_nowplaying"]) {
        [mainMenuItems addObject:menu_NowPlaying];
    }
    if ([self isMenuEntryEnabled:@"menu_remote"]) {
        [mainMenuItems addObject:menu_Remote];
    }
    if ([self isMenuEntryEnabled:@"menu_search"]) {
        [mainMenuItems addObject:menu_Search];
    }
    
    // Set rootLabel for all menu entries
    for (mainMenu *menuItem in mainMenuItems) {
        menuItem.rootLabel = menuItem.mainLabel;
    }
    
#pragma mark - Build and Initialize Global Search Lookup

    globalSearchMenuLookup = @[
        @[menu_Movies,  [self getGlobalSearchTab:menu_Movies  label:LOCALIZED_STR(@"Movies")]], // Movies
        @[menu_Movies,  [self getGlobalSearchTab:menu_Movies  label:LOCALIZED_STR(@"Movie Sets")]], // Movie Sets
        @[menu_TVShows, [self getGlobalSearchTab:menu_TVShows label:LOCALIZED_STR(@"TV Shows")]], // TV Shows
        @[menu_Videos,  [self getGlobalSearchTab:menu_Videos  label:LOCALIZED_STR(@"Music Videos")]], // Music Videos
        @[menu_Music,   [self getGlobalSearchTab:menu_Music   label:LOCALIZED_STR(@"Artists")]], // Artists
        @[menu_Music,   [self getGlobalSearchTab:menu_Music   label:LOCALIZED_STR(@"Albums")]], // Albums
        @[menu_Music,   [self getGlobalSearchTab:menu_Music   label:LOCALIZED_STR(@"All songs")]], // Songs
    ];
    
    // Initialize controllers
    self.serverName = LOCALIZED_STR(@"No connection");
    if (IS_IPHONE) {
        InitialSlidingViewController *initialSlidingViewController = [[InitialSlidingViewController alloc] initWithNibName:@"InitialSlidingViewController" bundle:nil];
        initialSlidingViewController.mainMenu = mainMenuItems;
        self.window.rootViewController = initialSlidingViewController;
    }
    else {
        self.windowController = [[ViewControllerIPad alloc] initWithNibName:@"ViewControllerIPad" bundle:nil];
        self.windowController.mainMenu = mainMenuItems;
        self.window.rootViewController = self.windowController;
    }
    return YES;
}

- (BOOL)isMenuEntryEnabled:(NSString*)menuItem {
    id menuEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:menuItem];
    return (menuEnabled == nil || [menuEnabled boolValue]);
}

- (NSURL*)getServerJSONEndPoint {
    if (!obj.serverIP || !obj.serverPort) {
        return nil;
    }
    NSString *serverJSON = [NSString stringWithFormat:@"http://%@:%@/jsonrpc", obj.serverIP, obj.serverPort];
    return [NSURL URLWithString:serverJSON];
}

- (NSDictionary*)getServerHTTPHeaders {
    NSData *authCredential = [[NSString stringWithFormat:@"%@:%@", obj.serverUser, obj.serverPass] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [authCredential base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", base64AuthCredentials];
    NSDictionary *httpHeaders = @{@"Authorization": authValue};
    return httpHeaders;
}

#pragma mark - Helper

- (void)setIdleTimerFromUserDefaults {
    UIApplication.sharedApplication.idleTimerDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"lockscreen_preference"];
}

- (void)setInterfaceStyleFromUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mode = [userDefaults stringForKey:@"theme_mode"];
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle style = UIUserInterfaceStyleUnspecified;
        if (mode.length) {
            if ([mode isEqualToString:@"dark_mode"]) {
                style = UIUserInterfaceStyleDark;
            }
            else if ([mode isEqualToString:@"light_mode"]) {
                style = UIUserInterfaceStyleLight;
            }
        }
        self.window.overrideUserInterfaceStyle = style;
    }
}
    
- (NSNumber*)getGlobalSearchTab:(mainMenu*)menuItem label:(NSString*)subLabel {
    // Search for the method index with the desired sub label (e.g. "All Songs")
    int k;
    for (k = 0; k < menuItem.mainMethod.count; ++k) {
        id paramArray = menuItem.mainParameters[k];
        id parameters = [Utilities indexKeyedDictionaryFromArray:paramArray];
        if ([parameters[@"label"] isEqualToString:subLabel]) {
            break;
        }
    }
    return @(k);
}

- (void)handleProximityChangeNotification:(id)sender {
    if ([[UIDevice currentDevice] proximityState]) {
        UIApplication.sharedApplication.idleTimerDisabled = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationDidEnterBackgroundNotification" object: nil];
    }
    else {
        [self setIdleTimerFromUserDefaults];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationWillEnterForegroundNotification" object: nil];
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    }
}

// Returns the addresses of the discard service (port 9) on every
/// broadcast-capable interface.
///
/// Each array entry contains either a `sockaddr_in` or `sockaddr_in6`.
- (NSArray<NSData*>*)addressesOfDiscardServiceOnBroadcastCapableInterfaces {
    struct ifaddrs *addrList = NULL;
    int err = getifaddrs(&addrList);
    if (err != 0) {
        return @[];
    }
    NSMutableArray<NSData*> *result = [NSMutableArray array];
    for (struct ifaddrs *cursor = addrList; cursor != NULL; cursor = cursor->ifa_next) {
        if ((cursor->ifa_flags & IFF_BROADCAST) &&
            (cursor->ifa_addr != NULL)) {
            switch (cursor->ifa_addr->sa_family) {
                case AF_INET: {
                    struct sockaddr_in sin = *(struct sockaddr_in*)cursor->ifa_addr;
                    sin.sin_port = htons(9);
                    NSData *addr = [NSData dataWithBytes:&sin length:sizeof(sin)];
                    [result addObject:addr];
                } break;
                case AF_INET6: {
                    struct sockaddr_in6 sin6 = *(struct sockaddr_in6*)cursor->ifa_addr;
                    sin6.sin6_port = htons(9);
                    NSData *addr = [NSData dataWithBytes:&sin6 length:sizeof(sin6)];
                    [result addObject:addr];
                } break;
                default: {
                    // do nothing
                } break;
            }
        }
    }
    freeifaddrs(addrList);
    return result;
}

/// Does a best effort attempt to trigger the local network privacy alert.
///
/// It works by sending a UDP datagram to the discard service (port 9) of every
/// IP address associated with a broadcast-capable interface interface. This
/// should trigger the local network privacy alert, assuming the alert hasn’t
/// already been displayed for this app.
///
/// This code takes a ‘best effort’. It handles errors by ignoring them. As
/// such, there’s guarantee that it’ll actually trigger the alert.
///
/// - note: iOS devices don’t actually run the discard service. I’m using it
/// here because I need a port to send the UDP datagram to and port 9 is
/// always going to be safe (either the discard service is running, in which
/// case it will discard the datagram, or it’s not, in which case the TCP/IP
/// stack will discard it).
///
/// There should be a proper API for this (r. 69157424).
///
/// For more background on this, see [Triggering the Local Network Privacy Alert](https://developer.apple.com/forums/thread/663768).
- (void)triggerLocalNetworkPrivacyAlert {
    int sock4 = socket(AF_INET, SOCK_DGRAM, 0);
    int sock6 = socket(AF_INET6, SOCK_DGRAM, 0);
    
    if (sock4 >= 0 && sock6 >= 0) {
        char message = '!';
        NSArray<NSData*> *addresses = [self addressesOfDiscardServiceOnBroadcastCapableInterfaces];
        for (NSData *address in addresses) {
            int sock = ((const struct sockaddr*)address.bytes)->sa_family == AF_INET ? sock4 : sock6;
            (void) sendto(sock, &message, sizeof(message), MSG_DONTWAIT, address.bytes, (socklen_t) address.length);
        }
    }
    
    // If we failed to open a socket, the descriptor will be -1 and it’s safe to
    // close that (it’s guaranteed to fail with `EBADF`).
    close(sock4);
    close(sock6);
}

- (void)sendWOL:(NSString*)MAC withPort:(NSInteger)WOLport {
    CFSocketRef     WOLsocket;
    WOLsocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, 0, NULL, NULL);
    if (WOLsocket) {
        int desc = -1;
        desc = CFSocketGetNative(WOLsocket);
        int yes = -1;
        
        if (setsockopt (desc, SOL_SOCKET, SO_BROADCAST, (char*)&yes, sizeof(yes)) < 0) {
            NSLog(@"Set Socket options failed");
        }
        
        unsigned char ether_addr[6];
        
        int idx;
        
        for (idx = 0; idx + 2 <= MAC.length; idx += 3) {
            NSRange range = NSMakeRange(idx, 2);
            NSString *hexStr = [MAC substringWithRange:range];
            
            NSScanner *scanner = [NSScanner scannerWithString:hexStr];
            unsigned int intValue;
            [scanner scanHexInt:&intValue];
            
            ether_addr[idx / 3] = intValue;
        }
        
        /* Build the message to send - 6 x 0xff then 16 x MAC address */
        
        unsigned char message[102];
        unsigned char *message_ptr = message;
        
        memset(message_ptr, 0xFF, 6);
        message_ptr += 6;
        for (int i = 0; i < 16; ++i) {
            memcpy(message_ptr, ether_addr, 6);
            message_ptr += 6;
        }

        __auto_type getLocalBroadcastAddress = ^in_addr_t {
            in_addr_t broadcastAddress = 0xffffffff;
            struct ifaddrs *ifs = NULL;
            getifaddrs(&ifs);
            for (__auto_type ifIter = ifs; ifIter != NULL; ifIter = ifIter->ifa_next) {
                if (ifIter->ifa_flags & IFF_LOOPBACK || ifIter->ifa_flags & IFF_POINTOPOINT || !(ifIter->ifa_flags & IFF_RUNNING))
                    continue;
                if (!ifIter->ifa_addr || ifIter->ifa_addr->sa_family != AF_INET || !ifIter->ifa_broadaddr)
                    continue;
                broadcastAddress = ((struct sockaddr_in*)ifIter->ifa_broadaddr)->sin_addr.s_addr;
                break;
            }
            if (ifs) {
                freeifaddrs(ifs);
            }
            return broadcastAddress;
        };

        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = getLocalBroadcastAddress();
        addr.sin_port = htons(WOLport);
        
        CFDataRef message_data = CFDataCreate(NULL, (unsigned char*)&message, sizeof(message));
        CFDataRef destinationAddressData = CFDataCreate(NULL, (const UInt8*)&addr, sizeof(addr));
        
        CFSocketError CFSocketSendData_error = CFSocketSendData(WOLsocket, destinationAddressData, message_data, 30);
        
        if (CFSocketSendData_error) {
            NSLog(@"CFSocketSendData error: %li", CFSocketSendData_error);
        }
    }
}


- (void)applicationWillResignActive:(UIApplication*)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self setIdleTimerFromUserDefaults];
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"UIApplicationWillEnterForegroundNotification" object: nil];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication*)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)saveServerList {
    [Utilities archivePath:self.dataFilePath file:@"serverList_saved.dat" data:arrayServerList];
}

- (void)clearDiskCacheAtPath:(NSString*)cachePath {
    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (void)clearAppDiskCache {
    // Clear SDWebImage image cache
    [[SDImageCache sharedImageCache] clearDisk];
    
    // Clear library cache
    [self clearDiskCacheAtPath:self.libraryCachePath];
    
    // Clear EPG cache
    [self clearDiskCacheAtPath:self.epgCachePath];
    
    // Clear network cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
