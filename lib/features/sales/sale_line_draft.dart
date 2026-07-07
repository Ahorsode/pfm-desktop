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
  });

  final SaleProductType productType;
  final String description;
  final int quantity;
  final double unitPrice;
  final String? inventoryId;
  final String? livestockId;
  final String? eggAllocationMode;
  final String? eggBatchId;

  double get lineTotal => quantity * unitPrice;
}
