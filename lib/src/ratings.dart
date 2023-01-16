/// Copyright 2021, domohuhn.
/// License: BSD-3-Clause
/// See LICENSE for the full text of the license

/// Rating thresholds for the results.
class Ratings {
  double _failure = 100;
  bool _initialized = false;
  final List<_Limit> _limits = [];

  set failure(double v) {
    _initialized = true;
    _failure = v;
  }

  double get failure => _failure;

  bool get initialized => _initialized;

  /// Adds a rating with the [lower] boundary called [name].
  void addRating(double lower, String name) {
    _limits.add(_Limit(lower, name));
    _limits.sort((lhs, rhs) => rhs.lowerBoundary.compareTo(lhs.lowerBoundary));
  }

  /// Checks if a number of [percentage] detected mutations should be marked as successful.
  bool isSuccessful(double percentage) {
    return _failure <= percentage;
  }

  /// Gets the rating for [percentage] detected mutations.
  /// If now rating is found, N/A will be returned.
  String rating(double percentage) {
    for (final l in _limits) {
      if (l.lowerBoundary <= percentage) {
        return l.name;
      }
    }
    return 'N/A';
  }

  @override
  String toString() {
    return '${_limits.length} quality ratings: Failure threshold $_failure%';
  }

  void sanitize() {
    if (initialized) {
      return;
    }
    _failure = 80.0;
    addRating(100, 'A');
    addRating(80, 'B');
    addRating(60, 'C');
    addRating(40, 'D');
    addRating(20, 'E');
    addRating(0, 'F');
  }
}

class _Limit {
  _Limit(this.lowerBoundary, this.name);

  double lowerBoundary;
  String name;
}
