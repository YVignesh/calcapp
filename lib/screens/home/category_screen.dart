import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/tools.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryId;

  const CategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final cat = categories.firstWhere((c) => c.id == categoryId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                cat.name,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cat.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24, bottom: 24),
                    child: Icon(
                      cat.icon,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.separated(
              itemCount: cat.tools.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final tool = cat.tools[i];
                return _ToolCard(tool: tool, category: cat);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final ToolDef tool;
  final CategoryDef category;

  const _ToolCard({required this.tool, required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(tool.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: category.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tool.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.description,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: cs.onSurfaceVariant, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
