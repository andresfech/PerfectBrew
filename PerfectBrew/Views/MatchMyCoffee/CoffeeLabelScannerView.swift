import SwiftUI
import PhotosUI
import AVFoundation

/// View for scanning coffee bag labels with camera or photo library
struct CoffeeLabelScannerView: View {
    @Binding var isPresented: Bool
    let onImageSelected: (UIImage) -> Void
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var selectedImage: UIImage?
    
    private let permissionManager = PermissionManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding(.top, 40)
                
                Text("Scan Coffee Bag Label")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Take a photo or choose from your library to automatically extract coffee information")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    // Camera button
                    if permissionManager.isCameraAvailable {
                        Button(action: {
                            checkAndRequestCameraPermission()
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.headline)
                                Text("Take Photo")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $showingCamera) {
                            CameraView(image: $selectedImage)
                        }
                    }
                    
                    // Photo library button
                    Button(action: {
                        checkAndRequestPhotoLibraryPermission()
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.headline)
                            Text("Choose from Library")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showingImagePicker) {
                        PhotoPickerView(image: $selectedImage)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            }
            .navigationTitle("Scan Label")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(permissionMessage)
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    onImageSelected(image)
                    isPresented = false
                }
            }
        }
    }
    
    private func checkAndRequestCameraPermission() {
        let status = permissionManager.checkCameraPermission()
        
        switch status {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            Task {
                let granted = await permissionManager.requestCameraPermission()
                await MainActor.run {
                    if granted {
                        showingCamera = true
                    } else {
                        showPermissionDeniedAlert(for: "camera")
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(for: "camera")
        @unknown default:
            showPermissionDeniedAlert(for: "camera")
        }
    }
    
    private func checkAndRequestPhotoLibraryPermission() {
        let status = permissionManager.checkPhotoLibraryPermission()
        
        switch status {
        case .authorized, .limited:
            showingImagePicker = true
        case .notDetermined:
            Task {
                let status = await permissionManager.requestPhotoLibraryPermission()
                await MainActor.run {
                    if status == .authorized || status == .limited {
                        showingImagePicker = true
                    } else {
                        showPermissionDeniedAlert(for: "photo library")
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(for: "photo library")
        @unknown default:
            showPermissionDeniedAlert(for: "photo library")
        }
    }
    
    private func showPermissionDeniedAlert(for type: String) {
        permissionMessage = "PerfectBrew needs access to your \(type) to scan coffee bag labels. Please enable it in Settings."
        showingPermissionAlert = true
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Photo Picker View

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let result = results.first else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.image = image
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

