//
//  PHImageManager+TNKRequestImages.m
//  Pods
//
//  Created by David Beck on 2/24/15.
//
//

#import "PHImageManager+TNKRequestImages.h"


@implementation PHImageManager (TNKRequestImages)

- (NSDictionary *)requestImagesForAssets:(NSArray *)assets
                              targetSize:(CGSize)targetSize
                             contentMode:(PHImageContentMode)contentMode
                                 options:(PHImageRequestOptions *)options
                           resultHandler:(void (^)(NSDictionary *results,
                                                   NSDictionary *infos))resultHandler {
    if (options.deliveryMode == PHImageRequestOptionsDeliveryModeOpportunistic) {
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    
    NSMutableDictionary *results = [NSMutableDictionary new];
    NSMutableDictionary *infos = [NSMutableDictionary new];
    NSMutableDictionary *requestIDs = [NSMutableDictionary new];
    dispatch_group_t group = dispatch_group_create();
    
    for (PHAsset *asset in assets) {
        dispatch_group_enter(group);
        
        PHImageRequestID requestID = [self requestImageForAsset:asset targetSize:targetSize contentMode:contentMode options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            results[asset.localIdentifier] = result;
            infos[asset.localIdentifier] = info;
            
            dispatch_group_leave(group);
        }];
        
        requestIDs[asset.localIdentifier] = @(requestID);
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        resultHandler(results, infos);
    });
    
    return requestIDs;
}

@end