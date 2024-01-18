#import <Foundation/Foundation.h>

-(SecCertificateRef*)getCertificateAtPath(NSString* certificatePath);

@interface PSGCertTrustSettings: UIViewController
- (id)specifierForTrustSettings:(SecCertificateRef)arg1 isRestricted:(BOOL)arg2;
- (void)setFullTrustEnabled:(id)arg1 forSpecifier:(id)arg2;
@end
