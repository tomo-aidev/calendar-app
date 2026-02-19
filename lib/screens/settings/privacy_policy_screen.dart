import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              '${AppConstants.appName}（以下「本アプリ」）における個人情報の取り扱いについて、'
              '以下のとおりプライバシーポリシーを定めます。',
            ),
            _buildSectionTitle('1. 収集する情報'),
            _buildParagraph(
              '本アプリでは、以下の情報をお使いの端末内にのみ保存します。'
              'これらの情報が外部サーバーに送信されることはありません。',
            ),
            _buildBullet('ニックネーム、生年月日、血液型、星座（運勢表示のため）'),
            _buildBullet('カレンダーの予定・記念日データ'),
            _buildBullet('アプリの設定情報（通知時刻、表示設定等）'),
            _buildSectionTitle('2. Googleカレンダー連携について'),
            _buildParagraph(
              '本アプリでは、吉日情報をGoogleカレンダーに追加する機能を提供しています。'
              'この機能はブラウザ経由でGoogleカレンダーのWebサイトを開くものであり、'
              '端末内のカレンダーデータにはアクセスしません。',
            ),
            _buildSectionTitle('3. 広告配信について'),
            _buildParagraph(
              '本アプリでは、広告配信のために第三者の広告配信サービス（Google AdMob等）を利用する場合があります。'
              'これらのサービスでは、広告の最適化のために以下の情報が収集される場合があります。',
            ),
            _buildBullet('端末の識別情報（広告ID）'),
            _buildBullet('アプリの利用状況'),
            _buildBullet('おおよその位置情報'),
            _buildParagraph(
              '広告配信サービスによる情報収集の詳細については、各サービスのプライバシーポリシーをご確認ください。',
            ),
            _buildLink('Google プライバシーポリシー', 'https://policies.google.com/privacy'),
            _buildSectionTitle('4. 通知機能について'),
            _buildParagraph(
              '本アプリでは、毎日の吉日メッセージを通知でお届けする機能があります。'
              '通知の送受信はすべて端末内で処理され、外部サーバーは利用しません。'
              '通知は設定画面からいつでもオフにできます。',
            ),
            _buildSectionTitle('5. データの保管と削除'),
            _buildParagraph(
              'すべてのデータはお使いの端末内にのみ保存されます。'
              'アプリを削除することで、すべてのデータが端末から完全に削除されます。',
            ),
            _buildSectionTitle('6. お子様のプライバシー'),
            _buildParagraph(
              '本アプリは、13歳未満のお子様の個人情報を意図的に収集することはありません。',
            ),
            _buildSectionTitle('7. プライバシーポリシーの変更'),
            _buildParagraph(
              '本ポリシーは、必要に応じて変更されることがあります。'
              '変更があった場合は、アプリ内で通知いたします。',
            ),
            _buildSectionTitle('8. お問い合わせ'),
            _buildParagraph(
              '本ポリシーに関するお問い合わせは、アプリストアのレビューまたは開発者連絡先までお願いいたします。',
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '最終更新日: 2026年2月18日',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('・', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(String text, String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        '$text: $url',
        style: const TextStyle(fontSize: 13, color: Colors.blue, height: 1.6),
      ),
    );
  }
}
