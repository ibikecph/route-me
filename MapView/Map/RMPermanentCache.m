//
//  RMPermanentCache.m
//  MapView
//
//  Created by Ivan Pavlovic on 29/03/2013.
//
//

#import "RMPermanentCache.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "RMTileImage.h"
#import "RMTile.h"

#define kWriteQueueLimit 15

@interface RMPermanentCache ()

- (NSUInteger)count;
- (NSUInteger)countTiles;
- (void)touchTile:(RMTile)tile withKey:(NSString *)cacheKey;
- (void)purgeTiles:(NSUInteger)count;

@end

#pragma mark -

@implementation RMPermanentCache
{
    // Database
    FMDatabaseQueue *_queue;
    
    NSUInteger _tileCount;
    NSOperationQueue *_writeQueue;
    NSRecursiveLock *_writeQueueLock;
    
    // Cache
    RMCachePurgeStrategy _purgeStrategy;
    NSUInteger _capacity;
    NSUInteger _minimalPurge;
    NSTimeInterval _expiryPeriod;
}

@synthesize databasePath = _databasePath;

+ (NSString *)dbPathUsingCacheDir:(BOOL)useCacheDir {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) // Should only be one...
	{
		NSString *cachePath = [paths objectAtIndex:0];
        
		// check for existence of cache directory
		if ( ![[NSFileManager defaultManager] fileExistsAtPath: cachePath])
		{
			// create a new cache directory
			[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
		}
        
		return [cachePath stringByAppendingPathComponent:@"PermanentCache.db"];
	}
    
	return nil;
}

- (void)configureDBForFirstUse
{
    [_queue inDatabase:^(FMDatabase *db) {
        [[db executeQuery:@"PRAGMA synchronous=OFF"] close];
        [[db executeQuery:@"PRAGMA journal_mode=OFF"] close];
        [[db executeQuery:@"PRAGMA cache-size=100"] close];
        [[db executeQuery:@"PRAGMA count_changes=OFF"] close];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS tiles (tilekey INTEGER NOT NULL, cache_key VARCHAR(25) NOT NULL, last_used DOUBLE NOT NULL, image BLOB NOT NULL)"];
        [db executeUpdate:@"CREATE UNIQUE INDEX IF NOT EXISTS main_index ON tiles(tilekey)"];
    }];
}

- (id)initWithDatabase:(NSString *)path
{
	if (!(self = [super init]))
		return nil;
    
	self.databasePath = path;
    
    _writeQueue = [NSOperationQueue new];
    [_writeQueue setMaxConcurrentOperationCount:1];
    _writeQueueLock = [NSRecursiveLock new];
    
	RMLog(@"Opening database at %@", path);
    
    _queue = [[FMDatabaseQueue databaseQueueWithPath:path] retain];
    
	if (!_queue)
	{
		RMLog(@"Could not connect to database");
        
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        
        [self release];
        return nil;
	}
    
    [_queue inDatabase:^(FMDatabase *db) {
        [db setCrashOnErrors:NO];
        [db setShouldCacheStatements:TRUE];
    }];
    
	[self configureDBForFirstUse];
    
    _tileCount = [self countTiles];
    
	return self;
}

- (id)initUsingCacheDir:(BOOL)useCacheDir
{
	return [self initWithDatabase:[RMPermanentCache dbPathUsingCacheDir:useCacheDir]];
}

- (void)dealloc
{
    self.databasePath = nil;
    [_writeQueueLock lock];
    [_writeQueue release]; _writeQueue = nil;
    [_writeQueueLock unlock];
    [_writeQueueLock release]; _writeQueueLock = nil;
    [_queue release]; _queue = nil;
	[super dealloc];
}

- (void)setPurgeStrategy:(RMCachePurgeStrategy)theStrategy
{
	_purgeStrategy = theStrategy;
}

- (void)setCapacity:(NSUInteger)theCapacity
{
	_capacity = theCapacity;
}

- (void)setMinimalPurge:(NSUInteger)theMinimalPurge
{
	_minimalPurge = theMinimalPurge;
}

- (void)setExpiryPeriod:(NSTimeInterval)theExpiryPeriod
{
    _expiryPeriod = theExpiryPeriod;
    
    srand(time(NULL));
}

- (UIImage *)cachedImage:(RMTile)tile withCacheKey:(NSString *)aCacheKey
{
    //	RMLog(@"DB cache check for tile %d %d %d", tile.x, tile.y, tile.zoom);
    
    __block UIImage *cachedImage = nil;
    
    [_writeQueueLock lock];
    
    [_queue inDatabase:^(FMDatabase *db) {
         RMLog(@"Tile key:%@ Cache key:%@", [RMTileCache tileHash:tile], aCacheKey);
         FMResultSet *results = [db executeQuery:@"SELECT image FROM tiles WHERE tilekey = ?", [RMTileCache tileHash:tile]];
         
         if ([db hadError])
         {
             RMLog(@"DB error while fetching tile data: %@", [db lastErrorMessage]);
             return;
         }
         
         NSData *data = nil;
         
         if ([results next])
         {
             data = [results dataForColumnIndex:0];
             if (data) cachedImage = [UIImage imageWithData:data];
         }
         
         [results close];
     }];
    
    [_writeQueueLock unlock];
    
	return cachedImage;
}

- (void)addImage:(UIImage *)image forTile:(RMTile)tile withCacheKey:(NSString *)aCacheKey {
    RMLog(@"No adding tiles to permanent cache");
}

#pragma mark -

- (NSUInteger)count
{
    return _tileCount;
}

- (NSUInteger)countTiles {
    __block NSUInteger count = 0;
    
    [_writeQueueLock lock];
    
    [_queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"SELECT COUNT(tilekey) FROM tiles"];
         
         if ([results next])
             count = [results intForColumnIndex:0];
         else
             RMLog(@"Unable to count columns");
         
         [results close];
     }];
    
    [_writeQueueLock unlock];
    
	return count;
}

- (void)purgeTiles:(NSUInteger)count {
    RMLog(@"No purging for permanent cache");
}

- (void)removeAllCachedImages {
    RMLog(@"No remove for permanent cache");
}

- (void)removeAllCachedImagesForCacheKey:(NSString *)cacheKey {
   RMLog(@"No remove for permanent cache");
}

- (void)touchTile:(RMTile)tile withKey:(NSString *)cacheKey {
    RMLog(@"No updating for permanent cache");
}

- (void)didReceiveMemoryWarning {
    RMLog(@"Low memory in the database tilecache");
    
    [_writeQueueLock lock];
    [_writeQueue cancelAllOperations];
    [_writeQueueLock unlock];
}

@end
