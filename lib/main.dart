import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:folding_cell/folding_cell/widget.dart';
import 'package:particle_background/simple_animations_package.dart';

void main() => runApp(ParticleApp());

class ParticleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Intro() // ParticleBackgroundPage(),
      ),
    );
  }
}

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      padding: EdgeInsets.only(top: 30.0),
      child: Center(child: FoldingCellSimpleDemo() ,)
    );
  }
}


class FoldingCellSimpleDemo extends StatelessWidget {
  final _foldingCellKey = GlobalKey<SimpleFoldingCellState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Color(0xFF2e282a),
      //alignment: Alignment.topCenter,
      child: SimpleFoldingCell(
          key: _foldingCellKey,
          frontWidget: _buildFrontWidget(),
          innerTopWidget: _buildInnerTopWidget(),
          innerBottomWidget: _buildInnerBottomWidget(context),
          cellSize: Size(MediaQuery.of(context).size.width/1.5, MediaQuery.of(context).size.height/3 ),
          padding: EdgeInsets.all(15),
          animationDuration: Duration(milliseconds: 300),
          borderRadius: 10,
          onOpen: () => print('cell opened'),
          onClose: () => print('cell closed')),
    );
  }

  Widget _buildFrontWidget() {
    return Container(
        color: Color(0xFFffcd3c),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("HI THERE",
                style: TextStyle(
                    color: Color(0xFF2e282a),
                    fontFamily: 'OpenSans',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w800)),
            FlatButton(
              onPressed: () => _foldingCellKey?.currentState?.toggleFold(),
              child: Text(
                "You: Um.. Hello.",
              ),
              textColor: Colors.white,
              color: Colors.indigoAccent,
              splashColor: Colors.white.withOpacity(0.5),
            )
          ],
        ));
  }

  Widget _buildInnerTopWidget() {
    return Container(
        color: Color(0xFFff9234),
        //alignment: Alignment.center,
        child: Center(
          child: Text("Today is a\n very\n special day!",
          textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF2e282a),
                  fontFamily: 'OpenSans',
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800)),
        ));
  }

  Widget _buildInnerBottomWidget(BuildContext context) {
    return Container(
      color: Color(0xFFecf2f9),
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FlatButton(
          onPressed: () {
            _foldingCellKey?.currentState?.toggleFold();
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ParticleBackgroundPage()));
          },
          child: Text(
            "You: What is It?",
          ),
          textColor: Colors.white,
          color: Colors.indigoAccent,
          splashColor: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class ParticleBackgroundPage extends StatefulWidget {
  @override
  _ParticleBackgroundPageState createState() => _ParticleBackgroundPageState();
}

class _ParticleBackgroundPageState extends State<ParticleBackgroundPage> {
  bool showImage = false;

  void showImageFn(){
    
    setState(() {
      showImage = true;  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: AnimatedBackground()),
        Positioned.fill(child: Particles(30)),
        showImage? Container():Positioned.fill(child: CenteredText(showImageFn: showImageFn)),
        (!showImage)? Container():Positioned.fill(
          child: GestureDetector(
            onTap: ()=> window.open('http://wtlab.iis.u-tokyo.ac.jp/en/images/materials/brochure20190401.pdf', 'name') ,
                      child: Image.asset(
              'assets/deepu.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
              ),
          ),
        )
      ],
    );
  }
}

class Particles extends StatefulWidget {
  final int numberOfParticles;

  Particles(this.numberOfParticles);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(ParticleModel(random));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 30),
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: ParticlePainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
}

class ParticleModel {
  Animatable tween;
  double size;
  AnimationProgress animationProgress;
  Random random;

  ParticleModel(this.random) {
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    final duration = Duration(milliseconds: 3000 + random.nextInt(6000));

    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 0.2 + random.nextDouble() * 0.4;
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  Duration time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(50);

    particles.forEach((particle) {
      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position =
          Offset(animation["x"] * size.width, animation["y"] * size.height);
      canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff8a113a), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff440216), end: Colors.blue.shade600))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class CenteredText extends StatelessWidget {
  final Function showImageFn;
  const CenteredText({
    Key key, this.showImageFn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Today is Deepanshu's Birthdayy!! Happiee Birthdayy!! 🎂🎂🎂🎂",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200, fontSize: 40.0),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
              onPressed: () {
                showImageFn();
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(title: Text("Behold your 👀!!"), content: Text("Behind this Dialog box is Deepu!!"), actions: <Widget>[FlatButton(
                      child: Text("Yea yea..the President on his feet guy.."), onPressed: ()=>Navigator.of(context).pop(),
                    )],);
                  },
                );
              },
              child: Text(
                "Who's Deepanshu? 🤔",
              ),
              textColor: Colors.white,
              color: Colors.grey,
              splashColor: Colors.white.withOpacity(0.5),
          ),
            ),
          ],
        ),
      ),
    );
  }
}
