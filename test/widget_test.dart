// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segundo_app_test/main.dart'; // Adjust with your app's main import
import 'package:share_plus/share_plus.dart';
// Import the platform interface
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
// It's good practice to import the specific file if known, or ensure the library file exports it.
// For share_plus, SharePlatform is typically available via the main library export.
import 'package:share_plus_platform_interface/platform_interface/share_plus_platform.dart' as sp_platform;
import 'package:plugin_platform_interface/plugin_platform_interface.dart'; // For MockPlatformInterfaceMixin
import 'dart:async'; // Required for Future

// Mock class for SharePlatform (from share_plus_platform_interface)
// Implement MockPlatformInterfaceMixin to satisfy PlatformInterface.verifyToken
class MockSharePlatform extends Fake implements sp_platform.SharePlatform, MockPlatformInterfaceMixin {
  String? sharedText;
  String? subject;
  Rect? sharePositionOriginRect; // Renamed to avoid conflict if a class named Rect is imported directly
  List<XFile>? filesList;  // Renamed
  String? uriString; // Renamed

  // Keep track of how many times methods are called
  int shareCallCount = 0;
  int shareFilesCallCount = 0; // For XFile list
  int shareWithResultCallCount = 0;
  int shareFilesWithResultCallCount = 0; // For XFile list
  int shareUriCallCount = 0;
  // int shareLegacyFilesCallCount = 0; // For List<String> paths if that's still a method

  // This 'share' method must match SharePlatform's 'share' which takes ShareParams
  @override
  Future<sp_platform.ShareResult> share(sp_platform.ShareParams params) async {
    shareCallCount++;
    // Extract text for test verification if needed, though SharePlus.share in main.dart uses ShareParams
    // which likely calls shareWithResult on the platform, not this 'share(ShareParams)'
    sharedText = params.text;
    this.subject = params.subject;
    this.sharePositionOriginRect = params.sharePositionOrigin;
    return sp_platform.ShareResult(params.text ?? '', sp_platform.ShareResultStatus.success);
  }

  // This 'shareFiles' method must match SharePlatform's 'shareFiles'
  // Assuming it takes a params object like ShareFilesParams, or similar to XFile list
  @override
  Future<sp_platform.ShareResult> shareFiles(List<XFile> files, {String? subject, String? text, Rect? sharePositionOrigin, List<String>? fileNameOverrides}) async {
    shareFilesCallCount++;
    this.filesList = files; // Keep this if shareFiles is called with List<XFile> directly
    this.subject = subject;
    sharedText = text;
    this.sharePositionOriginRect = sharePositionOrigin;
    // Return a ShareResult as per typical new interface methods
    return sp_platform.ShareResult('mock_files_shared', sp_platform.ShareResultStatus.success);
  }

  // This is the method SharePlus.instance.share(ShareParams) in main.dart actually calls on the platform.
  @override
  Future<sp_platform.ShareResult> shareWithResult(String text, {String? subject, Rect? sharePositionOrigin}) async {
    shareWithResultCallCount++;
    sharedText = text; // This is what we check in the test
    this.subject = subject;
    this.sharePositionOriginRect = sharePositionOrigin;
    return sp_platform.ShareResult(text, sp_platform.ShareResultStatus.success); // text is the raw value
  }

  @override
  Future<sp_platform.ShareResult> shareFilesWithResult(List<XFile> files, {String? subject, String? text, Rect? sharePositionOrigin, List<String>? fileNameOverrides}) async {
    shareFilesWithResultCallCount++;
    this.filesList = files;
    this.subject = subject;
    sharedText = text;
    this.sharePositionOriginRect = sharePositionOrigin;
    return sp_platform.ShareResult('mock_shared_files_value', sp_platform.ShareResultStatus.success);
  }

  // This 'shareUri' method should also match SharePlatform's 'shareUri'
  // Assuming it takes a params object like ShareUriParams or similar to Uri
  @override
  Future<sp_platform.ShareResult> shareUri(Uri uri, {Rect? sharePositionOrigin}) async {
    shareUriCallCount++;
    this.uriString = uri.toString();
    this.sharePositionOriginRect = sharePositionOrigin;
    // Return a ShareResult
    return sp_platform.ShareResult(uri.toString(), sp_platform.ShareResultStatus.success);
  }
}


