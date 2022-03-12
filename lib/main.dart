import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskItem{
  bool _state;
  String _name;
  TaskItem([this._state = false, this._name = '']);

  factory TaskItem.fromJson(Map<String, dynamic> jsonData) {
    return TaskItem(
      jsonData['state'],
      jsonData['name'],
    );
  }

  static Map<String, dynamic> toMap(TaskItem taskItem) => {
    'state': taskItem._state,
    'name': taskItem._name,
  };

  static String encode(List<TaskItem> taskItems) => json.encode(
    taskItems.map<Map<String, dynamic>>((taskItem) => TaskItem.toMap(taskItem)).toList(),
  );

  static List<TaskItem> decode(String taskItems) => (json.decode(
      taskItems) as List<dynamic>).map<TaskItem>((item) => TaskItem.fromJson(item)).toList();
}

class CustomTheme{
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      textTheme: const TextTheme(
        headline1: TextStyle(height: 0.0, fontSize: 56, color: Colors.black, fontWeight: FontWeight.w800, fontFamily: "Inter"),
        bodyText1: TextStyle(fontSize: 18, color: Color(0xFF575767), fontWeight: FontWeight.w500, fontFamily: "Inter"),
      ),
      primaryColorDark: const Color(0xFFDADADA),

      primaryColor: const Color(0xFFFCFCFC),
      primaryColorLight: const Color(0xFFF8F8F8),
      dividerColor: const Color(0xFFEBEBEB),
      cardColor: const Color(0xFFF2F3FF),
      backgroundColor: const Color(0xFFEBEBEB),
      iconTheme: const IconThemeData(color: Color(0xFF575767)),
    );
  }
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF1E1F25),
      textTheme: const TextTheme(
        headline1: TextStyle(height: 0.0, fontSize: 56, color: Colors.white, fontWeight: FontWeight.w800, fontFamily: "Inter"),
        bodyText1: TextStyle(fontSize: 18, color: Color(0xFFDADADA), fontWeight: FontWeight.w500, fontFamily: "Inter"),
      ),
      primaryColorDark: const Color(0xFF0E0E11),
      primaryColor: const Color(0xFF2B2D37),
      primaryColorLight: const Color(0xFF262933),
      dividerColor: const Color(0xFF29292F),
      cardColor: const Color(0xFF24242D),
      backgroundColor: const Color(0xFF29292F),
      iconTheme: const IconThemeData(color: Color(0xFF575767)),
    );
  }
}

SharedPreferences? prefs;
List<TaskItem> taskList = List.empty(growable: true);
String newTaskTame = '';

void saveTasksInPrefs() async{
  final String newTaskItemsString = TaskItem.encode(taskList);
  String? currentTaskItemsString = await prefs?.getString('tasks');
  if(newTaskItemsString!=currentTaskItemsString){
    await prefs?.setString('tasks', newTaskItemsString);
  }
}

void saveTaskItem(){
  if (newTaskTame.isEmpty) {
    if (taskList.isNotEmpty) {
      if (taskList[0]._name.isEmpty) {
        taskList.removeAt(0);
      }
    }
  }
  else {
    taskList[0]._name = newTaskTame;
    newTaskTame = '';
    saveTasksInPrefs();
  }
}

void readTasks() async{
  String? taskItemsString = await prefs?.getString('tasks');
  if(taskItemsString!=null) {
    taskList = TaskItem.decode(taskItemsString);
  }
}

void main() async{
  runApp(MyApp(UniqueKey()));
}

