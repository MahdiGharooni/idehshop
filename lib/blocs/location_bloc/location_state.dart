import 'package:equatable/equatable.dart';
import 'package:idehshop/blocs/bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

/// initial state
class UninitializedLocationState extends LocationState {}

/// set user new location after moving marker
class SetNewLocationLocationState extends LocationState {}

/// show loading
class ShowLoadingLocationState extends LocationState {}
