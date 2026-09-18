/// Module: parent / p1_home
///
///*************************** FILE INFO ****************************///
/// File Name: parent_cubit.dart
/// Purpose: Declares `ParentCubit` and `ParentState` — the parent's children
///          and which one is selected.
/// Author: Manger Plus team
/// Created: 18/9/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'package:manger_plus/core/constants/app_keys.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/data/repository/auth_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/base_repository/auth_base_repository.dart';
import 'package:manger_plus/features/onboarding/o2_authentication/domain/entities/app_user.dart';

class ParentState {
  final bool loading;
  final List<AppUser> children;
  final String? selectedId;

  const ParentState({
    this.loading = true,
    this.children = const <AppUser>[],
    this.selectedId,
  });

  AppUser? get selected {
    for (final AppUser c in children) {
      if (c.uid == selectedId) return c;
    }
    return children.isEmpty ? null : children.first;
  }
}

class ParentCubit extends Cubit<ParentState> {
  ParentCubit({UsersBaseRepository? users})
      : _users = users ?? UsersRepository(),
        super(const ParentState());

  final UsersBaseRepository _users;
  final GetStorage _storage = GetStorage();
  String _loadedFor = '';

  /// Loads the children listed on [parent]. Called again whenever the
  /// admin changes the list (the session is live) — a no-op otherwise.
  Future<void> load(AppUser parent) async {
    final String key = parent.childrenIds.join(',');
    if (key == _loadedFor && !state.loading) return;
    _loadedFor = key;

    final List<AppUser> kids = await _users.fetchMany(parent.childrenIds);
    kids.sort((a, b) => a.displayName.compareTo(b.displayName));
    final String? remembered = _storage.read(AppKeys.selectedChild);
    if (isClosed) return;
    emit(ParentState(
      loading: false,
      children: kids,
      selectedId: kids.any((AppUser k) => k.uid == remembered)
          ? remembered
          : (kids.isEmpty ? null : kids.first.uid),
    ));
  }

  void select(String uid) {
    _storage.write(AppKeys.selectedChild, uid);
    emit(ParentState(loading: false, children: state.children, selectedId: uid));
  }
}
