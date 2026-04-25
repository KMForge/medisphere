import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HealthEducationScreen extends StatelessWidget {
  static const String routeName = '/health-education';

  const HealthEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = [
      (
        'Dengue Prevention',
        'Keep your surroundings clean, remove stagnant water, and use mosquito protection to prevent dengue.',
      ),
      (
        'Proper Nutrition',
        'Balance fruits, vegetables, proteins, and whole grains. Hydrate well and limit sugary drinks.',
      ),
      (
        'COVID Guidelines',
        'Stay updated on vaccines, wear masks in crowded spaces, and isolate when feeling unwell.',
      ),
      (
        'Maternal Care',
        'Attend prenatal checkups, take prenatal vitamins, and monitor warning signs closely.',
      ),
      (
        'Child Immunization',
        'Follow the national immunization schedule to keep children protected from preventable diseases.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Health Education')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.$1,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _ArticleDetailPage(
                                  title: article.$1,
                                  body: article.$2,
                                ),
                              ),
                            );
                          },
                          child: const Text('Read more'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ArticleDetailPage extends StatelessWidget {
  final String title;
  final String body;

  const _ArticleDetailPage({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ),
    );
  }
}
