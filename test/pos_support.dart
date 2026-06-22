/// POS-feature test support. Re-exports the shared fakes/builders (read-only
/// reuse — the shared `test/support/fakes.dart` is NOT edited here) and adds
/// POS-specific helpers used by the POS register tests.
library;

import 'package:dorukhonai_man/features/products/data/product_models.dart';

export 'support/fakes.dart'
    show
        FakePosRepository,
        FakeProductsRepository,
        sampleShift,
        sampleSale,
        sampleSaleLine,
        paged;

/// A prescription-only (`℞`) product for the rx-confirm path (TZ_03 §C.2).
Product rxProduct({String id = 'rx1', String name = 'Амоксициллин'}) =>
    Product(id: id, name: name, rxRequired: true);

/// A plain (non-rx) product.
Product otcProduct({String id = 'p1', String name = 'Аспирин'}) =>
    Product(id: id, name: name);
