import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/report_models.dart';
import '../../core/theme/tokens/color_tokens.dart';
import '../../shared/widgets/appbar/custom_appbar.dart';
import '../../shared/widgets/cards/report_card.dart';
import 'report_dummy_data.dart';

// TODO(Phase 5-5): Replace dummy pagination with API + cursors.
/// Soccer match reports list with simulated infinite scroll (max 20 items).
class SoccerReportListPage extends StatefulWidget {
  const SoccerReportListPage({super.key});

  static const int _kMaxItems = 20;
  static const int _kPageSize = 10;

  @override
  State<SoccerReportListPage> createState() => _SoccerReportListPageState();
}

class _SoccerReportListPageState extends State<SoccerReportListPage> {
  static final _dateFmt = DateFormat('MM.dd', 'en_US');

  final List<SoccerReport> _reports = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<SoccerReport> get _pool =>
      ReportDummyData.soccerReports.take(SoccerReportListPage._kMaxItems).toList();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialReports();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final atEnd = pos.maxScrollExtent <= 0
        ? true
        : pos.pixels >= pos.maxScrollExtent * 0.8;
    if (atEnd && _hasMore && !_isLoadingMore) {
      _loadMoreReports();
    }
  }

  Future<void> _loadInitialReports() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final pool = _pool;
    final first = pool.take(SoccerReportListPage._kPageSize).toList();
    setState(() {
      _reports
        ..clear()
        ..addAll(first);
      _isLoading = false;
      _hasMore = _reports.length < SoccerReportListPage._kMaxItems &&
          _reports.length < pool.length;
    });
    // Short lists may not scroll; still try opportunistic pagination.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScroll();
    });
  }

  Future<void> _loadMoreReports() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final pool = _pool;
    final next = pool.skip(_reports.length).take(SoccerReportListPage._kPageSize).toList();
    if (next.isEmpty) {
      setState(() {
        _isLoadingMore = false;
        _hasMore = false;
      });
      return;
    }
    setState(() {
      _reports.addAll(next);
      _isLoadingMore = false;
      _hasMore = _reports.length < SoccerReportListPage._kMaxItems &&
          _reports.length < pool.length;
    });
    if (_hasMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onScroll();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width - 32;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: 'Match Reports',
          onBackPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary500,
              ),
            )
          : ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length + (_hasMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index < _reports.length) {
                  final report = _reports[index];
                  return ReportCard(
                    size: ReportCardSize.large,
                    width: cardWidth,
                    title: report.title,
                    date: _dateFmt.format(report.publishedAt),
                    description: report.author,
                    thumbnailUrl: report.thumbnailUrl,
                    onTap: () => context.push('/report/soccer/${report.id}'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: _isLoadingMore
                        ? const CircularProgressIndicator(
                            color: AppColors.primary500,
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),
    );
  }
}
