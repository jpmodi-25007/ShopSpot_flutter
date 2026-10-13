import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_web/features/reservation/data/models/reservation_model.dart';

void main() {
  group('ReservationModel', () {
    test('correctly parses qrToken and mediaAssets', () {
      final json = {
        'id': 'res-1',
        'productId': 'prod-1',
        'product': {
          'name': 'Test Product',
          'mediaAssets': [
            {'secureUrl': 'https://example.com/image.jpg'}
          ],
        },
        'shop': {'name': 'Test Shop'},
        'reservedPrice': 99.99,
        'quantity': 2,
        'status': 'ACTIVE',
        'expiresAt': '2026-10-13T12:00:00.000Z',
        'qrToken': 'mock-qr-token',
      };

      final model = ReservationModel.fromJson(json);

      expect(model.id, 'res-1');
      expect(model.productName, 'Test Product');
      expect(model.productImage, 'https://example.com/image.jpg');
      expect(model.qrCode, 'mock-qr-token');
      expect(model.reservedPrice, 99.99);
      expect(model.quantity, 2);
    });
  });
}

