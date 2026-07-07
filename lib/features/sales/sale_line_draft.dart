import '../utils/egg_log_utils.dart';
import '../utils/sale_quantity_utils.dart';

enum SaleProductType { inventory, livestock, custom }

class SaleLineDraft {
  const SaleLineDraft({
    required this.productType,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.inventoryId,
    this.livestockId,
    this.eggAllocationMode,
    this.eggBatchId,
    this.eggQuantityUnit = EggSaleQuantityUnit.crate,
    this.lineDiscountAmount = 0,
    this.lineDiscountType = 'flat',
    this.eggsPerCrate = defaultEggsPerCrate,
  });

  final SaleProductType productType;
  final String description;
  final int quantity;
  final double unitPrice;
  final String? inventoryId;
  final String? livestockId;
  final String? eggAllocationMode;
  final String? eggBatchId;
  final EggSaleQuantityUnit eggQuantityUnit;
  final double lineDiscountAmount;
  final String lineDiscountType;
  final int eggsPerCrate;

  int get resolvedQuantityEggs {
    if (productType != SaleProductType.inventory) {
      return quantity;
    }
    return saleQuantityInEggs(
      displayQuantity: quantity,
      unit: eggQuantityUnit,
      eggsPerCrate: eggsPerCrate,
    );
  }

  double get lineSubtotal => quantity * unitPrice;

  double get lineDiscountValue => computeLineDiscount(
        lineSubtotal: lineSubtotal,
        discountAmount: lineDiscountAmount,
        discountType: lineDiscountType,
      );

  double get lineTotal =>
      (lineSubtotal - lineDiscountValue).clamp(0, double.infinity);

  double get resolvedUnitPricePerEgg {
    if (productType != SaleProductType.inventory) {
      return unitPrice;
    }
    return saleUnitPricePerEgg(
      displayUnitPrice: unitPrice,
      unit: eggQuantityUnit,
      eggsPerCrate: eggsPerCrate,
    );
  }
}
