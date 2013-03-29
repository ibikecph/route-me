//
//  SMPermanentTileSource.m
//  MapView
//
//  Created by Ivan Pavlovic on 29/03/2013.
//
//

#import "SMPermanentTileSource.h"

@implementation SMPermanentTileSource


- (id)init
{
	if (!(self = [super init]))
        return nil;
    
    self.minZoom = 16;
    self.maxZoom = 16;
    
	return self;
}

- (NSURL *)URLForTile:(RMTile)tile
{
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f",
			  self, tile.zoom, self.minZoom, self.maxZoom);
    
    //    // debug
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://tiles.ibikecph.dk/tiles/%d/%d/%d.png", tile.zoom, tile.x, tile.y]];
}

- (NSString *)uniqueTilecacheKey
{
    // TODO
    //	return @"OpenStreetMap";
  	return @"I Bike CPH";
}

- (NSString *)shortName
{
    // TODO
    //	return @"Open Street Map";
    return @"I Bike CPH";
}

- (NSString *)longDescription
{
    // TODO
    //	return @"Open Street Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
	return @"I Bike CPH, TODO";
}

- (NSString *)shortAttribution
{
    // TODO
    //	return @"© OpenStreetMap CC-BY-SA";
    return @"TODO";
}

- (NSString *)longAttribution
{
    // TODO
    //	return @"Map data © OpenStreetMap, licensed under Creative Commons Share Alike By Attribution.";
    return @"TODO";
}
@end
