import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({ Key? key }) : super(key: key);
  
  void selectFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      );
    if (result != null) {
      if(result.files.single.path != null){
        String path = result.files.single.path.toString();
        debugPrint(path);
      Navigator.pushNamed(context, '/editor', arguments: { 'path': path, 'name': result.files.single.name});
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Editor"),
        backgroundColor: Colors.purple[900],
      ),
      backgroundColor: Colors.grey[900],
      body: RawMaterialButton(
        child: Expanded(
          child: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/video.png',
                  width: 200,
                ),
                const Text("Tap to select video",
                  style: TextStyle(fontSize: 30),
                ),
              ],
              mainAxisSize: MainAxisSize.min,
            )
            )
        ),
        onPressed: ()=>selectFile(context),
        ),
    );
  }
}