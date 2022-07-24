import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  void selectFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );
      if (result != null) {
        if (result.files.single.path != null) {
          String path = result.files.single.path.toString();
          debugPrint(path);
          Navigator.pushNamed(context, '/editor',
              arguments: {'path': path, 'name': result.files.single.name});
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
      body: RawMaterialButton(
        child: Expanded(
            child: Center(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/video.png',
              width: 200,
              color: Colors.white,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Tap to select video",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ))),
        onPressed: () => selectFile(context),
      ),
    );
  }
}
