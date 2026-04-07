import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../model/create_ping_model.dart';
import 'connection_provider.dart';

class CreatePingNotifier extends StateNotifier<CreatePingState> {
  final Ref ref;

  CreatePingNotifier(this.ref) : super(CreatePingState()) {
    // Basic Text Listeners
    itemNameController.addListener(() => state = state.copyWith(itemName: itemNameController.text));
    notesController.addListener(() => state = state.copyWith(notes: notesController.text));

    quantityController.addListener(() {
      final text = quantityController.text;
      final val = int.tryParse(text) ?? 0;
      state = state.copyWith(quantity: val);
    });

    radiusController.addListener(() {
      final val = int.tryParse(radiusController.text) ?? 5;
      state = state.copyWith(radius: val);
    });

    categoryController.addListener(() {
      final text = categoryController.text.trim();
      final list = text.isEmpty ? <String>[] : text.split(", ");
      if (state.categories.join(',') != list.join(',')) {
        state = state.copyWith(categories: list);
      }
    });
  }

  // Controllers
  final itemNameController = TextEditingController();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();
  final unitController = TextEditingController();
  final radiusController = TextEditingController(text: "5");
  final categoryController = TextEditingController();
  final connectionDisplayController = TextEditingController();

  /// Logic for Enums (Outside Constructor)
  void updateUnit(Unit unit) {
    state = state.copyWith(unit: unit);
    unitController.text = unit.name;
  }

  void updateUrgency(UrgencyLevel level) {
    state = state.copyWith(urgencyLevel: level);
  }

  /// Toggles between sending to everyone vs specific selection
  void toggleMyConnectionOnly() {
    final newValue = !state.myConnectionOnly;

    if (newValue) {
      final allConnections = ref.read(connectionProvider).connections;
      final allIds = allConnections.map((e) => e.id).toList();

      state = state.copyWith(
        myConnectionOnly: true,
        connectedIds: allIds,
        pingTargetType: PingTargetType.CONNECTIONS_ONLY,
      );
      connectionDisplayController.text = "All Connections (${allIds.length})";
    } else {
      state = state.copyWith(
        myConnectionOnly: false,
        connectedIds: [],
        pingTargetType: PingTargetType.SPECIFIC,
      );
      connectionDisplayController.text = "";
    }
  }

  /// Updates specific connection IDs (usually called from CustomSelectField)
  void updateConnections(List<String> ids) {
    final allConnectionsCount = ref.read(connectionProvider).connections.length;
    final isAllSelected = ids.length == allConnectionsCount && allConnectionsCount > 0;

    state = state.copyWith(
      connectedIds: ids,
      myConnectionOnly: isAllSelected,
      pingTargetType: isAllSelected ? PingTargetType.CONNECTIONS_ONLY : PingTargetType.SPECIFIC,
    );

    if (isAllSelected) {
      connectionDisplayController.text = "All Connections (${ids.length})";
    } else if (ids.isEmpty) {
      connectionDisplayController.text = "";
    } else {
      connectionDisplayController.text = "${ids.length} selected";
    }
  }

  Future<void> sendPing() async {
    state = state.copyWith(isLoading: true);

    try {
      final Map<String, dynamic> payload = state.toJson();
      log('$payload');

      final response = await NetworkCaller().postRequest(
        AppUrl.createPing,
        body: payload,
        token: AuthService.token,
      );

      if (response.isSuccess) {
        state = state.copyWith(isLoading: false);
        resetForm();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void resetForm() {
    itemNameController.clear();
    quantityController.clear();
    notesController.clear();
    unitController.clear();
    radiusController.text = "5";
    categoryController.clear();
    connectionDisplayController.clear();
    state = CreatePingState();
  }

  @override
  void dispose() {
    itemNameController.dispose();
    quantityController.dispose();
    notesController.dispose();
    unitController.dispose();
    radiusController.dispose();
    categoryController.dispose();
    connectionDisplayController.dispose();
    super.dispose();
  }
}

final createPingProvider = StateNotifierProvider<CreatePingNotifier, CreatePingState>((ref) {
  return CreatePingNotifier(ref);
});