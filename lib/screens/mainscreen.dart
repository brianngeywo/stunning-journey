import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/DataHandler.dart/appData.dart';
import 'package:uber/assistants/assistant_methods.dart';
import 'package:uber/assistants/geofireAssistant.dart';
import 'package:uber/configMaps.dart';
import 'package:uber/models/directionDetails.dart';
import 'package:uber/models/nearbyAvailableDrivers.dart';
import 'package:uber/screens/SearchScreen.dart';
import 'package:uber/widgets/DrawerMenu.dart';
import 'package:uber/widgets/progressDialog.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainscreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  bool mpesaPayment = false;
  bool cashPayment = true;
  GoogleMapController newgoogleMapController;
  DirectionDetails tripDirectionDetails;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineset = {};
  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 40;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  double searchContainerHeight = 30;
  double rideDetailsContainerHeight = 0;
  double paymentContainerHeight = 0;
  double requestRideContainerHeight = 0;
  Color selectedpaymentbackgroundcolor = Colors.green[50];

  DatabaseReference rideRequestRef;
  BitmapDescriptor nearbyIcon;
  Icon dropUpIcon = Icon(Icons.arrow_drop_down, color: Colors.white, size: 28);
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };
    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };
    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };
    rideRequestRef.push().set(rideInfoMap);
  }

  void cancelRideRequest() {
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 200;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 220;
      paymentContainerHeight = 0;
    });
    rideRequestRef.remove();
  }

  void displayPaymentsContainer() async {
    await getPlaceDirection();
    setState(() {
      paymentContainerHeight = 200;
      requestRideContainerHeight = 0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 210;
    });
    // saveRideRequest();
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 50;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 80;
      paymentContainerHeight = 0;
    });
    saveRideRequest();
  }

  resetApp() {
    setState(() {
      searchContainerHeight = 230;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 220;
      polylineset.clear();
      markerSet.clear();
      pLineCoordinates.clear();
      paymentContainerHeight = 0;
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 200;
      bottomPaddingOfMap = 210;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 17);
    newgoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("this is your address:" + address);
    initGeofireListner();
  }

  static final CameraPosition _kEldoret = CameraPosition(
    target: LatLng(0.51847, 35.273911),
    zoom: 22.4746,
  );
  bool nearbyAvailableDriversKeyLoaded = false;
  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        color: Theme.of(context).accentColor,
        width: 230,
        child: Drawer(
          child: DrawerMenu(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap, top: 20),
            mapType: MapType.terrain,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kEldoret,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineset,
            markers: markerSet,
            circles: circleSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newgoogleMapController = controller;
              locatePosition();
            },
          ),
          //menu icon
          Positioned(
            top: 40,
            left: 15,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Icon(Icons.menu, size: 38),
            ),
          ),
          //reset app icon
          Positioned(
            top: 100,
            left: 15,
            child: GestureDetector(
              onTap: () {
                resetApp();
              },
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor,
                        blurRadius: 7,
                        spreadRadius: 0.7,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.close, color: Colors.black),
                      radius: 20)),
            ),
          ),
          //hide menu button
          Positioned(
            bottom: 0,
            left: 30,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceInOut,
              duration: new Duration(milliseconds: 600),
                          child: Padding(
                padding: EdgeInsets.only(bottom: searchContainerHeight),
                child: GestureDetector(
                  onTap: () {
                    if (searchContainerHeight == 30) {
                      setState(() {
                        searchContainerHeight = 225;
                        bottomPaddingOfMap = 230;
                        // bottomPaddingOfBottomMenuOpenAction = 230;
                        dropUpIcon = Icon(Icons.arrow_drop_down,
                            color: Colors.white, size: 28);
                      });
                    } else {
                      setState(() {
                        searchContainerHeight = 30;
                        bottomPaddingOfMap = 40;
                        // bottomPaddingOfBottomMenuOpenAction = 0;
                        dropUpIcon = Icon(Icons.arrow_drop_up,
                            color: Colors.white, size: 28);
                      });
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18)),
                    ),
                    child: dropUpIcon,
                  ),
                ),
              ),
            ),
          ),
          //bottom helper menu
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.linearToEaseOut,
              duration: new Duration(milliseconds: 600),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Theme.of(context).primaryColor,
                  //     blurRadius: 10,
                  //     spreadRadius: 0.7,
                  //     offset: Offset(0.7, 0.7),
                  //   ),
                  // ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 8),
                      // Text(
                      //   "Hello",
                      //   style: TextStyle(
                      //       fontSize: 22,
                      //       color: Theme.of(context).primaryColor),
                      // ),
                      SizedBox(height: 8),
                      Text(
                        "Where are you going?",
                        style: TextStyle(
                            fontSize: 25,
                            fontFamily: "Brand Bold",
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 18),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black,
                            //     blurRadius: 2,
                            //     spreadRadius: 0.5,
                            //     offset: Offset(0.5, 0.5),
                            //   ),
                            // ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.0),
                                height: 50,
                                child: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(width: 30),
                              Text(
                                "search drop off",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.home,
                                // color: Theme.of(context).primaryColor,
                                size: 45,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Provider.of<AppData>(context)
                                                .pickUpLocation !=
                                            null
                                        ? Provider.of<AppData>(context)
                                            .pickUpLocation
                                            .placeName
                                        : "Add Home",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Your current address",
                                    style: TextStyle(
                                        // color: Theme.of(context).primaryCRolor,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // SizedBox(height: 10),
                          // DividerWidget(),
                          // SizedBox(height: 10),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       Icons.work,
                          //       color: Theme.of(context).primaryColor,
                          //     ),
                          //     SizedBox(
                          //       width: 12,
                          //     ),
                          //     Text(
                          //       "Your work address",
                          //       style: TextStyle(
                          //         color: Theme.of(context).primaryColor,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //car booking menu
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Theme.of(context).primaryColor,
                  //     blurRadius: 16,
                  //     spreadRadius: 0.5,
                  //     offset: Offset(0.7, 0.7),
                  //   ),
                  // ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Theme.of(context).accentColor,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Image.asset("assets/images/car_android.png",
                                  height: 70, width: 80),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Car",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: "Brand Bold")),
                                  Text(
                                      ((tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : ''),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontFamily: "Brand Bold")),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails != null)
                                    ? '\KSH${AssistantMethods.calculateFares(tripDirectionDetails)}'
                                    : ''),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 16),
                      //   child: Row(
                      //     children: [
                      //       Icon(FontAwesomeIcons.moneyBillAlt,
                      //           size: 13, color: Colors.black54),
                      //       SizedBox(width: 6),
                      //       Text("Cash"),
                      //       SizedBox(width: 6),
                      //       Icon(Icons.keyboard_arrow_down,
                      //           color: Colors.black54, size: 16),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: RaisedButton(
                            onPressed: () {
                              // displayRequestRideContainer();
                              displayPaymentsContainer();
                            },
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "confirm",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  // Icon(FontAwesomeIcons.taxi,
                                  //     color: Colors.white, size: 18),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //payment container menu
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: paymentContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 60,
                          color: selectedpaymentbackgroundcolor,
                          child: RaisedButton(
                              color: mpesaPayment
                                  ? selectedpaymentbackgroundcolor
                                  : Colors.white,
                              onPressed: () {
                                setState(() {
                                  cashPayment = false;
                                  mpesaPayment = true;
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.phone_android),
                                  Text("mpesa", style: TextStyle(fontSize: 20),),
                                ],
                              )),
                        ),
                        SizedBox(width: 20),
                        Container(
                          width: 120,
                          height: 60,
                          color: selectedpaymentbackgroundcolor,
                          child: RaisedButton(
                              color: cashPayment
                                  ? selectedpaymentbackgroundcolor
                                  : Colors.white,
                              onPressed: () {
                                setState(() {
                                  mpesaPayment = false;
                                  cashPayment = true;
                                });
                              },
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(FontAwesomeIcons.moneyBill),
                                  ),
                                  Text("cash", style: TextStyle(fontSize: 20)),
                                ],
                              )),
                        )
                      ],
                    ),
                    SizedBox(height: 50),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          displayRequestRideContainer();
                        },
                        child: Text(
                          cashPayment
                              ? "pay with cash"
                              : "pay with mpesa",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //getting driver loading widget
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              height: requestRideContainerHeight,
              decoration: BoxDecoration(color: Colors.white,
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(16),
                  //   topRight: Radius.circular(16),
                  // ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor,
                        spreadRadius: 0.5,
                        blurRadius: 50,
                        offset: Offset(0.7, 0.7))
                  ]),
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Getting nearest driver",
                            style: TextStyle(fontSize: 24)),
                        SizedBox(width: 50),
                        GestureDetector(
                          onTap: () {
                            cancelRideRequest();
                            // resetApp();
                          },
                          child: Icon(Icons.close, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "please wait...",
      ),
    );
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);
    print("this is encoded point ::");
    print(details.encodedPoints);
    PolylinePoints polyLinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polyLinePoints.decodePolyline(details.encodedPoints);
    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineset.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("PolylineID"),
        color: Theme.of(context).primaryColor,
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        geodesic: true,
      );
      polylineset.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newgoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "destination"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "destination"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );
    setState(() {
      markerSet.add(pickUpLocMarker);
      markerSet.add(dropOffLocMarker);
    });
    Circle pickUpLocCircle = Circle(
      circleId: CircleId("pickUpId"),
      fillColor: Colors.teal[700],
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.teal[700],
    );
    Circle dropOffLocCircle = Circle(
      circleId: CircleId("dropOffId"),
      fillColor: Colors.red[100],
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.red[100],
    );
    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropOffLocCircle);
    });
  }

  void initGeofireListner() {
    Geofire.initialize("availableDrivers");
    //comment
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 30)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeofireAssistant.nearbyAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriversKeyLoaded == true) {
              updateAvailableDriverOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeofireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriverOnMap();

            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeofireAssistant.updateNearbyDriverLocation(nearbyAvailableDrivers);
            updateAvailableDriverOnMap();

            // Update your key's location
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriverOnMap();
            // All Intial Data is loaded
            break;
        }
      }

      setState(() {});
    });
    //comment
  }

  void updateAvailableDriverOnMap() {
    setState(() {
      markerSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeofireAssistant.nearbyAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude, driver.longitude);
      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvailablePosition,
        icon: nearbyIcon,
        rotation: AssistantMethods.createRandomNumber(360),
      );
      tMarkers.add(marker);
    }
    setState(() {
      markerSet = tMarkers;
    });
  }

  void createIconMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/taxi-2.png")
          .then((value) {
        nearbyIcon = value;
      });
    }
  }
}
