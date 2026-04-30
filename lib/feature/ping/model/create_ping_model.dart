enum UrgencyLevel { GENERAL, MODERATE, EMERGENCY }
enum PingTargetType { CONNECTIONS_ONLY, ALL, SPECIFIC }
enum Unit {PIECE,KG,GRAM,LITER,ML,BAG}

class CreatePingState {
  final List<String> connectedIds;
  final String itemName;
  final int neededWithin;
  final String notes;
  final PingTargetType pingTargetType;
  final int quantity;
  final int radius;
  final Unit? unit;
  final bool myConnectionOnly;
  final UrgencyLevel urgencyLevel;
  final bool isLoading;
  final List<String> categories;
  final String? errorMessage;

  CreatePingState({
    this.connectedIds = const [],
    this.itemName = '',
    this.neededWithin = 24,
    this.notes = '',
    this.myConnectionOnly = false,
    this.categories = const [],
    this.pingTargetType = PingTargetType.SPECIFIC,
    this.quantity = 0,
    this.radius = 5,
    this.unit,
    this.urgencyLevel = UrgencyLevel.GENERAL,
    this.isLoading = false,
    this.errorMessage = ''
  });

  Map<String, dynamic> toJson() => {
    "connectedIds": pingTargetType == PingTargetType.CONNECTIONS_ONLY
        ? []
        : connectedIds,
    "itemName": itemName,
    "category": categories,
    "neededWithin": neededWithin,
    "notes": notes,
    "pingTargetType": pingTargetType.name,
    "quantity": quantity,
    "radius": radius,
    "unit": unit?.name,
    "urgencyLevel": urgencyLevel.name,
  };

  CreatePingState copyWith({
    List<String>? connectedIds,
    String? itemName,
    int? neededWithin,
    String? notes,
    List<String>? categories,
    PingTargetType? pingTargetType,
    int? quantity,
    bool? myConnectionOnly,
    int? radius,
    Unit? unit,
    UrgencyLevel? urgencyLevel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CreatePingState(
      connectedIds: connectedIds ?? this.connectedIds,
      itemName: itemName ?? this.itemName,
      neededWithin: neededWithin ?? this.neededWithin,
      notes: notes ?? this.notes,
      myConnectionOnly: myConnectionOnly ?? this.myConnectionOnly,
      categories: categories ?? this.categories,
      pingTargetType: pingTargetType ?? this.pingTargetType,
      quantity: quantity ?? this.quantity,
      radius: radius ?? this.radius,
      unit: unit ?? this.unit,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage
    );
  }
}