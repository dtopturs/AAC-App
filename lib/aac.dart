import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

// One picture and its word
class AACButton {
  final String image;
  final String word;

  const AACButton(this.image, this.word);
}

// All our AAC pictures
final Map<String, AACButton> aacButtons = {
  "00": AACButton("assets/images/yes.png", "yes"),
  "01": AACButton("assets/images/who.png", "who"),
  "02": AACButton("assets/images/all.png", "all"),
  "03": AACButton("assets/images/dont.png", "don't"),
  "04": AACButton("assets/images/help.png", "help"),
  "05": AACButton("assets/images/turn.png", "turn"),
  "06": AACButton("assets/images/open.png", "open"),
  "07": AACButton("assets/images/a.png", "a"),
  "08": AACButton("assets/images/here.png", "here"),
  "09": AACButton("assets/images/different.png", "different"),
  "10": AACButton("assets/images/all_done.png", "all done"),
  "11": AACButton("assets/images/what.png", "what"),
  "12": AACButton("assets/images/you.png", "you"),
  "13": AACButton("assets/images/do.png", "do"),
  "14": AACButton("assets/images/put.png", "put"),
  "15": AACButton("assets/images/get.png", "get"),
  "16": AACButton("assets/images/make.png", "make"),
  "17": AACButton("assets/images/the.png", "the"),
  "18": AACButton("assets/images/there.png", "there"),
  "19": AACButton("assets/images/some.png", "some"),
  "20": AACButton("assets/images/something_else.png", "something else"),
  "21": AACButton("assets/images/when.png", "when"),
  "22": AACButton("assets/images/it.png", "it"),
  "23": AACButton("assets/images/is.png", "is"),
  "24": AACButton("assets/images/stop.png", "stop"),
  "25": AACButton("assets/images/go.png", "go"),
  "26": AACButton("assets/images/come.png", "come"),
  "27": AACButton("assets/images/to.png", "to"),
  "28": AACButton("assets/images/out.png", "out"),
  "29": AACButton("assets/images/not.png", "not"),
  "30": AACButton("assets/images/somethings_wrong.png", "something's wrong"),
  "31": AACButton("assets/images/where.png", "where"),
  "32": AACButton("assets/images/that.png", "that"),
  "33": AACButton("assets/images/can.png", "can"),
  "34": AACButton("assets/images/want.png", "want"),
  "35": AACButton("assets/images/drink.png", "drink"),
  "36": AACButton("assets/images/eat.png", "eat"),
  "37": AACButton("assets/images/at.png", "at"),
  "38": AACButton("assets/images/in.png", "in"),
  "39": AACButton("assets/images/more.png", "more"),
  "40": AACButton("assets/images/lets.png", "let's"),
  "41": AACButton("assets/images/why.png", "why"),
  "42": AACButton("assets/images/he.png", "he"),
  "43": AACButton("assets/images/will.png", "will"),
  "44": AACButton("assets/images/look.png", "look"),
  "45": AACButton("assets/images/say.png", "say"),
  "46": AACButton("assets/images/play.png", "play"),
  "47": AACButton("assets/images/and.png", "and"),
  "48": AACButton("assets/images/on.png", "on"),
  "49": AACButton("assets/images/same.png", "same"),
  "50": AACButton("assets/images/no.png", "no"),
  "51": AACButton("assets/images/how.png", "how"),
  "52": AACButton("assets/images/she.png", "she"),
  "53": AACButton("assets/images/shall.png", "shall"),
  "54": AACButton("assets/images/like.png", "like"),
  "55": AACButton("assets/images/feel.png", "feel"),
  "56": AACButton("assets/images/now.png", "now"),
  "57": AACButton("assets/images/for.png", "for"),
  "58": AACButton("assets/images/off.png", "off"),
  "59": AACButton("assets/images/on.png", "on"),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My AAC App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),
      home: const AACHomePage(),
    );
  }
}

class AACHomePage extends StatefulWidget {
  const AACHomePage({super.key});

  @override
  State<AACHomePage> createState() => _AACHomePageState();
}

class _AACHomePageState extends State<AACHomePage> {
  final List<AACButton> selectedButtons = [];

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.3);
    flutterTts.setPitch(1.0);
  }

  void addButton(AACButton button) {
    setState(() {
      selectedButtons.add(button);
    });
  }

  // Clear the message box
  void clearMessage() {
    setState(() {
      selectedButtons.clear();
    });

    flutterTts.stop();
  }

  // Speak all the selected words
  Future<void> speakMessage() async {
    if (selectedButtons.isEmpty) return;

    final message = selectedButtons.map((button) => button.word).join(" ");

    await flutterTts.stop();
    await flutterTts.speak(message);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My AAC Board', style: TextStyle(fontSize: 18)),
        toolbarHeight: 36,
        backgroundColor: Colors.pink.shade100,
      ),

      body: Column(
        children: [
          // TOP COMMUNICATION BAR
          Container(
            height: 78,
            padding: const EdgeInsets.all(5),
            color: Colors.pink.shade100,
            child: Row(
              children: [
                // Rectangle containing selected pictures
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.pink.shade300, width: 2),
                    ),
                    child: selectedButtons.isEmpty
                        ? Center(
                            child: Text(
                              'Your message goes here!',
                              style: TextStyle(
                                color: Colors.pink.shade300,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(3),
                            itemCount: selectedButtons.length,
                            itemBuilder: (context, index) {
                              final button = selectedButtons[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        button.image,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.image_not_supported,
                                              );
                                            },
                                      ),
                                    ),
                                    Text(
                                      button.word,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 5),

                // CLEAR BUTTON
                SizedBox(
                  width: 48,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: clearMessage,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.pink.shade700,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 21),
                        Text('Clear', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 5),

                // SPEAK BUTTON
                SizedBox(
                  width: 52,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: selectedButtons.isEmpty ? null : speakMessage,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.pink.shade400,
                      foregroundColor: Colors.white,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up, size: 22),
                        Text('Speak', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // THE 10 x 6 PICTURE GRID
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 10;
                const rows = 6;
                const spacing = 3.0;
                const padding = 3.0;

                final buttonWidth =
                    (constraints.maxWidth -
                        padding * 2 -
                        spacing * (columns - 1)) /
                    columns;

                final buttonHeight =
                    (constraints.maxHeight -
                        padding * 2 -
                        spacing * (rows - 1)) /
                    rows;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(padding),
                  itemCount: aacButtons.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: buttonWidth / buttonHeight,
                  ),
                  itemBuilder: (context, index) {
                    final button = aacButtons.values.elementAt(index);

                    return AACGridButton(
                      button: button,
                      onTap: () => addButton(button),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// One clickable, animated picture
class AACGridButton extends StatefulWidget {
  final AACButton button;
  final VoidCallback onTap;

  const AACGridButton({super.key, required this.button, required this.onTap});

  @override
  State<AACGridButton> createState() => _AACGridButtonState();
}

class _AACGridButtonState extends State<AACGridButton> {
  double scale = 1.0;

  Future<void> animateTap() async {
    setState(() {
      scale = 1.8;
    });

    widget.onTap();

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: animateTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 2000),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.pink.shade100),
          ),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  widget.button.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 18);
                  },
                ),
              ),
              Text(
                widget.button.word,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
