import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';

@freezed
class AsyncState<T> with _$AsyncState<T> {
  const factory AsyncState.initial() = _Initial<T>;
  const factory AsyncState.loading() = _Loading<T>;
  const factory AsyncState.success(T data) = _Success<T>;
  const factory AsyncState.error(String message) = _Error<T>;

  bool get isLoading => this is _Loading;
  bool get isSuccess => this is _Success;
  bool get isError => this is _Error;
  bool get isInitial => this is _Initial;

  T? get dataOrNull => mapOrNull(success: (state) => state.data);
  String? get errorOrNull => mapOrNull(error: (state) => state.message);
}