class MyApp extends StatefulWidget {
  const MyApp(Key key): super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  @override
  Widget build(BuildContext context) {
    var brightness = WidgetsBinding.instance!.window.platformBrightness;

    return MaterialApp(
      home: MyHomePage(UniqueKey()),
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: brightness==Brightness.dark? ThemeMode.dark:ThemeMode.light,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(Key key) : super(key: key);

  bool keyboardState           = false;
  bool keyboardPreviousState  = false;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ScrollController controller = ScrollController();

  void keyboardStateObserve(){
    widget.keyboardPreviousState = widget.keyboardState;
    if(MediaQuery.of(context).viewInsets.bottom==0) {
      widget.keyboardState = false;
    } else {
      widget.keyboardState = true;
    }

  }
  bool keyboardWasHidden(){
    if((widget.keyboardPreviousState)&&(!widget.keyboardState)){
      return true;
    } else {
      return false;
    }
  }

  void initPrefs()async{
    prefs = await SharedPreferences.getInstance();
    readTasks();
    setState((){});
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    initPrefs();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    double iconSize = 36*(screenWidth/505);
    double buttonSize = 56*(screenWidth/505);

    double textSizeFactor = screenWidth/505;
    double topSpaceHeight = 64*(screenWidth/505);
    double headerHeight = 56*(screenWidth/505);
    double dividerHeight = 44*(screenWidth/505);
    double taskItemHeight = 24*(screenWidth/505);
    double taskItemSpace = 32*(screenWidth/505);
    double taskItemCheckboxSpacerSize = 10*(screenWidth/505);
    double textFieldWidth = screenWidth - taskItemCheckboxSpacerSize - taskItemSpace - 2*topSpaceHeight;

    keyboardStateObserve();
    if(keyboardWasHidden()) {
      saveTaskItem();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row( children: [
        SizedBox(width: topSpaceHeight),
        Expanded( child: Column(
          children: <Widget>[
            SizedBox(height: topSpaceHeight+ MediaQuery.of(context).padding.top),
            SizedBox(height: headerHeight,
              child: Row(children: [
                Expanded(child: Container(alignment: Alignment.bottomLeft,
                    child: Text("Tasks", style: Theme.of(context).textTheme.headline1?.apply(fontSizeFactor: textSizeFactor))), flex: 1),
                Align(alignment: Alignment.topRight, child: SizedBox( height: buttonSize, width: buttonSize,
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(width: 1, color: Theme.of(context).backgroundColor,),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      color: Theme.of(context).cardColor,),
                    child: IconButton(padding: const EdgeInsets.all(0), iconSize: iconSize, icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color,),
                        onPressed: () {
                          if(widget.keyboardState){
                            saveTaskItem();
                          }
                          taskList.insert(0,TaskItem());
                            if(controller.hasClients){
                              controller.animateTo(0.0, curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
                            }
                          setState(() {});
                          //prefs?.clear();
                    }),
                  ),
                ),),
              ],),
            ),
            Container(height: dividerHeight),
            Divider(height: 0, thickness: 1, indent: 0, endIndent: 0, color: Theme.of(context).dividerColor,),
            Expanded(
              child: taskList.isEmpty? Container():Padding( padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Scrollbar(
                  isAlwaysShown: true,
                  controller: controller,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    controller: controller,
                    itemCount: taskList.length,
                    itemBuilder: (context, i){ return TaskItemWidget(i, taskItemHeight, taskItemSpace, taskItemCheckboxSpacerSize, textFieldWidth);},
                  ),
                ),
              ),
            flex: 1),
          ],
        ), flex: 1),
        SizedBox(width: topSpaceHeight),
      ],),
    );
  }
}


class TaskItemWidget extends StatefulWidget {

  final int itemNumber;
  final double taskItemHeight, verticalInterval, spacerSize, textFieldWidth;

  TaskItemWidget(this.itemNumber,  this.taskItemHeight, this.verticalInterval, this.spacerSize, this.textFieldWidth) {}

  @override
  TaskItemState createState() => TaskItemState();
}

class TaskItemState extends State<TaskItemWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(children: [
        Container(height: widget.verticalInterval),
          taskList.isEmpty ? Container() : Row(children: [
            GestureDetector(onTap: () {
              taskList[widget.itemNumber]._state ?
              taskList[widget.itemNumber]._state = false : taskList[widget.itemNumber]._state = true;
              saveTasksInPrefs();
              setState(() {});
            },
              child:Container(
                width: widget.taskItemHeight, height: widget.taskItemHeight,
                decoration: BoxDecoration(border: Border.all(width: 2, color: Theme.of(context).primaryColorDark,),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight,],),),
                child: taskList[widget.itemNumber]._state ? FittedBox(
                  fit: BoxFit.fill, child: Icon(Icons.check, color: Theme.of(context).textTheme.headline1?.color),): Container(),
              ),
            ),

            Container(width: widget.spacerSize),
            Container(width: widget.textFieldWidth, height: widget.taskItemHeight, padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
              child: taskList[widget.itemNumber]._name.isEmpty ?
                TextFormField(
                  initialValue: newTaskTame,
                  key: UniqueKey(),
                  autofocus: true,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyText1?.apply(fontSizeFactor: widget.taskItemHeight / 24),
                  onChanged: (text) {newTaskTame = text;},
                  onFieldSubmitted: (text) {saveTaskItem();},
                  onSaved: (text) {},
                ):
                Text(
                    taskList[widget.itemNumber]._name,
                    style: Theme.of(context).textTheme.bodyText1?.apply(fontSizeFactor: widget.taskItemHeight / 24)),
            ),
          ]
        )
      ]
    );
  }
}