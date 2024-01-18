#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PSGCertTrustSettings: UIViewController
- (id)specifierForTrustSettings:(SecCertificateRef)arg1 isRestricted:(BOOL)arg2;
- (void)setFullTrustEnabled:(id)arg1 forSpecifier:(id)arg2;
- (id)isFullTrustEnabled:(id)arg1;
@end

PSGCertTrustSettings* certTrustSettings;
PSGCertTrustSettings* getCertTrustSettings(void);
SecCertificateRef getCertificateAtPath(NSString* certificatePath);
void trustCertificate(NSString* certificatePath, BOOL shouldTrust);
BOOL isCertificateTrusted(NSString* certificatePath);
