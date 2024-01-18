#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface PSGCertTrustSettings: UIViewController
- (id)specifierForTrustSettings:(SecCertificateRef)arg1 isRestricted:(BOOL)arg2;
- (void)setFullTrustEnabled:(id)arg1 forSpecifier:(id)arg2;
@end

SecCertificateRef getCertificateAtPath(NSString* certificatePath);
void trustCertificate(NSString* certificatePath);
PSGCertTrustSettings* certTrustSettings = [objc_getClass("PSGCertTrustSettings") alloc];
