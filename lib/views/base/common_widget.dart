import 'package:flutter/material.dart';

class CommonWidget {
  Widget posterContainerWidget(posterPath) {
    return Image.network(
      "https://www.themoviedb.org/t/p/w440_and_h660_face/$posterPath",
      fit: BoxFit.cover,
      height: 300,
      width: 200,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return noPosterWidget();
      },
    );
  }

  Widget noPosterWidget() {
    return Container(
      color: Colors.blueGrey,
      height: 300,
      width: 200,
      child: const Center(
        child: Text("Image Not Found"),
      ),
    );
  }
}
