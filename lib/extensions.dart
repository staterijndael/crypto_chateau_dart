extension NullableObjectX<T extends Object> on T? {
  R when<R>({
    required R Function() isNull,
    required R Function(T object) isNotNull,
  }) =>
      this == null ? isNull() : isNotNull(this!);

  R? mayBeWhen<R>({
    R Function()? isNull,
    R Function(T object)? isNotNull,
  }) =>
      this == null ? isNull?.call() : isNotNull?.call(this!);
}
