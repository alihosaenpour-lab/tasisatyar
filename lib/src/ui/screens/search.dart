import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/repository.dart';
import '../shell.dart';
import '../widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<SearchHit> _results = const [];
  bool _loading = false;
  Timer? _debounce;

  static const _order = ['error', 'problem', 'component', 'device', 'brand'];
  static const _labels = {
    'error': 'خطاها', 'problem': 'مشکلات', 'component': 'قطعات',
    'device': 'مدل‌ها', 'brand': 'برندها',
  };
  static const _icons = {
    'error': Icons.error_outline_rounded,
    'problem': Icons.build_circle_outlined,
    'component': Icons.precision_manufacturing_outlined,
    'device': Icons.devices_other_rounded,
    'brand': Icons.factory_outlined,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () => _run(q));
  }

  Future<void> _run(String q) async {
    if (q.trim().length < 2) {
      setState(() { _results = const []; _loading = false; });
      return;
    }
    setState(() => _loading = true);
    final r = await CatalogRepository.instance.search(q);
    if (mounted && _ctrl.text == q) setState(() { _results = r; _loading = false; });
  }

  void _open(SearchHit h) {
    final route = switch (h.type) {
      'error' => '/error', 'problem' => '/problem', 'component' => '/component',
      'device' => '/device', 'brand' => '/devices', _ => null,
    };
    if (route != null) Navigator.pushNamed(context, route, arguments: h.id);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<SearchHit>>{};
    for (final h in _results) {
      (grouped[h.type] ??= []).add(h);
    }
    final hasQuery = _ctrl.text.trim().length >= 2;

    return TyTabScaffold(
      tab: 1,
      appBar: AppBar(
        titleSpacing: 8,
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'مثلاً: E01 یا «فشار کم» یا «ممبران»...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13.5),
            border: InputBorder.none, enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none, filled: false,
            suffixIcon: _ctrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () { _ctrl.clear(); _onChanged(''); setState(() {}); },
                  ),
          ),
        ),
      ),
      body: !hasQuery
          ? const EmptyState(
              icon: Icons.manage_search_rounded,
              title: 'جستجو در کل بانک اطلاعاتی',
              message: 'کد خطا، نام خطا، برند، مدل، مشکل، قطعه یا راهکار را بنویسید؛ نتایج به‌صورت زنده نمایش داده می‌شود.')
          : _loading && _results.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'نتیجه‌ای پیدا نشد.',
                      message: '«${_ctrl.text.trim()}» در بانک اطلاعاتی یافت نشد. املای دیگری را امتحان کنید یا از دسته‌بندی‌ها وارد شوید.')
                  : ListView(
                      padding: const EdgeInsets.all(14),
                      children: [
                        for (final type in _order)
                          if (grouped[type] != null) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                              child: Row(children: [
                                Icon(_icons[type], size: 18, color: TyColors.teal),
                                const SizedBox(width: 6),
                                Text(_labels[type]!,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(width: 6),
                                Text('(${grouped[type]!.length})',
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                              ]),
                            ),
                            for (final h in grouped[type]!)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TyListItem(
                                  title: h.title,
                                  subtitle: h.sub,
                                  onTap: () => _open(h),
                                ),
                              ),
                          ],
                        const SizedBox(height: 24),
                      ],
                    ),
    );
  }
}
