import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'image_detail_page.dart';
import 'data_storage.dart';
import 'image_data.dart';
import 'settings_page.dart';
import 'about_page.dart';

class ImageGalleryPage extends StatefulWidget {
  const ImageGalleryPage({super.key});
  @override
  ImageGalleryPageState createState() => ImageGalleryPageState();
}

class ImageGalleryPageState extends State<ImageGalleryPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<ImageData> images = [];
  final TextEditingController openAIKeyController = TextEditingController();
  String imageFolder = '';
  bool permissionsGranted = false; // State variable to track permission status
  int _selectedIndex = 1;
  late AnimationController _controller;

  Map<String, dynamic> computeTotals() {
    int sumPromptTokens = 0;
    int sumCompletionTokens = 0;
    double sumCost = 0.0;

    for (var image in images) {
      for (var response in image.responses) {
        sumPromptTokens += response.promptTokens;
        sumCompletionTokens += response.completionTokens;
        sumCost += response.cost;
      }
    }

    return {
      'sumPromptTokens': sumPromptTokens,
      'sumCompletionTokens': sumCompletionTokens,
      'sumCost': sumCost, //.toStringAsFixed(2)
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkPermissionsAndLoadImages();
    checkOpenAIKey();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/');
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/score');
    }
  }

  void selectFolder() async {
    final dataStorage = DataStorage();
    await dataStorage.setSelectedFolderPath(imageFolder);
    loadImages(imageFolder);
  }

  void checkOpenAIKey() async {
    final dataStorage = DataStorage();

    bool apiKeyExists = await dataStorage.checkOpenAIKey();

    if (!apiKeyExists) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsPage(
                onAllImageDataDeleted: checkPermissionsAndLoadImages),
          ),
        );
      });
    }
  }

  /*

  void checkOpenAIKey() async {
    final dataStorage = DataStorage();
    String openAIKey = await dataStorage.getOpenAIKey();

    if (openAIKey.isEmpty) {

      Future.delayed(Duration.zero, () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsPage(onAllImageDataDeleted: checkPermissionsAndLoadImages),
          ),
        );
      });
    }
  }
 */

  void checkPermissionsAndLoadImages() async {
    var statusPhotos = await Permission.photos.status;

    if (!statusPhotos.isGranted) {
      var result = await Permission.photos.request();

      if (result.isDenied || result.isPermanentlyDenied) {
        setState(() {
          permissionsGranted = false;
        });
      }
    }

    if (await Permission.photos.isGranted) {
      setState(() {
        permissionsGranted = true; // Update state to reflect granted permission
      });

      final dataStorage = DataStorage();
      String imageFolder = await dataStorage.getSelectedFolderPath();
      if (imageFolder.isNotEmpty) {
        loadImages(imageFolder);
      } else {
        setState(() {
          images = [];
        });
      }
    }
  }

  bool isSupportedImageFile(String filePath) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
        .contains(path.extension(filePath).toLowerCase().replaceAll('.', ''));
  }

  void loadImages(String directoryPath) async {
    final dataStorage = DataStorage();
    List<ImageData> storedImages = await dataStorage.getImageInfo();

    List<ImageData> imagesWithResponses =
        storedImages.where((img) => img.hasResponse).toList();
    List<ImageData> unprocessedImages = [];

    imagesWithResponses.sort((a, b) => a.filePath.compareTo(b.filePath));

    final directory = Directory(directoryPath);

    Set<String> pathsWithResponses =
        imagesWithResponses.map((img) => img.filePath).toSet();

    await for (var entity in directory.list()) {
      if (entity is File && isSupportedImageFile(entity.path)) {
        if (!pathsWithResponses.contains(entity.path)) {
          unprocessedImages.add(ImageData(filePath: entity.path));
        }
      }
    }

    List<ImageData> finalImages = imagesWithResponses + unprocessedImages;

    setState(() {
      images = finalImages;
    });
  }

  Widget _buildBody() {
    if (!permissionsGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  'You cannot use the app without granting permissions to access photos.'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Semantics(
                label: 'Request Permissions',
                button: true,
                child: ElevatedButton(
                  onPressed: checkPermissionsAndLoadImages,
                  child: const Text('Allow Permissions'),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (images.isEmpty) {
      return FutureBuilder<String>(
        future: DataStorage().getSelectedFolderPath(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'This folder has no images. You must select a folder that contains images.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Semantics(
                      label: 'Select Folder',
                      button: true,
                      child: ElevatedButton(
                        onPressed: selectFolder,
                        child: const Text('Select Folder'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No folder selected. Please select a folder that contains images.',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Semantics(
                      label: 'Select Folder',
                      button: true,
                      child: ElevatedButton(
                        onPressed: selectFolder,
                        child: const Text('Select Folder'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          ImageData currentImage = images[index];
          bool hasDescription = currentImage.hasResponse;

          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDetailPage(
                    selectedImage: currentImage,
                    onImageDetailUpdate: checkPermissionsAndLoadImages,
                  ),
                ),
              );
              checkPermissionsAndLoadImages();
            },
            child: Semantics(
              label: hasDescription
                  ? 'Image with one or more responses'
                  : 'Image without any responses',
              hint: 'Tap to open image detail page',
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hasDescription ? Colors.blue : Colors.grey,
                    width: 3,
                  ),
                ),
                child: File(currentImage.filePath).existsSync()
                    ? Image.file(
                        File(currentImage.filePath),
                        semanticLabel:
                            'Image file and folder: ${currentImage.filePath}',
                      )
                    : const Center(
                        child: Text(
                          'Image no longer available',
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = computeTotals();
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(const Color(0xFF232526), const Color(0xFF7F53AC),
                        _controller.value)!,
                    Color.lerp(const Color(0xFF7F53AC), const Color(0xFF647DEE),
                        _controller.value)!,
                  ],
                ),
              ),
            );
          },
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          drawer: Drawer(
            child: Semantics(
              label: 'Navigation Menu',
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Caveat',
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings',
                        style: TextStyle(fontFamily: 'Caveat')),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            SettingsPage(onAllImageDataDeleted: () {
                          checkPermissionsAndLoadImages();
                        }),
                      ));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About',
                        style: TextStyle(fontFamily: 'Caveat')),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Semantics(
                      label: 'Total tokens and cost',
                      child: Text(
                        'Totals: Cost: 24${totals['sumCost'].toStringAsFixed(2)}\nInput Tokens: ${totals['sumPromptTokens']} Output Tokens: ${totals['sumCompletionTokens']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Caveat',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Semantics(
                      label: 'Select Folder',
                      hint: 'Tap to select a folder',
                      child: IconButton(
                        icon:
                            const Icon(Icons.folder_open, color: Colors.white),
                        onPressed: selectFolder,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  child: _buildBody(),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
