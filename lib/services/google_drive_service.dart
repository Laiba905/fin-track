import 'dart:convert'; // Native JSON string to bytes encoder
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as sign_in;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleDriveService {
  static sign_in.GoogleSignInAccount? _currentUser;
  static bool _initialized = false;

  /// --- 🔑 GOOGLE SIGN-IN HANDSHAKE ENGINE ---
  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      // Android 'serverClientId must be provided' error ko fix karne k liye aapki id yahan inject kar di hai
      await sign_in.GoogleSignIn.instance.initialize(
        serverClientId: '543940238158-rnj79a5nvqvocm0j8r74figv0ldq7eum.apps.googleusercontent.com',
      );
      _initialized = true;

      // Listen for authentication events to maintain current user state
      sign_in.GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (event is sign_in.GoogleSignInAuthenticationEventSignIn) {
          _currentUser = event.user;
        } else if (event is sign_in.GoogleSignInAuthenticationEventSignOut) {
          _currentUser = null;
        }
      });
    }
  }

  // Silent restore of existing session (No UI)
  static Future<sign_in.GoogleSignInAccount?> restoreSession() async {
    try {
      await _ensureInitialized();
      _currentUser = await sign_in.GoogleSignIn.instance.attemptLightweightAuthentication();
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  static Future<sign_in.GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();

      // Check for existing session first
      final silentAccount = await restoreSession();
      if (silentAccount != null) return silentAccount;

      // Interactive sign-in using your explicit scope configurations
      _currentUser = await sign_in.GoogleSignIn.instance.authenticate(
        scopeHint: [drive.DriveApi.driveAppdataScope],
      );
      return _currentUser;
    } catch (error) {
      debugPrint("GOOGLE SIGN IN SERVICE ERROR: $error");
      rethrow;
    }
  }

  /// --- ☁️ SECURE DATA BACKUP ROUTINE MODULE ---
  static Future<bool> backupData(String jsonData) async {
    try {
      await _ensureInitialized();

      if (_currentUser == null) {
        // Attempt lightweight authentication to restore previous session
        _currentUser = await restoreSession();
        if (_currentUser == null) {
          _currentUser = await signIn();
          if (_currentUser == null) return false;
        }
      }

      // Obtain authorization for the specific scope
      final scopes = [drive.DriveApi.driveAppdataScope];
      final auth = await _currentUser!.authorizationClient.authorizeScopes(scopes);

      // Use extension method from 'extension_google_sign_in_as_googleapis_auth' to get an authenticated HTTP client
      final httpClient = auth.authClient(scopes: scopes);
      final driveApi = drive.DriveApi(httpClient);

      final backupFileName = "fintrack_secure_backup.json";

      final fileList = await driveApi.files.list(
        q: "name = '$backupFileName'",
        spaces: 'appDataFolder',
      );

      final drive.File fileMetadata = drive.File()
        ..name = backupFileName
        ..parents = ['appDataFolder'];

      // Converting plain json string into standard bytes array block safely
      final List<int> bytesPayload = utf8.encode(jsonData);
      final mediaStream = Stream<List<int>>.value(bytesPayload);
      final mediaUpload = drive.Media(mediaStream, bytesPayload.length);

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final existingFileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: mediaUpload,
        );
        debugPrint("Cloud backup payload updated successfully.");
      } else {
        await driveApi.files.create(
          fileMetadata,
          uploadMedia: mediaUpload,
        );
        debugPrint("Fresh backup node allocated inside Drive space.");
      }
      return true;
    } catch (e) {
      debugPrint("BACKUP PROCESS EXCEPTION: $e");
      return false;
    }
  }

  /// --- 📥 CLOUD DATA RESTORE / FETCH ENGINE ---
  static Future<String?> downloadBackupData() async {
    try {
      await _ensureInitialized();

      if (_currentUser == null) {
        _currentUser = await restoreSession();
        if (_currentUser == null) {
          _currentUser = await signIn();
          if (_currentUser == null) return null;
        }
      }

      // Obtain authorization for the specific scope
      final scopes = [drive.DriveApi.driveAppdataScope];
      final auth = await _currentUser!.authorizationClient.authorizeScopes(scopes);

      // Authenticated HTTP Client fetch flow
      final httpClient = auth.authClient(scopes: scopes);
      final driveApi = drive.DriveApi(httpClient);

      final backupFileName = "fintrack_secure_backup.json";

      // AppDataFolder scanning database query node
      final fileList = await driveApi.files.list(
        q: "name = '$backupFileName'",
        spaces: 'appDataFolder',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final fileId = fileList.files!.first.id!;

        // Fetching media content stream from Google Drive node
        final drive.Media media = await driveApi.files.get(
          fileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;

        final List<int> dataBytes = [];
        await for (var chunk in media.stream) {
          dataBytes.addAll(chunk);
        }

        // Parse bytes payload directly back to standard json string representation
        final String jsonString = utf8.decode(dataBytes);
        debugPrint("Cloud backup snapshot successfully downloaded.");
        return jsonString;
      }

      debugPrint("No pre-existing backup node discovered on cloud storage.");
      return null;
    } catch (e) {
      debugPrint("FETCH RESTORE ANOMALY ERROR: $e");
      return null;
    }
  }

  /// --- 🚪 DISCONNECT & TERMINATE SESSION ---
  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await sign_in.GoogleSignIn.instance.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint("Sign out anomaly tracked: $e");
    }
  }
}
