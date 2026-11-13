/// Canonical API roles: CUSTOMER, SHOPKEEPER, INFLUENCER.
/// Older UI code sometimes used "RETAILER" — treat it as SHOPKEEPER.
class RoleUtils {
  static String normalize(String? role) => (role ?? '').trim().toUpperCase();

  static bool isShopkeeper(String? role) {
    final r = normalize(role);
    return r == 'SHOPKEEPER' || r == 'RETAILER';
  }

  static bool isInfluencer(String? role) => normalize(role) == 'INFLUENCER';

  static bool isCustomer(String? role) {
    final r = normalize(role);
    return r == 'CUSTOMER' || r.isEmpty || r == 'USER' || r == 'GUEST';
  }

  static String displayLabel(String? role) {
    if (isShopkeeper(role)) return 'Retailer';
    if (isInfluencer(role)) return 'Influencer';
    return 'Customer';
  }
}
