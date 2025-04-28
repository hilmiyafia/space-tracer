import 'dart:ui'; 
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:spacetracer/mygame.dart';
import 'package:spacetracer/myutils.dart';

late FragmentProgram faceFragment;
late FragmentProgram skyFragment;

void main() async {
  faceFragment = await FragmentProgram.fromAsset("assets/shaders/face.frag");
  skyFragment = await FragmentProgram.fromAsset("assets/shaders/sky.frag");
  runApp(
    Material(
      child: GameWidget.controlled(
        gameFactory: MyGame.new,
        overlayBuilderMap: {
          GameOverlay.main: (BuildContext context, MyGame game) {
            return Center(
              child: Stack(
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/images/menu.png"), 
                    width: double.infinity, 
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image(image: AssetImage("assets/images/title.png")),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            FlameAudio.play("button.ogg");
                            game.overlays.add(GameOverlay.selectLevel);
                          }, 
                          style: MyUtils.whiteButton,
                          child: Text("PLAY", style: MyUtils.blackText),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            FlameAudio.play("button.ogg");
                            game.overlays.add(GameOverlay.tutorial);
                          }, 
                          style: MyUtils.whiteButton,
                          child: Text("HOW TO PLAY", style: MyUtils.blackText),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            FlameAudio.play("button.ogg");
                            game.overlays.add(GameOverlay.settings);
                          }, 
                          style: MyUtils.whiteButton,
                          child: Text("SETTINGS", style: MyUtils.blackText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          GameOverlay.selectLevel: (BuildContext context, MyGame game) {
            final blockColors = <int>[
              0x800080FF, 0x80FF4000, 0x8000FF80
            ];
            final levelBlocks = List<Widget>.generate(3, (i) {
              BoxDecoration? foregroundDecoration;
              void Function()? onPressed;
              var iconPath = "assets/images/icon${i + 1}.png";
              if (i > 0 && MyUtils.recordTime[i - 1] < 0) {
                foregroundDecoration = BoxDecoration(
                  color: Color(0xC0000000),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                );
                iconPath = "assets/images/locked.png";
              } else {
                onPressed = () {
                  FlameAudio.play("button.ogg");
                  game.overlays.clear();
                  game.myWorld.loadLevel(i);
                };
              }
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(blockColors[i]),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                foregroundDecoration: foregroundDecoration,
                child: Column(
                  children: <Widget>[
                    Text("LEVEL ${i + 1}", style: MyUtils.whiteText),
                    SizedBox(height: 16),
                    Image(
                      image: AssetImage(iconPath), 
                      width: 128, 
                      height: 128,
                    ),
                    SizedBox(height: 16),
                    Text("Record", style: MyUtils.whiteText),
                    Text(
                      MyUtils.printTime(MyUtils.recordTime[i]),
                      style: MyUtils.whiteText,
                    ),
                    SizedBox(height: 16),
                    Text("Score", style: MyUtils.whiteText),
                    Text(
                      MyUtils.recordScore[i].toString(),
                      style: MyUtils.whiteText,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onPressed, 
                      style: MyUtils.whiteButton,
                      child: Text("PLAY", style: MyUtils.blackText),
                    ), 
                  ],
                ),
              );
            });
            return Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Color(0xC0000000),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("SELECT LEVEL", style: MyUtils.titleStyle),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        levelBlocks[0],
                        SizedBox(width: 16),
                        levelBlocks[1],
                        SizedBox(width: 16),
                        levelBlocks[2],
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        FlameAudio.play("button.ogg");
                        game.overlays.remove(GameOverlay.selectLevel);
                      }, 
                      style: MyUtils.whiteButton,
                      child: Text("BACK", style: MyUtils.blackText),
                    ),
                  ],
                ),
              ),
            );
          },
          GameOverlay.paused: (BuildContext context, MyGame game) {
            return Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Color(0xC0000000),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("PAUSED", style: MyUtils.titleStyle),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            FlameAudio.play("button.ogg");
                            game.overlays.remove(GameOverlay.paused);
                            game.overlays.add(GameOverlay.main);
                          }, 
                          style: MyUtils.whiteButton,
                          child: Text("ABORT RACE", style: MyUtils.blackText),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            FlameAudio.play("button.ogg");
                            game.overlays.remove(GameOverlay.paused);
                            game.myWorld.countDown(true);
                          }, 
                          style: MyUtils.whiteButton,
                          child: Text("RESUME", style: MyUtils.blackText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          GameOverlay.finished: (BuildContext context, MyGame game) {
            return Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Color(0xC0000000),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("FINISHED", style: MyUtils.titleStyle),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(MyUtils.levelColors[game.myWorld.level]),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "LEVEL ${game.myWorld.level + 1}",
                            style: MyUtils.whiteText,
                          ),
                          SizedBox(height: 16),
                          Text("Time", style: MyUtils.whiteText),
                          Text(
                            game.myWorld.timerText.text,
                            style: MyUtils.whiteText,
                          ),
                          SizedBox(height: 16),
                          Text("Score", style: MyUtils.whiteText),
                          Text(
                            game.myWorld.score.toString(),
                            style: MyUtils.whiteText,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (game.myWorld.finishMusic != null) {
                          game.myWorld.finishMusic!.stop();
                          game.myWorld.finishMusic!.dispose();
                          game.myWorld.finishMusic = null;
                        }
                        FlameAudio.play("button.ogg");
                        game.overlays.remove(GameOverlay.finished);
                        game.overlays.add(GameOverlay.main);
                      }, 
                      style: MyUtils.whiteButton,
                      child: Text("MENU", style: MyUtils.blackText),
                    ),
                  ],
                ),
              ),
            );
          },
          GameOverlay.tutorial: (BuildContext context, MyGame game) {
            return Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Color(0xC0000000),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("HOW TO PLAY", style: MyUtils.titleStyle),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0x800080FF),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Text(
                        (
                          "Use the arrow keys to move your view.\n" 
                          "Use the W key to move forward.\n" 
                          "Use the S key to brake.\n" 
                          "Use the spacebar to boost.\n\n" 
                          "Make sure to pass through the checkpoints in order.\n" 
                          "When you missed a checkpoint, there will be a warning on screen.\n"
                          "Use the R key to reset to the latest checkpoint.\n\n" 
                          "The red triangle in the minimap is your spaceship.\n"
                          "The blue dot in the minimap is the next checkpoint."
                        ),
                        textAlign: TextAlign.center,
                        style: MyUtils.whiteText,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        FlameAudio.play("button.ogg");
                        game.overlays.remove(GameOverlay.tutorial);
                      }, 
                      style: MyUtils.whiteButton,
                      child: Text("BACK", style: MyUtils.blackText),
                    ),
                  ],
                ),
              ),
            );
          },
          GameOverlay.settings: (BuildContext context, MyGame game) {
            return Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Color(0xC0000000),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("SETTINGS", style: MyUtils.titleStyle),
                    SizedBox(height: 16),
                    Container(
                      width: 256,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0x800080FF),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Checkbox(
                            value: MyUtils.inverseLook,
                            fillColor: WidgetStatePropertyAll(Color(0xFF000040)),
                            checkColor: Color(0xFFFFFFFF),
                            onChanged: (value) {
                              FlameAudio.play("button.ogg");
                              MyUtils.inverseLook = value ?? false;
                              game.overlays.remove(GameOverlay.settings);
                              game.overlays.add(GameOverlay.settings);
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              FlameAudio.play("button.ogg");
                              MyUtils.inverseLook = !MyUtils.inverseLook;
                              game.overlays.remove(GameOverlay.settings);
                              game.overlays.add(GameOverlay.settings);
                            },
                            child: Text(
                              "Invert Y (Plane Control)",
                              style: MyUtils.whiteText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        FlameAudio.play("button.ogg");
                        game.overlays.remove(GameOverlay.settings);
                      }, 
                      style: MyUtils.whiteButton,
                      child: Text("BACK", style: MyUtils.blackText),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        initialActiveOverlays: <String>[GameOverlay.main],
      ),
    ),
  );
}
