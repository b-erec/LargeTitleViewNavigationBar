//
//  NSObject+KVO.h
//  LargeTitleView
//
//  Created by berec on 24/03/2020.
//  Copyright © 2020 Noname. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^KVObserver)(NSDictionary<NSKeyValueChangeKey,id> *_Nullable change);

@interface NSObject (KVO)

- (void)addBlockObserverForKeyPath:(NSString *)keyPath observer:(KVObserver)observer;
- (void)removeBlockObserverForKeyPath:(NSString *)keyPath;
- (void)removeAllBlockObservers;

@end

NS_ASSUME_NONNULL_END
