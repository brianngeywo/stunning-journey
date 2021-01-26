import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/DataHandler.dart/appData.dart';
import 'package:uber/assistants/request_assistant.dart';
import 'package:uber/models/placePredictions.dart';
import 'package:uber/screens/mainscreen.dart';
import 'package:uber/configMaps.dart';
import 'package:uber/widgets/divider.dart';
import 'package:uber/widgets/predictionTile.dart';

class SearchScreen extends StatefulWidget {
  static const String idScreen = "searchscreen";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextController = TextEditingController();
  TextEditingController dropOffTextController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress = Provider.of<AppData>(context).pickUpLocation != null
        ? Provider.of<AppData>(context).pickUpLocation.placeName
        : "enter pickup location";
    pickUpTextController.text = placeAddress;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
              child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 175,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 25, top: 20, right: 25, bottom: 10),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      Stack(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    MainScreen.idScreen, (route) => false);
                              },
                              child: Icon(Icons.arrow_back)),
                          Center(
                            child: Text(
                              "Set drop off",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Image.asset("assets/images/pickicon.png",
                              height: 15, width: 15),
                          SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: TextField(
                                  controller: pickUpTextController,
                                  decoration: InputDecoration(
                                    hintText: "pick up location",
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11, top: 8, bottom: 8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Image.asset("assets/images/desticon.png",
                              height: 15, width: 15),
                          SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: TextField(
                                  onChanged: (val) {
                                    findPlace(val);
                                  },
                                  controller: dropOffTextController,
                                  decoration: InputDecoration(
                                    hintText: "drop off location",
                                    hintStyle: TextStyle(color: Colors.black),
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 14, top: 10, bottom: 10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: (placePredictionList.length > 0)
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 16),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            return PredictionTile(
                              placePredictions: placePredictionList[index],
                            );
                          },
                          separatorBuilder: (BuildContext context, index) =>
                              DividerWidget(),
                          itemCount: placePredictionList.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 0) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:KE";
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == "Failed") {
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placesList;
        });
      }
      print("places prediction response :: ");
      print(res);
    }
  }
}
