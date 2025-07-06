import 'package:flutter/material.dart';
import '../models/gym.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final Gym gym;

  const DetailScreen({super.key, required this.gym});

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
  
  Future<void> _launchPhone(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
     if (!await launchUrl(phoneUri)) {
      debugPrint('Could not launch $phoneUri');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gym.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '基本情報'),
            Card(
              child: Column(
                children: [
                  _buildDetailTile(
                    context,
                    Icons.location_on, 
                    '住所', 
                    '${gym.prefecture ?? ''}${gym.city ?? ''}${gym.address ?? ''}'
                  ),
                  _buildDetailTile(context, Icons.directions_walk, 'アクセス', gym.access),
                  _buildDetailTile(
                    context, 
                    Icons.phone, 
                    '電話番号', 
                    gym.phoneNumber,
                    onTap: () => _launchPhone(gym.phoneNumber),
                  ),
                   _buildDetailTile(
                    context, 
                    Icons.language, 
                    'ウェブサイト', 
                    gym.website,
                    onTap: () => _launchURL(gym.website),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle(context, '壁情報'),
             Card(
              child: Column(
                children: [
                  _buildDetailTile(
                    context,
                    Icons.square_foot, 
                    '壁面積', 
                    gym.wallArea != null ? '${gym.wallArea} ㎡' : null,
                  ),
                  _buildDetailTile(
                    context,
                    Icons.height, 
                    '壁の高さ', 
                    gym.wallHeight != null ? '${gym.wallHeight} m' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(context, '設備・サービス'),
            Card(
              child: Column(
                children: [
                  _buildAmenityTile(context, '駐車場', gym.hasParking),
                  _buildAmenityTile(context, 'シャワー', gym.hasShower),
                  _buildAmenityTile(context, 'ショップ', gym.hasShop),
                  // ★★★ここからが元に戻した項目です★★★
                  _buildAmenityTile(context, 'リード壁', gym.hasLead),
                  _buildAmenityTile(context, 'トップロープ', gym.hasTopRope),
                  _buildAmenityTile(context, 'オートビレイ', gym.hasAutoBelay),
                  _buildAmenityTile(context, 'クラック', gym.hasCrack),
                  // ★★★ここまで★★★
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (gym.notes != null && gym.notes!.isNotEmpty) ...[
              _buildSectionTitle(context, '備考'),
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(gym.notes!, style: const TextStyle(fontSize: 16, height: 1.5)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
  
  Widget _buildDetailTile(BuildContext context, IconData icon, String title, String? value, {VoidCallback? onTap}) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: onTap != null ? Colors.blue[700] : null,
          decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAmenityTile(BuildContext context, String title, String? status) {
    Icon statusIcon;
    Color iconColor;
    String statusText;

    switch (status) {
      case '有':
        statusIcon = const Icon(Icons.check_circle_outline);
        iconColor = Colors.green;
        statusText = '有り';
        break;
      case '無':
        statusIcon = const Icon(Icons.highlight_off);
        iconColor = Colors.red;
        statusText = '無し';
        break;
      default:
        statusIcon = const Icon(Icons.help_outline);
        iconColor = Colors.grey;
        statusText = '不明';
    }

    return ListTile(
      leading: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(data: IconThemeData(color: iconColor), child: statusIcon),
          const SizedBox(width: 8),
          Text(statusText, style: TextStyle(color: iconColor, fontSize: 16)),
        ],
      ),
    );
  }
}