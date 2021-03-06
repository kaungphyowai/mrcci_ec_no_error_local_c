import 'dart:ui';
import 'Dashboard_Components/Currency_Exchange_Rate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mrcci_ec/constants/loading.dart';
import '../../../firebase services/authservices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Dashboard_Components/DashBoard_Functions.dart';
import 'Dashboard_Components/Upcoming_Meetings.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var currencyData;
  var rates;
  bool loading = false;
  var userInfo;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  List<dynamic> upcomingMeetings = [];
  List<dynamic> upcomingEvents = null;
  Auth _auth = Auth();

  CollectionReference meetings =
      FirebaseFirestore.instance.collection('meetings');
  CollectionReference events = FirebaseFirestore.instance.collection('events');
  Future getCurrency() async {
    try {
      Response response =
          await Dio().get('https://forex.cbm.gov.mm/api/latest');
      currencyData = response.data;
      rates = currencyData['rates'];
    } catch (e) {
      print(e.message);
    }
  }

  Future getuserinfo() async {
    // final uid = firebaseAuth.currentUser.uid;
    // userinfo = await firestoreService.getCurrentUserInfo(uid);
    // userinfo = userinfo.data().length;
    // //print(userinfo);
    // return uid;
    final uid = firebaseAuth.currentUser.uid;
    print(uid);
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('userProfiles')
        .doc(uid)
        .get();
    userInfo = user.data();

    //print(userInfo['role']);

    //print('userInfo ${userInfo}');
    return userInfo;
  }

  @override
  Widget build(BuildContext context) {
    getuserinfo();
    //getCurrency();
    List<String> upcomingSevenDays = get_upcoming_seven_days();
    return ListView(
      children: [
        FutureBuilder(
          future: getCurrency(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            } else {
              return Currency_Exchange_Rate(rates: rates);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The Upcoming Meetings For You',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: getuserinfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return StreamBuilder<QuerySnapshot>(
                stream: meetings.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingIndicator();
                  }
                  if (snapshot.connectionState == ConnectionState.active) {
                    upcomingMeetings = getUpcomingMeetings(
                        snapshot: snapshot,
                        userInfo: userInfo,
                        upcomingSevenDays: upcomingSevenDays);

                    if (upcomingMeetings.isNotEmpty) {
                      return Upcoming_Meetings(
                          upcomingMeetings: upcomingMeetings);
                    } else {
                      return Text('There is No upcoming Meetings');
                    }
                  }
                },
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The Upcoming Events For You',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: events.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.connectionState == ConnectionState.active) {
              upcomingEvents = getUpcomingEvents(
                  snapshot: snapshot, upcomingSevenDays: upcomingSevenDays);

              if (upcomingEvents.isNotEmpty) {
                print('UpcomingEvents Exist');
                return Upcoming_Meetings(upcomingMeetings: upcomingEvents);
              } else {
                return Text('There is No upcoming Events');
              }
            }
          },
        ),
      ],
    );
  }
}
