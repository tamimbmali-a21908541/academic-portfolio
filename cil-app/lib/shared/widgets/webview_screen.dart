import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';

/// WebView Screen - Displays website pages in-app
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final bool showAppBar;
  final bool enableShare;
  final bool enableExternalBrowser;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title = '',
    this.showAppBar = true,
    this.enableShare = true,
    this.enableExternalBrowser = true,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String _currentUrl = '';
  String _pageTitle = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _pageTitle = widget.title;
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _updateTitle();
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? false) {
              _showError(error.description);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle external links
            if (!_isCilUrl(request.url) && !request.url.startsWith('https://www.comunidadeislamica.pt')) {
              _openExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isCilUrl(String url) {
    return url.contains('comunidadeislamica.pt') ||
        url.contains('wixstatic.com') ||
        url.contains('wix.com');
  }

  Future<void> _updateTitle() async {
    try {
      final title = await _controller.getTitle();
      if (title != null && title.isNotEmpty && mounted) {
        setState(() {
          _pageTitle = title.replaceAll(' | Comunidade Islâmica de Lisboa', '').trim();
        });
      }
    } catch (e) {
      // Ignore title fetch errors
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar: $message'),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _controller.reload(),
          ),
        ),
      );
    }
  }

  Future<void> _shareUrl() async {
    await Share.share(
      _currentUrl,
      subject: _pageTitle.isNotEmpty ? _pageTitle : 'CIL - Comunidade Islâmica de Lisboa',
    );
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_currentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                _pageTitle.isNotEmpty ? _pageTitle : widget.title,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (widget.enableShare)
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _shareUrl,
                    tooltip: 'Partilhar',
                  ),
                if (widget.enableExternalBrowser)
                  IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: _openInBrowser,
                    tooltip: 'Abrir no navegador',
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'reload':
                        _controller.reload();
                        break;
                      case 'home':
                        _controller.loadRequest(Uri.parse('https://www.comunidadeislamica.pt'));
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'reload',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Recarregar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'home',
                      child: Row(
                        children: [
                          Icon(Icons.home),
                          SizedBox(width: 8),
                          Text('Página inicial'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: _isLoading
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(2),
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
            )
          : null,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading && _loadingProgress < 0.9)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _loadingProgress > 0 ? _loadingProgress : null,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A carregar...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// WebView Page - A standalone page wrapper for WebView
class WebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return WebViewScreen(
      url: url,
      title: title,
    );
  }
}
