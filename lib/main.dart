// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:js/js.dart';
import 'dart:ui_web' as ui;

import 'package:webelements/context_util.dart';

@JS()
external void _exitFullScreen();
@JS()
external void _enterFullScreen();

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Web based element to rebedr the image on the scaffold
  html.ImageElement? _imageElement;
  final String viewId = 'image-container';

  // textEditng controller to get the image link.
  late TextEditingController controller;

  // simple boolean helper variable to check before doing certain task.
  var isInFullScreen = false;

  // Animations to control whether the background should be dim or not?
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Widget _modalbarrier;
  bool shouldDimScaffold = false;

  @override
  void initState() {
    super.initState();

    // Initializing the animationController & animation.
    ColorTween colorTween = ColorTween(
      begin: Colors.transparent,
      end: Colors.black.withOpacity(0.35),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _colorAnimation = colorTween.animate(
      _animationController,
    );
    _modalbarrier = AnimatedModalBarrier(
      color: _colorAnimation,
    );

    controller = TextEditingController();

    // registering the HTML element which is div inorder to placethe image inside of it.
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (_) => html.DivElement()..id = viewId,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void loadImage() {
    var container = html.document.getElementById(viewId);
    if (container != null) {
      container.children.clear();
      _imageElement = html.ImageElement()
        ..src = controller.text
        ..alt = 'failed to load image'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.minWidth = '100%'
        ..style.minHeight = '100%'
        ..onDoubleClick.listen((_) {
          if (isInFullScreen) {
            _exitFullScreen();
          } else {
            _enterFullScreen();
          }
          isInFullScreen = !isInFullScreen;
        });
      container.append(_imageElement as html.Node);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: Center(
                        child: HtmlElementView(
                          viewType: viewId,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration:
                            const InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: loadImage,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          floatingActionButton: PopupMenuButton(
            color: Colors.white,
            onOpened: () {
              setState(() {
                shouldDimScaffold = true;
              });
              _animationController.reset();
              _animationController.forward();
            },
            onCanceled: () {
              setState(() {
                shouldDimScaffold = false;
              });
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    if (isInFullScreen) {
                      context.showToast("You're are already in full screen!");
                      return;
                    }
                    _enterFullScreen();
                    isInFullScreen = true;
                  },
                  child: const Text('Enter Fullscreen'),
                ),
                PopupMenuItem(
                  onTap: () {
                    if (!isInFullScreen) {
                      context.showToast("You're not in full screen to exit!");
                      return;
                    }
                    _exitFullScreen();
                    isInFullScreen = false;
                  },
                  child: const Text('Exit Fullscreen'),
                ),
              ];
            },
            popUpAnimationStyle: AnimationStyle(
              reverseCurve: Curves.easeInOut,
              reverseDuration: const Duration(
                milliseconds: 100,
              ),
            ),
            offset: const Offset(0, -112.0),
            child: const FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
          ),
        ),
        if (shouldDimScaffold) _modalbarrier,
      ],
    );
  }
}
