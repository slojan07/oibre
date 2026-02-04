import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? controller;
  bool isLoading = true;
  bool hasError = false;
  bool canGoBack = false;
  bool isFirstLoad = true;
  bool isSidebarVisible = false;

  @override
  void initState() {
    super.initState();
    bool isTest = false;
    if (!kIsWeb) {
      try {
        isTest = Platform.environment.containsKey('FLUTTER_TEST');
      } catch (_) {}
    }
    if (!kIsWeb && !isTest) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel('MenuHandler',
          onMessageReceived: (JavaScriptMessage message) {
            // Reset sidebar visibility when menu item is clicked
            setState(() {
              isSidebarVisible = false;
            });
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
                hasError = false;
              });
            },
            onPageFinished: (String url) {
              // Update navigation state immediately
              _updateNavigationState();
              // Hide the sidebar only if it should be hidden (when not explicitly toggled on)
              if (!isSidebarVisible) {
                _hideSidebarWithCSS();
              }
              // Setup menu item click listeners
              _setupMenuItemListeners();
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                hasError = true;
                isLoading = false;
              });
            },
          ),
        )
        ..enableZoom(false)
        ..setBackgroundColor(Colors.white)
        ..loadRequest(Uri.parse(AppConstants.hrmUrl));
    }
  }

  Future<void> _refresh() async {
    if (controller != null) {
      await controller!.reload();
    }
  }

  Future<void> _hideSidebarWithCSS() async {
    if (controller == null) return;
    
    try {
      // Inject CSS to hide sidebar, overlays, and enable full view
      await controller!.runJavaScript('''
        const style = document.createElement('style');
        style.id = 'sidebar-toggle-style';
        style.textContent = `
          aside { display: none !important; }
          body { margin: 0 !important; padding: 0 !important; overflow: visible !important; }
          main { width: 100% !important; margin: 0 !important; }
          [role="main"] { width: 100% !important; margin: 0 !important; }
          .flex { width: 100% !important; }
          div[class*="backdrop"] { display: none !important; }
          div[class*="overlay"] { display: none !important; }
          div[style*="position: fixed"] { pointer-events: none !important; }
          * { pointer-events: auto !important; }
          main * { pointer-events: auto !important; }
        `;
        document.head.appendChild(style);
      ''');
    } catch (e) {
      print('Error hiding sidebar: \$e');
    }
  }

  Future<void> _setupMenuItemListeners() async {
    if (controller == null) return;
    
    try {
      // Setup comprehensive click handler that hides sidebar immediately on any menu interaction
      await controller!.runJavaScript('''
        function hideMenuAndOverlay() {
          // Immediately hide all sidebar and overlay elements
          const style = document.createElement('style');
          style.id = 'menu-hide-style-' + Date.now();
          style.textContent = `
            aside, 
            nav[class*="sidebar"], 
            div[class*="sidebar"], 
            [class*="drawer"],
            [class*="menu"] { 
              display: none !important; 
              visibility: hidden !important; 
              opacity: 0 !important;
              pointer-events: none !important;
            }
            div[class*="backdrop"] { 
              display: none !important; 
              visibility: hidden !important; 
              opacity: 0 !important;
            }
            div[class*="overlay"] { 
              display: none !important; 
              visibility: hidden !important; 
              opacity: 0 !important;
            }
            div[role="dialog"] { 
              display: none !important; 
              visibility: hidden !important; 
              opacity: 0 !important;
            }
            body { overflow: visible !important; }
            main { width: 100% !important; }
          `;
          document.head.appendChild(style);
          console.log('Sidebar and overlays hidden');
        }
        
        // Listen for any clicks in the sidebar/menu area
        document.addEventListener('click', function(e) {
          const clickedElement = e.target;
          
          // Check if this is a dropdown/expand button (has arrow icons or expand-specific classes)
          const isDropdownButton = clickedElement.closest(
            'button[aria-expanded], [class*="expand"], [class*="collapse"], svg, i.icon-chevron, i.icon-arrow, [class*="toggle"]'
          ) || 
          clickedElement.textContent?.includes('>') ||
          clickedElement.textContent?.includes('v') ||
          clickedElement.textContent?.includes('∨') ||
          clickedElement.innerHTML?.includes('svg');
          
          // If it's a dropdown button, don't hide the menu (let it expand/collapse)
          if (isDropdownButton) {
            console.log('Dropdown button clicked - menu will expand/collapse');
            return;
          }
          
          // Check if click is inside a menu structure (links, buttons, list items, divs with menu roles)
          const isMenuClick = e.target.closest(
            'a[href], li, [role="menuitem"], [class*="menu-item"], [class*="item"]'
          );
          
          if (isMenuClick) {
            // Check if this element or its parent is within the sidebar
            const sidebar = e.target.closest('aside, nav[class*="sidebar"], div[class*="sidebar"], [class*="drawer"]');
            if (sidebar) {
              // Add a small delay to allow menu navigation to process
              setTimeout(() => {
                hideMenuAndOverlay();
                // Notify Flutter that menu was clicked
                MenuHandler.postMessage('menu_clicked');
              }, 100);
            }
          }
        }, true);
        
        // Also watch for navigation changes
        const observer = new MutationObserver(function(mutations) {
          // If page structure is changing significantly, ensure menu is hidden
          if (document.querySelector('aside:not([style*="display: none"])')) {
            // Menu is still visible, might need to hide it
            const urlChanged = window.lastUrl !== window.location.href;
            if (urlChanged) {
              hideMenuAndOverlay();
              window.lastUrl = window.location.href;
            }
          }
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true,
          attributes: false,
          characterData: false
        });
        
        window.lastUrl = window.location.href;
      ''').catchError((error) {
        print('Error setting up menu listeners: \$error');
      });
    } catch (e) {
      print('Error in _setupMenuItemListeners: \$e');
    }
  }

  void _updateNavigationState() {
    if (controller != null) {
      controller!.canGoBack().then((canGoBackValue) {
        if (mounted) {
          setState(() {
            isLoading = false;
            canGoBack = canGoBackValue;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          canGoBack = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppConstants.appBarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppConstants.primaryColor,
            boxShadow: [AppConstants.defaultShadow],
          ),
          child: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallSpacing),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    size: AppConstants.iconSize,
                  ),
                ),
                const SizedBox(width: AppConstants.mediumSpacing),
                const Text(AppConstants.appName),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: controller != null
                ? Container(
                    margin: const EdgeInsets.all(AppConstants.smallSpacing),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, size: AppConstants.smallIconSize),
                      tooltip: 'Menu',
                      onPressed: () {
                        // Toggle visibility flag and reset first load flag to prevent CSS hiding
                        setState(() {
                          isSidebarVisible = !isSidebarVisible;
                          isFirstLoad = false; // Prevent CSS hiding on reload
                        });
                        // Reload the page
                        _refresh();
                      },
                    ),
                  )
                : null,
          ),
        ),
      ),
      body: controller != null
          ? Stack(
              children: [
                WebViewWidget(controller: controller!),
                if (isLoading)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppConstants.largeSpacing),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppConstants.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.largeSpacing),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Loading HRM System...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (hasError)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.red.shade50],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppConstants.largeSpacing),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red.shade400, Colors.red.shade600],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.shade200,
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.wifi_off,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppConstants.largeSpacing),
                            Container(
                              padding: const EdgeInsets.all(AppConstants.defaultPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Connection Failed',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.smallSpacing),
                                  Text(
                                    'Unable to load the HRM system. Please check your internet connection.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppConstants.defaultPadding),
                                  ElevatedButton.icon(
                                    onPressed: _refresh,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try Again'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConstants.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppConstants.largeSpacing,
                                        vertical: AppConstants.mediumSpacing,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Container(
                margin: const EdgeInsets.all(AppConstants.largeSpacing),
                padding: const EdgeInsets.all(AppConstants.largeSpacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.web,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'WebView Not Available',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                    Text(
                      kIsWeb
                          ? 'WebView is not supported on web platform. Please use a mobile device.'
                          : 'WebView cannot be loaded in test mode.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}