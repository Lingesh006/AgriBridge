/// Data boundary for the app. Firebase adapters can implement this interface
/// without coupling backend code to Flutter widgets.
enum AgriDataKind {
  marketPrices,
  inputs,
  machinery,
  mechanics,
  usedEquipment,
  products,
  enquiries,
  community,
  savedItems,
  bookings,
  notifications,
  retailerMachinery,
}

class AgriRecord {
  const AgriRecord({required this.id, required this.title, this.subtitle = ''});

  final String id;
  final String title;
  final String subtitle;
}

abstract interface class AgriBridgeRepository {
  bool get isConfigured;

  Future<List<AgriRecord>> fetch(AgriDataKind kind);
}

/// Used until a real Firebase-backed repository is configured.
class UnconfiguredAgriBridgeRepository implements AgriBridgeRepository {
  const UnconfiguredAgriBridgeRepository();

  @override
  bool get isConfigured => false;

  @override
  Future<List<AgriRecord>> fetch(AgriDataKind kind) async => const [];
}

AgriDataKind? dataKindForScreen(int screen) => switch (screen) {
  7 => AgriDataKind.marketPrices,
  8 => AgriDataKind.inputs,
  11 || 12 => AgriDataKind.machinery,
  14 || 15 => AgriDataKind.mechanics,
  19 || 20 => AgriDataKind.usedEquipment,
  23 => AgriDataKind.products,
  24 => AgriDataKind.enquiries,
  25 => AgriDataKind.community,
  26 => AgriDataKind.savedItems,
  27 => AgriDataKind.bookings,
  29 => AgriDataKind.notifications,
  30 => AgriDataKind.retailerMachinery,
  _ => null,
};
