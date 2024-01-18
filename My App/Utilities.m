#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Utilities.h"

PSGCertTrustSettings* getCertTrustSettings(void) {
    certTrustSettings = [objc_getClass("PSGCertTrustSettings") alloc];
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    myView.backgroundColor = [UIColor redColor];
    certTrustSettings.view = myView;
    return certTrustSettings;
}

SecCertificateRef getCertificateAtPath(NSString* certificatePath) {
    NSData* certificateData = [NSData dataWithContentsOfFile: certificatePath];
    if (certificateData == NULL) {
        return NULL;
    }
    SecCertificateRef certificateRef = SecCertificateCreateWithData(kCFAllocatorMalloc, (__bridge CFDataRef)certificateData);
    return certificateRef;
}

void trustCertificate(NSString* certificatePath, BOOL shouldTrust) {
    SecCertificateRef certificateRef = getCertificateAtPath(certificatePath);
    if (certificateRef == NULL) {
        return;
    }
    [certTrustSettings setFullTrustEnabled: shouldTrust ? @YES : @NO forSpecifier: [certTrustSettings specifierForTrustSettings: certificateRef isRestricted: false]];
}

BOOL isCertificateTrusted(NSString* certificatePath) {
    SecCertificateRef certificateRef = getCertificateAtPath(certificatePath);
    if (certificateRef == NULL) {
        return false;
    }
    return [certTrustSettings isFullTrustEnabled: [certTrustSettings specifierForTrustSettings: certificateRef isRestricted: false]];
}
