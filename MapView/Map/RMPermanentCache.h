//
//  RMPermanentCache.h
//  MapView
//
//  Created by Ivan Pavlovic on 29/03/2013.
//
//

#import <UIKit/UIKit.h>
#import "RMTileCache.h"

@interface RMPermanentCache :  NSObject <RMTileCache>

/** @name Getting the Database Path */

/** The path to the SQLite database on disk that backs the cache. */
@property (nonatomic, retain) NSString *databasePath;

+ (NSString *)dbPathUsingCacheDir:(BOOL)useCacheDir;

/** @name Initializing Database Caches */

/** Initializes and returns a newly allocated database cache object at the given disk path.
 *   @param path The path to use for the database backing.
 *   @return An initialized cache object or `nil` if the object couldn't be created. */
- (id)initWithDatabase:(NSString *)path;

/** Initializes and returns a newly allocated database cache object.
 *   @param useCacheDir If YES, use the temporary cache space for the application, meaning that the cache files can be removed when the system deems it necessary to free up space. If NO, use the application's document storage space, meaning that the cache will not be automatically removed and will be backed up during device backups. The default value is NO.
 *   @return An initialized cache object or `nil` if the object couldn't be created. */
- (id)initUsingCacheDir:(BOOL)useCacheDir;

/** @name Configuring Cache Behavior */

/** Set the cache purge strategy to use for the database.
 *   @param theStrategy The cache strategy to use. */
- (void)setPurgeStrategy:(RMCachePurgeStrategy)theStrategy;

/** Set the maximum tile count allowed in the database.
 *   @param theCapacity The number of tiles to allow to accumulate in the database before purging begins. */
- (void)setCapacity:(NSUInteger)theCapacity;

/** Set the minimum number of tiles to purge when clearing space in the cache.
 *   @param thePurgeMinimum The number of tiles to delete at the time the cache is purged. */
- (void)setMinimalPurge:(NSUInteger)thePurgeMinimum;

/** Set the expiry period for cache purging.
 *   @param theExpiryPeriod The amount of time to elapse before a tile should be removed from the cache. If set to zero, tile count-based purging will be used instead of time-based. */
- (void)setExpiryPeriod:(NSTimeInterval)theExpiryPeriod;

@end
