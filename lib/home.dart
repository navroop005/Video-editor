import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  void selectFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );
      if (result != null) {
        if (result.files.single.path != null) {
          String path = result.files.single.path.toString();
          debugPrint(path);
          if (context.mounted) {
            Navigator.pushNamed(context, '/editor',
                arguments: {'path': path, 'name': result.files.single.name});
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Editor"),
      ),
      body: InkWell(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/video.png',
                width: 200,
                color: Theme.of(context).primaryColorLight,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Tap to select video",
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
        onTap: () => selectFile(context),
      ),
    );
  }
}
