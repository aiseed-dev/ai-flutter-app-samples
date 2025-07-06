import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/gym.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Gym> _allGyms = [];
  List<Gym> _filteredGyms = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // 検索用の状態変数
  String? _selectedRegion;
  String? _selectedPrefecture;
  List<String> _regions = [];
  List<String> _prefectures = [];

  // 日本の地方の並び順を定義
  static const List<String> regionOrder = [
    '北海道', '東北', '関東', '中部', '近畿', '中国', '四国', '九州・沖縄'
  ];

  @override
  void initState() {
    super.initState();
    _loadGymData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGymData() async {
    final String response = await rootBundle.loadString('assets/gym_data_en.json');
    final List<dynamic> data = json.decode(response);
    final allGyms = data.map((json) => Gym.fromJson(json)).toList();

    // データから地方リストを生成し、定義した順序でソート
    final regions = allGyms.map((g) => g.region ?? '').toSet()
        .where((r) => r.isNotEmpty).toList();
    regions.sort((a, b) {
      int indexA = regionOrder.indexOf(a);
      int indexB = regionOrder.indexOf(b);
      if (indexA == -1) indexA = regionOrder.length; // 未定義の地方は末尾に
      if (indexB == -1) indexB = regionOrder.length;
      return indexA.compareTo(indexB);
    });

    setState(() {
      _allGyms = allGyms;
      _regions = regions;
      _isLoading = false;
      _applyFilters(); // 初期表示
    });
  }

  // すべてのフィルターを適用する
  void _applyFilters() {
    List<Gym> results = _allGyms;

    // 1. 地方で絞り込み
    if (_selectedRegion != null) {
      results = results.where((gym) => gym.region == _selectedRegion).toList();
    }

    // 2. 都道府県で絞り込み
    if (_selectedPrefecture != null) {
      results = results.where((gym) => gym.prefecture == _selectedPrefecture).toList();
    }

    // 3. テキストで絞り込み
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      results = results.where((gym) {
        return gym.name.toLowerCase().contains(query) ||
               (gym.prefecture?.toLowerCase() ?? '').contains(query) ||
               (gym.city?.toLowerCase() ?? '').contains(query) ||
               (gym.address?.toLowerCase() ?? '').contains(query);
      }).toList();
    }

    setState(() {
      _filteredGyms = results;
    });
  }

  // 地方が選択されたときの処理
  void _onRegionSelected(String? region) {
    setState(() {
      _selectedRegion = (_selectedRegion == region) ? null : region;
      _selectedPrefecture = null; // 地方が変わったら都道府県はリセット

      if (_selectedRegion != null) {
        // 選択された地方に属する都道府県リストを生成
        _prefectures = _allGyms
            .where((g) => g.region == _selectedRegion)
            .map((g) => g.prefecture ?? '')
            .toSet()
            .where((p) => p.isNotEmpty)
            .toList();
        _prefectures.sort(); // 都道府県は五十音順でソート
      } else {
        _prefectures = [];
      }
    });
    _applyFilters();
  }
  
  // 都道府県が選択されたときの処理
  void _onPrefectureSelected(String? prefecture) {
    setState(() {
      _selectedPrefecture = (_selectedPrefecture == prefecture) ? null : prefecture;
    });
    _applyFilters();
  }

  // 設備アイコン表示ウィジェット
  Widget _buildAmenityIcon(String? status, IconData icon) {
    if (status == '有') {
      return Icon(icon, color: Colors.green, size: 20);
    }
    // nullや'無'の場合は何も表示しない（リストをシンプルに保つため）
    return const SizedBox.shrink(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClimbFinder'),
      ),
      body: Column(
        children: [
          // フィルターセクション
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRegionChips(),
                if (_selectedRegion != null) _buildPrefectureChips(),
              ],
            ),
          ),
          
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'キーワードでさらに絞り込み',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          
          // ジム一覧
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGyms.isEmpty
                  ? const Center(child: Text('該当するジムが見つかりません。'))
                  : ListView.builder(
                      itemCount: _filteredGyms.length,
                      itemBuilder: (context, index) {
                        final gym = _filteredGyms[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(gym.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${gym.prefecture ?? ''} ${gym.city ?? ''}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAmenityIcon(gym.hasParking, Icons.local_parking),
                                const SizedBox(width: 4),
                                _buildAmenityIcon(gym.hasShop, Icons.store),
                                const SizedBox(width: 4),
                                _buildAmenityIcon(gym.hasShower, Icons.shower),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetailScreen(gym: gym)),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // 地方選択チップ
  Widget _buildRegionChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: _regions.map((region) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(region),
              selected: _selectedRegion == region,
              onSelected: (selected) => _onRegionSelected(region),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 都道府県選択チップ
  Widget _buildPrefectureChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: _prefectures.map((prefecture) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(prefecture),
              selected: _selectedPrefecture == prefecture,
              onSelected: (selected) => _onPrefectureSelected(prefecture),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }
}