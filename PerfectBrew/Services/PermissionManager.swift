import Foundation
import AVFoundation
import Photos

/// Service for managing camera and photo library permissions
class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    /// Check camera permission status
    func checkCameraPermission() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// Request camera permission
    func requestCameraPermission() async -> Bool {
        return await AVCaptureDevice.requestAccess(for: .video)
    }
    
    /// Check photo library permission status
    func checkPhotoLibraryPermission() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    /// Request photo library permission
    func requestPhotoLibraryPermission() async -> PHAuthorizationStatus {
        return await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
    
    /// Check if camera is available on device
    var isCameraAvailable: Bool {
        AVCaptureDevice.default(for: .video) != nil
    }
}

