import 'package:covid_19/constant.dart';
import 'package:covid_19/graph.dart';
import 'package:covid_19/widgets/counter.dart';
import 'package:covid_19/widgets/my_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:covid_19/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid 19',
      theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          fontFamily: "Poppins",
          textTheme: TextTheme(
            body1: TextStyle(color: kBodyTextColor),
          )),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map statescode={};



  final controller = ScrollController();
  double offset = 0;
  int active,confirmed,deceased,recovered;
  int activeTotal,confirmedTotal,deceasedTotal,recoveredTotal;
  int confirmedTotalDelta,deceasedTotalDelta,recoveredTotalDelta;
  String state;
  List<String> states=[];
  String city;
  List<String> cities=[];
  Map data;
  Map totaldata;
  Map loaddata,loadtotaldata;
  Map olddata;
  DateTime date;

  startTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('first_time');

    var _duration = new Duration(seconds: 3);

    if (firstTime != null && !firstTime) {// Not first time
      getCompleteLoadData();
      //getCompleteData();

    } else {// First time
      getCompleteData();
      prefs.setBool('first_time', false);

    }
  }

  void getCompleteLoadData() async {
    print("getCompleteLoadData");

    FilePersistence fp = new FilePersistence();
    data = await fp.getObject('1', '1');
    totaldata = await fp.getObject('2', '2');

    activeTotal = int.parse(totaldata["statewise"][0]["active"]);
    confirmedTotal = int.parse(totaldata["statewise"][0]["confirmed"]);
    deceasedTotal = int.parse(totaldata["statewise"][0]["deaths"]);
    recoveredTotal = int.parse(totaldata["statewise"][0]["recovered"]);

    confirmedTotalDelta=int.parse(totaldata["statewise"][0]["deltaconfirmed"]);
    deceasedTotalDelta = int.parse(totaldata["statewise"][0]["deltadeaths"]);
    recoveredTotalDelta = int.parse(totaldata["statewise"][0]["deltarecovered"]);
    print((totaldata["statewise"][0]["lastupdatedtime"]));
    states.clear();
    states.add("India");
    statescode["India"]="TT";
    data.forEach((k,v) {
      if(k!="State Unassigned")
        {
          states.add(k);
          //print(k);
          //print(v["statecode"]);
          statescode[k]=v["statecode"];
        }

    });
    //print(statescode);
    if(state=="India")
    {
      cities.clear();
      cities.add("Total");
      city="Total";
      active = activeTotal;
      confirmed = confirmedTotal;
      deceased = deceasedTotal;
      recovered = recoveredTotal;
    }
    else
    {
      cities.clear();
      cities.add("Total");
      city='Total';
      data[state]["districtData"].forEach((k,v) {
        cities.add(k);
      });
    }


    setState(() {

    });

    getCompleteData();



  }

  void getCompleteData() async {
    print("getCompleteData");
    Response response = await get('https://api.covid19india.org/state_district_wise.json');
    Response response1 = await get('https://api.covid19india.org/data.json');
    //print(response.body);
    //print("akshit");
    data = jsonDecode(response.body);
    totaldata=jsonDecode(response1.body);
    //print(data);


    //offline capability start------------------------
    //String jsonString = jsonEncode(data);
    //print(jsonString.runtimeType);
    //print(data.runtimeType);
    FilePersistence fp = new FilePersistence();
    //print(jsonString);
    //await fp.saveString('1', '1', jsonString);

    await fp.saveObject('1', '1', data);
    loaddata = await fp.getObject('1', '1');
    await fp.saveObject('2', '2', totaldata);
    loadtotaldata = await fp.getObject('2', '2');

    //String loadString = await fp.getString('1', '1');
    //print(loadString);
    //Map loaddata=jsonDecode(loadString);
    //print(loaddata);
    //loaddata=fp.getObject('1', '1');
    //print(loaddata);



    // offline capability end-----------------------



    //print(totaldata["statewise"][0]["active"]);
    //print(totaldata["statewise"][0]["active"].runtimeType);
    //print(totaldata["statewise"].length);
    activeTotal = int.parse(totaldata["statewise"][0]["active"]);
    confirmedTotal = int.parse(totaldata["statewise"][0]["confirmed"]);
    deceasedTotal = int.parse(totaldata["statewise"][0]["deaths"]);
    recoveredTotal = int.parse(totaldata["statewise"][0]["recovered"]);

    confirmedTotalDelta=int.parse(totaldata["statewise"][0]["deltaconfirmed"]);
    deceasedTotalDelta = int.parse(totaldata["statewise"][0]["deltadeaths"]);
    recoveredTotalDelta = int.parse(totaldata["statewise"][0]["deltarecovered"]);
    //print((totaldata["statewise"][0]["lastupdatedtime"]));
    //print(DateTime.parse(totaldata["statewise"][0]["lastupdatedtime"]).runtimeType);

    String st=totaldata["statewise"][0]["state"];
    //print('$activeTotal $confirmedTotal $deceasedTotal $recoveredTotal $st');
    states.clear();
    states.add("India");
    statescode["India"]="TT";
    data.forEach((k,v) {
      //print('$k');
      if(k!="State Unassigned")
        {
          states.add(k);
          statescode[k]=v["statecode"];
        }

      //states.add('siikin');
    });
    if(state=="India")
      {
        cities.clear();
        cities.add("Total");
        city="Total";
        //cities.add("Total");
        active = activeTotal;
        confirmed = confirmedTotal;
        deceased = deceasedTotal;
        recovered = recoveredTotal;
      }
    else
      {
        cities.clear();
        cities.add("Total");
        //city="Total";
        getData();
        data[state]["districtData"].forEach((k,v) {
          //print('$k');
          //if(k!="State Unassigned")
          cities.add(k);
          //states.add('siikin');
        });
      }

    /*
    active = data[state]["districtData"][city]["active"];
    confirmed = data[state]["districtData"][city]["confirmed"];
    deceased = data[state]["districtData"][city]["deceased"];
    recovered = data[state]["districtData"][city]["recovered"];

     */

    print('akshit get complete data');
    setState(() {

    });


  }

  void getCityData()
  { //print(state);

    if(state=="India")
    {
      cities.clear();
      cities.add("Total");
      city="Total";
      active = activeTotal;
      confirmed = confirmedTotal;
      deceased = deceasedTotal;
      recovered = recoveredTotal;

      confirmedTotalDelta=int.parse(totaldata["statewise"][0]["deltaconfirmed"]);
      deceasedTotalDelta = int.parse(totaldata["statewise"][0]["deltadeaths"]);
      recoveredTotalDelta = int.parse(totaldata["statewise"][0]["deltarecovered"]);
      //getData();
      setState(() {

      });
    }
    else
    {
      //Implementing Total state counts

      cities.clear();
      cities.add("Total");
      data[state]["districtData"].forEach((k,v) {
        //print('$k');
        //if(k!="State Unassigned")
        cities.add(k);
        //states.add('siikin');
      });
      city=cities[0];
      getData();
      setState(() {

      });

    }
  }

  void getData() {

    if(city!="Total")
      {
        active = data[state]["districtData"][city]["active"];
        confirmed = data[state]["districtData"][city]["confirmed"];
        deceased = data[state]["districtData"][city]["deceased"];
        recovered = data[state]["districtData"][city]["recovered"];

        confirmedTotalDelta=data[state]["districtData"][city]["delta"]["confirmed"];
        deceasedTotalDelta = data[state]["districtData"][city]["delta"]["deceased"];
        recoveredTotalDelta = data[state]["districtData"][city]["delta"]["recovered"];

        print('akshit getdata');
      }
    else if(state=="India")
    {
      cities.clear();
      cities.add("Total");
      city="Total";
      active = activeTotal;
      confirmed = confirmedTotal;
      deceased = deceasedTotal;
      recovered = recoveredTotal;

      confirmedTotalDelta=int.parse(totaldata["statewise"][0]["deltaconfirmed"]);
      deceasedTotalDelta = int.parse(totaldata["statewise"][0]["deltadeaths"]);
      recoveredTotalDelta = int.parse(totaldata["statewise"][0]["deltarecovered"]);
      //getData();
      setState(() {

      });
    }
    else if(city=="Total")
      {
        int i;
        for(i=0;i<totaldata["statewise"].length;i++)
        {
          String st=totaldata["statewise"][i]["state"];
          if(st==state)
            break;
          //print('$st ');
        }
        active = int.parse(totaldata["statewise"][i]["active"]);
        confirmed = int.parse(totaldata["statewise"][i]["confirmed"]);
        deceased = int.parse(totaldata["statewise"][i]["deaths"]);
        recovered = int.parse(totaldata["statewise"][i]["recovered"]);

        confirmedTotalDelta=int.parse(totaldata["statewise"][i]["deltaconfirmed"]);
        deceasedTotalDelta = int.parse(totaldata["statewise"][i]["deltadeaths"]);
        recoveredTotalDelta = int.parse(totaldata["statewise"][i]["deltarecovered"]);
      }


    setState(() {

    });
    //getCityData();
    //print(data['title']);
  }
  String statetocode(String state)
  {
    return state;
  }

  int checknull(int val)
  {
    if(val==null)
      return 0;
    return val;
  }

  void getolddata(String year,String month, String day) async
  {

    print("getolddata");
    Response response = await get('https://api.covid19india.org/v4/data-${year}-${month}-${day}.json');
    olddata = jsonDecode(response.body);
    //print(olddata);
    //int check=int.parse(olddata["UP"]["total"]["confirmed"]);
    getolddatautil();

  }

  void getolddatautil()
  {
    String stcode='';
    stcode=statescode[state];
    int other=0;
    if(city=='Total')
    {



      confirmed = checknull(olddata[stcode]["total"]["confirmed"]);
      deceased = checknull(olddata[stcode]["total"]["deceased"]);
      recovered = checknull(olddata[stcode]["total"]["recovered"]);
      other=checknull(olddata[stcode]["total"]["other"]);
      active = confirmed-deceased-recovered-other;

      confirmedTotalDelta=checknull(olddata[stcode]["delta"]["confirmed"]);
      deceasedTotalDelta = checknull(olddata[stcode]["delta"]["deceased"]);
      recoveredTotalDelta = checknull(olddata[stcode]["delta"]["recovered"]);

    }
    else
    {

      confirmed = checknull(olddata[stcode]["districts"][city]["total"]["confirmed"]);
      deceased = checknull(olddata[stcode]["districts"][city]["total"]["deceased"]);
      recovered = checknull(olddata[stcode]["districts"][city]["total"]["recovered"]);
      other=checknull(olddata[stcode]["districts"][city]["total"]["other"]);
      active = confirmed-deceased-recovered-other;

      confirmedTotalDelta=checknull(olddata[stcode]["districts"][city]["delta"]["confirmed"]);
      deceasedTotalDelta =checknull(olddata[stcode]["districts"][city]["delta"]["deceased"]);
      recoveredTotalDelta = checknull(olddata[stcode]["districts"][city]["delta"]["recovered"]);

    }
    setState(() {

    });
    //print(olddata["TT"]["total"]["confirmed"]);
  }

  void getolddatastate()
  {
    if(state=="India")
    {
      cities.clear();
      cities.add("Total");
      city="Total";

      //getData();

    }
    else
    {
      //Implementing Total state counts

      cities.clear();
      cities.add("Total");
      data[state]["districtData"].forEach((k,v) {
        //print('$k');
        //if(k!="State Unassigned")
        cities.add(k);
        //states.add('siikin');
      });
      city=cities[0];


    }
    getolddatautil();
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    state="India";
    city='Total';
    startTime();
    //getCompleteData();
    //print('akshit');
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Text('About'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Made by Akshit Agarwal'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  String todayDatestr="${DateTime.now().toLocal()}".split(' ')[0];
  DateTime selectedDate = DateTime.now();
  String selectedDatestr="${DateTime.now().toLocal()}".split(' ')[0];

  Future<Null> _selectDate(BuildContext context) async {
    //print(todayDatestr);
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());

    //print(selectedDatestr);

    if (picked != null && picked != selectedDate)
      setState(() {
        print(selectedDate);
        selectedDate = picked;
        print(selectedDate);
        selectedDatestr="${selectedDate.toLocal()}".split(' ')[0];
        String year="${selectedDate.toLocal()}".split(' ')[0].split('-')[0];
        String month="${selectedDate.toLocal()}".split(' ')[0].split('-')[1];
        String day="${selectedDate.toLocal()}".split(' ')[0].split('-')[2];
        if(selectedDatestr!=todayDatestr)
        getolddata(year, month, day);
        else
          getData();
        //print(year+month+day);
        //print("${selectedDate.toLocal()}".split(' ')[0].split('-')[0]);
      });
  }

  @override
  Widget build(BuildContext context) {
    var myGroup = AutoSizeGroup();
    date=DateTime.now();
    //print(date);
    //print(date.day);
    //print(date);
    return RefreshIndicator(

      onRefresh: ()async {

         getCompleteData();
        print('refresh complete');
         Fluttertoast.showToast(
             msg: "Refresh Complete",
             toastLength: Toast.LENGTH_SHORT,
             gravity: ToastGravity.BOTTOM,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.grey,
             textColor: Colors.white,
             fontSize: 16.0
         );
      },
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton.icon(onPressed: (){
              return _showMyDialog();
            }, icon: Icon(Icons.person,color: Colors.white,), label: Text("About",style: TextStyle(color: Colors.white),))

          ],

          backgroundColor: Color(0xFF3383CD),
          title: Text('Covid Tracker'),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: <Widget>[
              MyHeader(
                image: "assets/icons/Drcorona.svg",
                textTop: "Stay Home",
                textBottom: "Stay Safe",
                offset: offset,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset("assets/icons/maps-and-flags.svg"),
                    SizedBox(width: 20),
                    Expanded(
                      child: DropdownButton(
                        isExpanded: true,
                        underline: SizedBox(),
                        icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                        value: state,
                        items: states.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          //TODO : update state info
                          state=value;
                          if(selectedDatestr==todayDatestr)
                          getCityData();
                          else
                            getolddatastate();
                          //getData();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset("assets/icons/maps-and-flags.svg"),
                    SizedBox(width: 20),
                    Expanded(
                      child: DropdownButton(
                        isExpanded: true,
                        underline: SizedBox(),
                        icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                        value: city,
                        items: cities.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          city=value;
                          //print(selectedDatestr);
                          //print(todayDatestr);

                          if(selectedDatestr==todayDatestr)
                          getData();
                          else
                            getolddatautil();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Case Update\n",
                                style: kTitleTextstyle,
                              ),
                              /*TextSpan(
                                text: "Newest update ${date.day}/${date.month}/${date.year}",
                                style: TextStyle(
                                  color: kTextLightColor,
                                ),
                              ),*/
                            ],
                          ),
                        ),

                        Spacer(),
                        Text(
                          "",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    RaisedButton(
                      onPressed: () => _selectDate(context),
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF42A5F5),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child:
                         Text("${selectedDate.toLocal()}".split(' ')[0].split('-')[2]+'/'+"${selectedDate.toLocal()}".split(' ')[0].split('-')[1]+'/'+"${selectedDate.toLocal()}".split(' ')[0].split('-')[0], style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    /*RaisedButton(
                      onPressed: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>BarChartSample1()));
                      },
                      child: Text("Details")
                    ),*/
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 30,
                            color: kShadowColor,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Counter(
                              myGroup: myGroup,
                              color: kInfectedColor,
                              deltanumber: confirmedTotalDelta,
                              number: confirmed,
                              title: "Infected",
                            ),
                          ),
                          Expanded(
                            child:Counter(
                              myGroup: myGroup,
                              color: kInfectedColor,
                              deltanumber: 0,
                              number: active,
                              title: "Active",
                            ),
                          ),
                          Expanded(
                            child: Counter(
                              myGroup: myGroup,
                              color: kRecovercolor,
                              deltanumber: recoveredTotalDelta,
                              number: recovered,
                              title: "Recovered",
                            ),
                          ),
                          Expanded(
                            child: Counter(
                              myGroup: myGroup,
                              color: kDeathColor,
                              deltanumber: deceasedTotalDelta,
                              number: deceased,
                              title: "Deaths",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
