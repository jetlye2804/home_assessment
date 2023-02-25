import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_assessment/models/now_playing_model.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  static var routeName = '/home';
  final NowPlayingModel? nowPlayingModel;

  const Home({super.key, this.nowPlayingModel});

  @override
  State<Home> createState() => _HomeState();
}

Future<http.Response> fetchAlbum() {
  return http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
}

class _HomeState extends State<Home> {
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
  }

  refreshNowShowingMovie(String step) {
    print(step);
    var count = currentPage;
    if (step == 'next') {
      count += 1;
    } else if (step == "back") {
      if (currentPage > 1) {
        count -= 1;
      } else {
        count = 1;
      }
    }

    print(count);

    setState(() {
      currentPage = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    var nowPlaying = widget.nowPlayingModel;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text("Jet's Movie App"),
        ),
        body: SafeArea(
            minimum: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Text(
                          "Now Showing",
                          style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          )),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: currentPage > 1
                                  ? () {
                                      refreshNowShowingMovie('back');
                                    }
                                  : null,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        currentPage > 1
                                            ? Colors.deepPurple
                                            : Colors.grey),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        currentPage > 1
                                            ? Colors.white
                                            : Colors.black),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            Text("$currentPage"),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.deepPurple),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                              onPressed: () {
                                refreshNowShowingMovie('next');
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                      )),
                    ],
                  ),
                  Expanded(
                      child: GridView.builder(
                    itemCount: nowPlaying!.results!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1 / 2.5,
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0),
                    itemBuilder: (BuildContext context, int index) {
                      var movieItem = nowPlaying.results![index];

                      var adultTag = Container(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 0, 168, 31)),
                          child: const Text("Safe"));
                      if (movieItem.adult! == true) {
                        adultTag = Container(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 168, 0, 0)),
                            child: const Text("Adult"));
                      }

                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 52, 52, 52)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            movieItem.posterPath != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                    child: Image.network(
                                      "https://www.themoviedb.org/t/p/w440_and_h660_face/${movieItem.posterPath}",
                                      fit: BoxFit.cover,
                                      height: 300,
                                      width: 200,
                                    ),
                                  )
                                : Container(),
                            Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: Text(movieItem.originalTitle!,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400)),
                                    ),
                                    Text(movieItem.releaseDate!),
                                    adultTag
                                  ],
                                ))
                          ],
                        ),
                      );
                    },
                  )),
                ])));
  }
}