void main() {
  // Store the original SharePlatform instance
  final sp_platform.SharePlatform originalPlatform = sp_platform.SharePlatform.instance;
  late MockSharePlatform mockSharePlatform; // Corrected type name

  setUp(() {
    // Create a new mock platform before each test
    mockSharePlatform = MockSharePlatform(); // Corrected type name
    // Set the platform instance to the mock
    sp_platform.SharePlatform.instance = mockSharePlatform;
  });

  tearDown(() {
    // Restore the original platform instance after each test
    sp_platform.SharePlatform.instance = originalPlatform;
  });

  testWidgets('initial UI loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: Home()));

    // Verify Image.asset for "assets/logo.png" is present.
    expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/logo.png'), findsOneWidget);

    // Verify the initial text "Clique abaixo para gerar uma frase!" is present.
    expect(find.text("Clique abaixo para gerar uma frase!"), findsOneWidget);

    // Verify the "Nova Frase" ElevatedButton is present.
    expect(find.widgetWithText(ElevatedButton, "Nova Frase"), findsOneWidget);

    // Verify the share IconButton in the AppBar is present.
    expect(find.byIcon(Icons.share), findsOneWidget);
    expect(find.ancestor(of: find.byIcon(Icons.share), matching: find.byType(AppBar)), findsOneWidget);
  });

  testWidgets('quote generation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    // Initial text
    const initialText = "Clique abaixo para gerar uma frase!";
    expect(find.text(initialText), findsOneWidget);

    // Tap the "Nova Frase" button.
    await tester.tap(find.widgetWithText(ElevatedButton, "Nova Frase"));
    await tester.pumpAndSettle(); // pumpAndSettle to allow time for setState and UI update

    // Verify that the initial text is no longer present.
    expect(find.text(initialText), findsNothing);

    // Verify that some new text (a quote) is displayed.
    // This is a basic check; we are not checking against the exact list of quotes
    // to avoid brittleness due to randomization.
    // We find the Text widget that is a descendant of the semi-transparent container.
    final quoteTextFinder = find.descendant(
      of: find.byWidgetPredicate((widget) => widget is Container && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).color == Colors.black.withOpacity(0.5)),
      matching: find.byType(Text),
    );
    expect(quoteTextFinder, findsOneWidget);
    final quoteTextWidget = tester.widget<Text>(quoteTextFinder);
    expect(quoteTextWidget.data, isNotNull);
    expect(quoteTextWidget.data, isNotEmpty);
    expect(quoteTextWidget.data != initialText, isTrue);
  });

  testWidgets('share button calls share method', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    const testQuote = "This is a test quote for sharing.";

    // Manually set a quote to ensure predictability for this test
    // This requires access to the State, which is not straightforward here.
    // Instead, we'll generate a quote first, then tap share.
    // This also means the shared text will be one of the random quotes.

    // Tap the "Nova Frase" button to generate a quote.
    await tester.tap(find.widgetWithText(ElevatedButton, "Nova Frase"));
    await tester.pumpAndSettle();

    // Find the generated quote text
    final quoteTextFinder = find.descendant(
      of: find.byWidgetPredicate((widget) => widget is Container && widget.decoration is BoxDecoration && (widget.decoration as BoxDecoration).color == Colors.black.withOpacity(0.5)),
      matching: find.byType(Text),
    );
    expect(quoteTextFinder, findsOneWidget);
    final String actualGeneratedQuote = tester.widget<Text>(quoteTextFinder).data!;

    // Tap the share button.
    await tester.tap(find.byIcon(Icons.share));
    await tester.pump(); // Allow time for the share method to be called

    // Verify that SharePlatform.share(ShareParams) was called
    // and that it was called with the correct text via the params.
    expect(mockSharePlatform.shareCallCount, 1);
    expect(mockSharePlatform.sharedText, actualGeneratedQuote); // sharedText is set from params.text in the mock
  });
}
