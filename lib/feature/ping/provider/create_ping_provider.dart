import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/service/app_url.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/network_caller.dart';
import '../model/connection_model.dart';
import '../model/create_ping_model.dart';
import 'connection_provider.dart';

class CreatePingNotifier extends StateNotifier<CreatePingState> {
  final Ref ref;

  CreatePingNotifier(this.ref) : super(CreatePingState()) {
    _initListeners();
  }

  void _initListeners() {
    itemNameController.addListener(() => state = state.copyWith(itemName: itemNameController.text));
    notesController.addListener(() => state = state.copyWith(notes: notesController.text));
    quantityController.addListener(() => state = state.copyWith(quantity: int.tryParse(quantityController.text) ?? 0));
    radiusController.addListener(() => state = state.copyWith(radius: int.tryParse(radiusController.text) ?? 5));

    categoryController.addListener(() {
      final list = categoryController.text.isEmpty ? <String>[] : categoryController.text.split(", ");
      state = state.copyWith(categories: list);
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

  void updateUnit(Unit unit) {
    state = state.copyWith(unit: unit);
    unitController.text = unit.name;
  }

  void updateUrgency(UrgencyLevel level) => state = state.copyWith(urgencyLevel: level);

  /// SCENARIO A: Manual Selection from the Dropdown
  void updateConnectedIds(List<dynamic> selectedItems) {
    final currentUserId = AuthService.id;

    final List<String> partnerIds = selectedItems.whereType<ConnectionModel>().map((conn) {
      return conn.senderId == currentUserId ? conn.receiverId : conn.senderId;
    }).toList();

    final allConnections = ref.read(connectionProvider).connections;
    bool isAllSelected = partnerIds.length == allConnections.length && partnerIds.isNotEmpty;

    state = state.copyWith(
      connectedIds: partnerIds,
      myConnectionOnly: isAllSelected,
      pingTargetType: isAllSelected ? PingTargetType.CONNECTIONS_ONLY : PingTargetType.SPECIFIC,
    );
  }

  /// SCENARIO B: Toggle Button (Select All)
  void toggleMyConnectionOnly() {
    final bool isTurningOn = !state.myConnectionOnly;
    final currentUserId = AuthService.id ?? "";
    final allConnections = ref.read(connectionProvider).connections;

    if (isTurningOn) {
      final List<String> partnerIds = allConnections.map((conn) {
        return conn.senderId == currentUserId ? conn.receiverId : conn.senderId;
      }).toList();

      state = state.copyWith(
        myConnectionOnly: true,
        connectedIds: partnerIds,
        pingTargetType: PingTargetType.CONNECTIONS_ONLY,
      );

      connectionDisplayController.text = "All connections selected";
    } else {
      state = state.copyWith(
        myConnectionOnly: false,
        connectedIds: [],
        pingTargetType: PingTargetType.SPECIFIC,
      );
      connectionDisplayController.clear();
    }
  }

  Future<bool> sendPing() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final Map<String, dynamic> payload = state.toJson();
      log('Ping Payload: $payload');

      final response = await NetworkCaller().postRequest(
        AppUrl.createPing,
        body: payload,
        token: AuthService.token,
      );

      if (response.isSuccess) {
        state = state.copyWith(isLoading: false);
        resetForm();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage ?? "Failed to create ping",
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An error occurred");
      return false;
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