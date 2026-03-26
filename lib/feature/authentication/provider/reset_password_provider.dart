import 'package:b2b_solution/feature/authentication/models/reset_password_state_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class ResetPasswordNotifier extends StateNotifier<ResetPasswordStateModel> {
  ResetPasswordNotifier() : super(ResetPasswordStateModel());

}