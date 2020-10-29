import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ignore: must_be_immutable
class MusicPlayer extends StatefulWidget {

  SongInfo songInfo;
  Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({this.songInfo,this.changeTrack,this.key}):super(key: key);
  MusicPlayerState createState()=>MusicPlayerState();
}
class MusicPlayerState extends State<MusicPlayer> {
  double minimumValue=0.0, maximumValue=0.0, currentValue=0.0;
  String currentTime='', endTime='';
  bool isPlaying=false;
  final AudioPlayer player=AudioPlayer();

  void initState()  {
    super.initState();
    setSong(widget.songInfo);
  }
  void dispose()  {
    super.dispose();
    player?.dispose();
  }
  void setSong(SongInfo songInfo) async {
    widget.songInfo=songInfo;
    await player.setUrl(widget.songInfo.uri);
    currentValue=minimumValue;
    maximumValue=player.duration.inMilliseconds.toDouble();
    setState(() {
      currentTime=getDuration(currentValue);
      endTime=getDuration(maximumValue);
    });
    isPlaying=false;
    changeStatus();
    player.positionStream.listen((duration) {
      currentValue=duration.inMilliseconds.toDouble();
      setState(() {
        currentTime=getDuration(currentValue);
      });
    });
  }
  void changeStatus() {
    setState(() {
      isPlaying=!isPlaying;
    });
    if(isPlaying) {
      player.play();
    } else  {
      player.pause();
    }
  }
  String getDuration(double value)  {
    Duration duration=Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds].map((element)=>element.remainder(60).toString().padLeft(2, '0')).join(':');
  }
  var imageList = [
    "assets/images/image2.png",
    "assets/images/image2.png",
    "assets/images/image2.png",
  ];
  PageController _controller=  PageController(viewportFraction: 0.7,initialPage: 1);
  int _index= 0;
  Widget build(context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 57, 5, 0),
        child: Column(children:<Widget>[
          SizedBox(height: _height*0.02,),
          SmoothPageIndicator(
            count: 3,
            controller: _controller,
            effect:  WormEffect(
              dotHeight: 14,
              strokeWidth: 15,
              dotWidth: 14,
              spacing:  10.0,
              radius:  20.0,
              paintStyle:  PaintingStyle.fill,
              dotColor:  Color(0xFF5C5C6E).withOpacity(0.25),
              activeDotColor:  Color(0xFF5C5C6E),
            ),
          ),
          SizedBox(
            height: _height*0.4, // card height
            child: PageView.builder(
              itemCount: 3,
              controller: _controller,
              onPageChanged: (int index) => setState(() => _index = index),
              itemBuilder: (_, i) {
                return Transform.scale(
                  scale: i == _index ? 1 : 0.8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(imageList[i],fit: BoxFit.fill,),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(widget.songInfo.title,
            style: titleText
          ),),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 33),
            child: Text(widget.songInfo.artist,
              style: artistText
          ),),
          Slider(
            inactiveColor: artistTextColor.withOpacity(0.25),
            activeColor: artistTextColor,
            min: minimumValue,
            max: maximumValue,
            value: currentValue,
            onChanged: (value) {
            currentValue=value;
            player.seek(Duration(milliseconds: currentValue.round()));
          },),
          Container(
            transform: Matrix4.translationValues(0, -15, 0),margin: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
              Text(currentTime, style: timeText,),
              Text(endTime, style: timeText.copyWith(color: artistTextColor.withOpacity(0.5)),)
          ],),),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
             GestureDetector(
               child: Image.asset("assets/images/back.png"),
               behavior: HitTestBehavior.translucent,
               onTap: () {
                 widget.changeTrack(false);
             },),
             GestureDetector(
               child: Container(
                 height: 60,
                   width: 60,
                   child: Image.asset(isPlaying?"assets/images/pause.png":"assets/images/Subtract.png")),
               // child: Icon(isPlaying?Icons.pause:Icons.play_arrow, color: Colors.black, size: 85),
               behavior: HitTestBehavior.translucent,onTap: () {
              changeStatus();
             },),
             GestureDetector(
               child: Image.asset("assets/images/next.png"),
               // child: Icon(Icons.skip_next, color: Colors.black, size: 55),
               behavior: HitTestBehavior.translucent,
               onTap: () {
                widget.changeTrack(true);
            },),
          ],),),
        ]),
      ),
    );
  }
}