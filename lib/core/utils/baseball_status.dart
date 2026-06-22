class BaseballStatus {
  static const _liveInnings = {
    'IN1',
    'IN2',
    'IN3',
    'IN4',
    'IN5',
    'IN6',
    'IN7',
    'IN8',
    'IN9',
    'IN10',
    'IN11',
    'IN12',
    'IN13',
    'IN14',
    'IN15',
  };
  static const _halfInnings = {
    '1H',
    '2H',
    '3H',
    '4H',
    '5H',
    '6H',
    '7H',
    '8H',
    '9H',
    '10H',
    '11H',
    '12H',
    '13H',
    '14H',
    '15H',
  };
  static const _liveBreaks = {'BT', 'HT', 'LIVE'};
  static const _finished = {
    'FT',
    'AET',
    'AWD',
    'WO',
  };
  static const _cancelled = {
    'CANC',
    'CANCELLED',
    'CANCELED',
    'ABD',
    'ABANDONED',
  };
  static const _postponed = {
    'PST',
    'POSTPONED',
    'POST',
    'PP',
  };
  static const _scheduled = {'NS', 'SCHEDULED', 'TBD'};

  static bool isLive(String? status) {
    if (status == null) return false;
    return _liveInnings.contains(status) ||
        _halfInnings.contains(status) ||
        _liveBreaks.contains(status);
  }

  static bool isFinished(String? status) {
    if (status == null) return false;
    return _finished.contains(status);
  }

  static bool isCancelled(String? status) {
    if (status == null) return false;
    return _cancelled.contains(status);
  }

  static bool isPostponed(String? status) {
    if (status == null) return false;
    return _postponed.contains(status);
  }

  static bool isScheduled(String? status) {
    if (status == null) return false;
    return _scheduled.contains(status);
  }

  static bool isInterrupted(String? status) => status == 'INTR';

  static String? extractInningNumber(String? status) {
    if (status == null) return null;
    if (_liveInnings.contains(status)) return status.replaceFirst('IN', '');
    if (_halfInnings.contains(status)) return status.replaceFirst('H', '');
    return null;
  }

  /// Display text for fixture match row
  static String displayStatus(String? status) {
    if (status == null) return '';
    if (isScheduled(status)) return ''; // show time instead
    if (isCancelled(status)) return 'Cancelled';
    if (isPostponed(status)) return 'Postponed';
    if (isFinished(status)) return 'Final';
    if (status == 'INTR') return 'INT';
    if (_liveInnings.contains(status)) {
      final inning = extractInningNumber(status);
      if (inning != null) return '${inning}T';
    }
    if (_halfInnings.contains(status)) {
      final inning = extractInningNumber(status);
      if (inning != null) return '${inning}B';
    }
    if (_liveBreaks.contains(status)) return 'LIVE';
    return status;
  }
}
