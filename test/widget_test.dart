import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agribridge/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> enterFarmer(WidgetTester tester) async {
    await tester.pumpWidget(const AgriBridgeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview OTP screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to role selection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as Farmer'));
    await tester.pumpAndSettle();
  }

  testWidgets('Tamil service labels render on a narrow farmer dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const AgriBridgeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('தமிழ்').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('தொடரவும்'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OTP திரை முன்னோட்டம்'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('பங்கைத் தேர்ந்தெடுக்க தொடரவும்'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('தொடரவும்: விவசாயி'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('விவசாய சேவைகள்'), findsOneWidget);
    expect(find.text('சந்தை விலைகள்'), findsOneWidget);
    expect(find.text('விதைகள்'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('language choice is restored on a fresh app launch', (
    tester,
  ) async {
    await tester.pumpWidget(const AgriBridgeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const AgriBridgeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Phone number'), findsOneWidget);
  });

  testWidgets(
    'farmer service grid fits narrow width and shows repository empty state',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await enterFarmer(tester);

      expect(find.text('Rent farm machinery'), findsOneWidget);
      expect(find.text('Farm services'), findsOneWidget);
      expect(find.text('Weather information'), findsOneWidget);
      expect(find.text('Market prices'), findsOneWidget);
      expect(find.text('Seeds'), findsOneWidget);
      expect(find.text('Fertilizers'), findsOneWidget);
      expect(find.text('Find a mechanic'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Seeds'));
      await tester.pumpAndSettle();
      expect(find.text('No listings available yet'), findsOneWidget);
      expect(
        find.text('Firebase is not configured. No live data is connected.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'machinery search shows no invented results when repository is empty',
    (tester) async {
      await enterFarmer(tester);
      await tester.tap(find.byKey(const Key('hero_search_machinery')));
      await tester.pumpAndSettle();
      expect(find.text('Machinery search'), findsOneWidget);
      expect(find.text('District'), findsOneWidget);
      expect(find.text('Block / Taluk'), findsOneWidget);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Equipment results'), findsOneWidget);
      expect(find.text('No listings available yet'), findsOneWidget);
      expect(find.textContaining('₹'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'retailer can save a product draft on device, clearly unpublished',
    (tester) async {
      await tester.pumpWidget(const AgriBridgeApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preview OTP screen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to role selection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retailer').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue as Retailer'));
      await tester.pumpAndSettle();
      expect(find.text('Retailer workspace'), findsOneWidget);
      expect(find.text('No enquiries yet'), findsOneWidget);

      await tester.tap(find.text('Add a product').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('product_name')),
        'Paddy seed',
      );
      await tester.enterText(find.byKey(const Key('product_price')), '720');
      await tester.enterText(find.byKey(const Key('product_stock')), '42');
      await tester.ensureVisible(find.text('Save product locally'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save product locally'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manage listings'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Paddy seed · ₹720'), findsOneWidget);
      expect(
        find.text(
          'Saved during this session only. Not published to customers.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
