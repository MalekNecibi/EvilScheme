#import "EVKURLPortions.h"
#import "NSURL+ComponentAdditions.h"
// #import <Foundation/NSJSONSerialization.h>

@interface GEOMapItemStorage : NSObject
-(instancetype)initWithData:(NSData *)data;
-(NSDictionary *)addressDictionary;
@end

@implementation EVKMapItemUnwrapperPortion

- (NSString *)evaluateUnencodedWithURL:(NSURL *)url {
    NSData *b64 = [[NSData alloc] initWithBase64EncodedString:[url trimmedResourceSpecifier]
                                                      options:0];
    
    NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:b64
                                                                    options:0
                                                                     format:nil
                                                                      error:nil];
    @try {
        // NSData *d = plist[@"MKMapItemLaunchAdditionsMapItems"][0][@"MKMapItemGEOMapItem"];
        
        NSDictionary *geo_parent = plist[@"MKMapItemLaunchAdditionsMapItems"][0];
        if (! [geo_parent objectForKey:@"MKMapItemGEOMapItem"]) {
           geo_parent = plist[@"MKMapItemLaunchAdditionsMapItems"][1];
        }
        NSData *geo = geo_parent[@"MKMapItemGEOMapItem"];
        NSDictionary *addr = [[[GEOMapItemStorage alloc] initWithData:geo] addressDictionary];
        
        // TODO: Free alloc 
        
        NSString *formattedString = [NSString stringWithFormat:@"%@ %@, %@ %@",
            // addr[@"Name"] ? : @"",
            addr[@"Street"] ? : @"",
            addr[@"City"] ? : @"",
            addr[@"State"] ? : @"",
            addr[@"ZIP"] ? : @""
            ];
        
        // Check if successsfully extracted some address info
        if (! [formattedString isEqualToString:@" ,  "]) {
            // Optional: Prepend the name if it exists
            return [NSString stringWithFormat:@"%@ %@",
                addr[@"Name"] ? : @"",
                formattedString
                ]; 
            // return formattedString;
        }
        
        
        
        // Find the internal apple maps url
        // extract the q query
        
        NSString *GEODataURL = [NSString stringWithFormat:@"%@", geo_parent[@"MKMapItemURLString"]];
        
        NSString *escapedString = [GEODataURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL* url = [NSURL URLWithString:escapedString];
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:true];
        NSArray *queryItems = urlComponents.queryItems;
        for (NSURLQueryItem *item in queryItems) {
            if ([item.name isEqualToString:@"q"]) {
                return item.value;
            }
        }

        // Otherwise fail and return nothing
        
        return @"";
        

    } @catch (NSException *ex) {
        return @"error caught";
    }
}

- (NSString *)stringRepresentation { return @"Address unwrapper"; }

@end



