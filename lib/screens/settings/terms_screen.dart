import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('第1条（適用）'),
            _buildParagraph(
              'この利用規約（以下「本規約」）は、${AppConstants.appName}（以下「本アプリ」）の利用条件を定めるものです。'
              'ユーザーの皆様には、本規約に同意いただいた上で本アプリをご利用いただきます。',
            ),
            _buildSectionTitle('第2条（利用について）'),
            _buildParagraph(
              '本アプリは、六曜・吉日の表示、運勢占い、カレンダー機能を提供する無料アプリです。'
              '個人の私的利用を目的としてご利用ください。',
            ),
            _buildSectionTitle('第3条（禁止事項）'),
            _buildParagraph('ユーザーは以下の行為をしてはなりません。'),
            _buildBullet('本アプリの改変、リバースエンジニアリング'),
            _buildBullet('本アプリを利用した営利目的の活動（個人開発者の許可なく）'),
            _buildBullet('本アプリの運営を妨害する行為'),
            _buildBullet('その他、開発者が不適切と判断する行為'),
            _buildSectionTitle('第4条（占い・運勢について）'),
            _buildParagraph(
              '本アプリが提供する運勢占い・吉日情報は、あくまで参考情報であり、エンターテインメントとして提供されるものです。'
              '科学的根拠に基づくものではなく、結果について一切の保証をいたしません。'
              '重要な判断は、ご自身の責任において行ってください。',
            ),
            _buildSectionTitle('第5条（免責事項）'),
            _buildParagraph(
              '開発者は、本アプリの利用により生じたいかなる損害についても、一切の責任を負いません。'
              'また、本アプリの正確性、完全性、有用性について保証するものではありません。',
            ),
            _buildSectionTitle('第6条（広告の表示）'),
            _buildParagraph(
              '本アプリには、第三者の広告配信サービスによる広告が表示される場合があります。'
              '広告の表示に関する詳細は、プライバシーポリシーをご確認ください。',
            ),
            _buildSectionTitle('第7条（サービスの変更・停止）'),
            _buildParagraph(
              '開発者は、ユーザーへの事前通知なしに、本アプリの内容を変更または提供を停止することができるものとし、'
              'これによってユーザーに生じた損害について一切の責任を負いません。',
            ),
            _buildSectionTitle('第8条（利用規約の変更）'),
            _buildParagraph(
              '開発者は、必要と判断した場合には、ユーザーに通知することなく本規約を変更できるものとします。'
              '変更後の利用規約は、本アプリ内に掲示した時点から効力を生じるものとします。',
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '最終更新日: 2026年2月17日',
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
}
