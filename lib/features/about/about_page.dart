import 'package:material_ui/material_ui.dart';
import 'package:runout/core/constants/app_constants.dart';
import 'package:runout/core/constants/layout_breakpoints.dart';
import 'package:runout/core/theme/theme_extension.dart';
import 'package:runout/shared/widgets/app_logo.dart';

const String _privacyPolicy =
    'Runout stores matches, players, and settings only on this device. '
    'There is no account, analytics, tracking, or backend, and your data is '
    'not sent anywhere. Clearing site data or uninstalling the app removes '
    'your data. There is no sync or backup yet.';

/// App information, licenses, privacy, and credits.
class AboutPage extends StatelessWidget {
  const new({super.key});

  void _openLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const AppLogo(size: 64),
      applicationLegalese: AppConstants.legalese,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = size.width < LayoutBreakpoints.compact ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LayoutBreakpoints.compact,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [
                  const _AboutHeader(),
                  _InfoCard(onLicenses: () => _openLicenses(context)),
                  const _PrivacyCard(),
                  const _PortfolioCard(),
                  Text(
                    AppConstants.legalese,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AboutHeader extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      spacing: 8,
      children: [
        const AppLogo(size: 96),
        Text(
          AppConstants.appTitle,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
        Text(
          AppConstants.appSubtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.titleMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.appDescription,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const new({required this.onLicenses});

  final VoidCallback onLicenses;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.surfaceContainerLowest,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.tag_rounded),
            title: Text('Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licenses'),
            subtitle: const Text('Open-source licenses used by Runout'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onLicenses,
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                Expanded(
                  child: Text(
                    'Data & privacy',
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            Text(
              _privacyPolicy,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      color: colors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                Expanded(
                  child: Text(
                    'Made by abidkyo',
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            SelectableText(
              AppConstants.portfolioSite,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
