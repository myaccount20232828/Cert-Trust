#import <Foundation/Foundation.h>
#import "Utilities.h"

SecCertificateRef getCertificateAtPath(NSString* certificatePath) {
    NSData* certificateData = [NSData dataWithContentsOfFile: certificatePath];
    if (certificateData == NULL) {
        return NULL;
    }
    SecCertificateRef certificateRef = SecCertificateCreateWithData(kCFAllocatorMalloc, (__bridge CFDataRef)certificateData);
    return certificateRef;
}

void trustCertificate(NSString* certificatePath, PSGCertTrustSettings* certTrustSettings) {
    SecCertificateRef certificateRef = getCertificateAtPath(certificatePath);
    if (certificateRef == NULL) {
        return;
    }
    [certTrustSettings setFullTrustEnabled: @YES forSpecifier: [certTrustSettings specifierForTrustSettings: certificateRef isRestricted: false]];
}
