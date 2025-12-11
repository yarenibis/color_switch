import 'dart:ui';
import 'package:color_switch/player.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'circle_rotator.dart';
import 'color_switcher.dart';
import 'ground.dart';
import 'star_component.dart';

class MyGame extends FlameGame
    with TapCallbacks, HasCollisionDetection, HasDecorator, HasTimeScale {
  late Player myPlayer;

  final List<Color> gameColors;
  final List<PositionComponent> _gameComponents =[];

  final ValueNotifier<int> currentScore = ValueNotifier(0);

  MyGame({
    this.gameColors = const [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.yellowAccent,
    ],
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: 600,
            height: 1000,
          ),
        );

  @override
  Color backgroundColor() => const Color(0xff222222);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    decorator = PaintDecorator.blur(0);
    FlameAudio.bgm.initialize();
    await Flame.images.loadAll([
      'finger_tap.png',
      'star_icon.png',
    ]);
    await FlameAudio.audioCache.loadAll([
      'background.mp3',
      'collect.wav',
    ]);
  }

  @override
  void onMount() {
    _initializeGame();
    super.onMount();
  }

  @override
  void update(double dt) {
    final cameraY = camera.viewfinder.position.y;
    final playerY = myPlayer.position.y;
    if (playerY < cameraY) {
      camera.viewfinder.position = Vector2(0, playerY);
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    myPlayer.jump();
    super.onTapDown(event);
  }

  void _initializeGame() {
    currentScore.value = 0;
    world.add(Ground(position: Vector2(0, 400)));
    world.add(myPlayer = Player(position: Vector2(0, 250)));
    camera.moveTo(Vector2(0, 0));
    _generateGameComponents(
      Vector2(0, 20)
    );
   
    FlameAudio.bgm.play('background.mp3');
  }

void _addComponentToTheGame(PositionComponent component){
    _gameComponents.add(component);
    world.add(component);
}


  void _generateGameComponents(Vector2 generateFromPosition) {
    _addComponentToTheGame(ColorSwitcher(position: generateFromPosition+ Vector2(0, 180)));
    _addComponentToTheGame(CircleRotator(
      position: generateFromPosition+Vector2(0, 0),
      size: Vector2(200, 200),
    ));
    _addComponentToTheGame(StarComponent(
      position: generateFromPosition +Vector2(0, 0),
    ));
 
   generateFromPosition -=Vector2(0,380);

    _addComponentToTheGame(ColorSwitcher(position: generateFromPosition +Vector2(0, 180),),);
    _addComponentToTheGame(CircleRotator(
      position: generateFromPosition +Vector2(0, 0),
      size: Vector2(200, 200),
    ));
    _addComponentToTheGame(StarComponent(
      position:generateFromPosition + Vector2(0, 0),
    ));

generateFromPosition -=Vector2(0,250);
    _addComponentToTheGame(ColorSwitcher(position: generateFromPosition + Vector2(0, 0)));
    _addComponentToTheGame(CircleRotator(
      position:generateFromPosition + Vector2(0, -200),
      size: Vector2(150, 150),
    ));
    _addComponentToTheGame(CircleRotator(
      position:generateFromPosition + Vector2(0, -200),
      size: Vector2(180, 180),
    ));
    _addComponentToTheGame(StarComponent(
      position:generateFromPosition + Vector2(0, -200),
    ));

  }

 
  void gameOver() {
    FlameAudio.bgm.stop();
    for (var element in world.children) {
      element.removeFromParent();
    }
    _initializeGame();
  }

  bool get isGamePaused => timeScale == 0.0;

  bool get isGamePlaying => !isGamePaused;

  void pauseGame() {
    (decorator as PaintDecorator).addBlur(10);
    timeScale = 0.0;
    FlameAudio.bgm.pause();
  }

  void resumeGame() {
    (decorator as PaintDecorator).addBlur(0);
    timeScale = 1.0;
    FlameAudio.bgm.resume();
  }

  void increaseScore() {
    currentScore.value++;
  }

  void checkToGenerateNextBadge(StarComponent starComponent) {
     final allStarComponents= _gameComponents.whereType<StarComponent>().toList();
     final lenght =allStarComponents.length;
     for(int i=0; i<allStarComponents.length; i++){
      if(starComponent == allStarComponents[i] && i>=lenght-2){
        final lastStar=allStarComponents.last;
        _generateGameComponents(lastStar.position - Vector2(0,400));
        _tryToGarbageCollect(starComponent);
      }
     }
  }

  void _tryToGarbageCollect(StarComponent star_component){
     final lenght =_gameComponents.length;
     for(int i=0; i<_gameComponents.length; i++){
      if(star_component == _gameComponents[i] && i>=15){
        _removeComponentsFromGame(i-7);
        break;
      }
     }
  }

  void _removeComponentsFromGame(int n){
     for(int i=n-1; i>=0; i--){
       _gameComponents[i].removeFromParent();
       _gameComponents.removeAt(i);
     }
  }
}