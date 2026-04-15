import 'package:flutter_riverpod/legacy.dart';

enum MapFilterType { EMERGENCY, VENDOR }

final mapFilterProvider = StateProvider<MapFilterType>((ref) => MapFilterType.EMERGENCY);