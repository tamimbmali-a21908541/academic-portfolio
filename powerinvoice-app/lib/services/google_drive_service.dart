import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

/// Google Drive Service for uploading invoice PDFs
class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  /// Sign in to Google Account
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print('Error signing in: $error');
      return null;
    }
  }

  /// Sign out from Google Account
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Get current signed in account
  static Future<GoogleSignInAccount?> getCurrentAccount() async {
    return await _googleSignIn.signInSilently();
  }

  /// Check if user is signed in
  static Future<bool> isSignedIn() async {
    final account = await getCurrentAccount();
    return account != null;
  }

  /// Upload PDF file to Google Drive
  static Future<String?> uploadPdfToDrive(File pdfFile, String fileName) async {
    try {
      // Get current account
      final account = await getCurrentAccount();
      if (account == null) {
        print('No Google account signed in');
        return null;
      }

      // Get authentication headers
      final authHeaders = await account.authHeaders;
      final authenticateClient = _GoogleAuthClient(authHeaders);

      // Create Drive API instance
      final driveApi = drive.DriveApi(authenticateClient);

      // Create file metadata
      final driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.mimeType = 'application/pdf';
      driveFile.parents = ['root']; // Save to root folder

      // Read file bytes
      final fileBytes = await pdfFile.readAsBytes();

      // Upload file
      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(
          Stream.value(fileBytes),
          fileBytes.length,
        ),
      );

      print('File uploaded successfully: ${response.id}');
      return response.id;
    } catch (error) {
      print('Error uploading to Drive: $error');
      return null;
    }
  }

  /// Create a folder in Google Drive (optional)
  static Future<String?> createFolder(String folderName) async {
    try {
      final account = await getCurrentAccount();
      if (account == null) return null;

      final authHeaders = await account.authHeaders;
      final authenticateClient = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final driveFile = drive.File();
      driveFile.name = folderName;
      driveFile.mimeType = 'application/vnd.google-apps.folder';
      driveFile.parents = ['root'];

      final response = await driveApi.files.create(driveFile);
      print('Folder created: ${response.id}');
      return response.id;
    } catch (error) {
      print('Error creating folder: $error');
      return null;
    }
  }

  /// Upload PDF to specific folder
  static Future<String?> uploadPdfToFolder(
    File pdfFile,
    String fileName,
    String folderId,
  ) async {
    try {
      final account = await getCurrentAccount();
      if (account == null) return null;

      final authHeaders = await account.authHeaders;
      final authenticateClient = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.mimeType = 'application/pdf';
      driveFile.parents = [folderId];

      final fileBytes = await pdfFile.readAsBytes();

      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(
          Stream.value(fileBytes),
          fileBytes.length,
        ),
      );

      print('File uploaded to folder: ${response.id}');
      return response.id;
    } catch (error) {
      print('Error uploading to folder: $error');
      return null;
    }
  }
}

/// Custom HTTP client for Google Sign-In authentication
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
