import 'package:analyzer/error/listener.dart' show ErrorReporter;
import 'package:analyzer/error/error.dart' as analyzer_error show ErrorSeverity;
import 'package:analyzer/dart/ast/ast.dart' show SimpleIdentifier;
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _AppLints();

class _AppLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [NoDirectIconsRule()];
}

class NoDirectIconsRule extends DartLintRule {
  NoDirectIconsRule()
      : super(
          code: LintCode(
            name: 'no_direct_icons',
            problemMessage: 'Use AppIcons instead of Icons.*',
            correctionMessage: 'Import package:musice/icons/app_icons.dart and use AppIcons.<icon>.',
            errorSeverity: analyzer_error.ErrorSeverity.ERROR,
          ),
        );

  bool _isInLib(CustomLintResolver resolver) {
    final path = resolver.path.replaceAll('\\', '/');
    return path.contains('/lib/');
  }

  bool _isAppIconsFile(CustomLintResolver resolver) {
    final path = resolver.path.replaceAll('\\', '/');
    return path.endsWith('/lib/icons/app_icons.dart');
  }

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    if (!_isInLib(resolver) || _isAppIconsFile(resolver)) return;

    context.registry.addPrefixedIdentifier((node) {
      final prefix = node.prefix;
      if (prefix.name == 'Icons') {
        reporter.atNode(node, code);
      }
    });

    context.registry.addPropertyAccess((node) {
      final target = node.target;
      if (target is SimpleIdentifier && target.name == 'Icons') {
        reporter.atNode(node, code);
      }
    });
  }
}
