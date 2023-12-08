import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:quran_and_islam/controller/prayer_time_controller.dart';
import 'package:quran_and_islam/controller/time_controller.dart';
import 'package:quran_and_islam/resources/components/app_drawer.dart';
import 'package:quran_and_islam/resources/components/main_category.dart';
import 'package:quran_and_islam/resources/constants/colors.dart';
import 'package:quran_and_islam/view/about_islam_view.dart';
import 'package:quran_and_islam/view/view_lists/arabic_to_english_surah_list.dart';
import 'package:quran_and_islam/view/calender_view.dart';
import 'package:quran_and_islam/view/hijri_calender.dart';
import 'package:quran_and_islam/view/view_lists/color_coded_surah_list.dart';
import 'package:quran_and_islam/view/view_lists/duas_list.dart';
import 'package:quran_and_islam/view/view_lists/only_arabic_surah_list.dart';
import 'package:quran_and_islam/view/salah_timing_view.dart';
import 'package:quran_and_islam/view/surah_by_surah_audio_view.dart';
import 'package:quran_and_islam/view/view_lists/word_by_word_surah_list.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../resources/components/prayer_container.dart';
import '../resources/constants/my_text_style.dart';
import '../resources/prayer_names.dart';
import 'english_only_quran.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  var location = Location();
  String currentCity = "Peshawar";

  var data;
  final DateTime _currentTime = DateTime.now();

  ///Getx controllers
  final timeController = Get.put(TimeController());
  final prayerTimeController = Get.put(PrayerTimeController());
  final prayerScroller = ItemScrollController();

  ///Method to get salah timings from API
  Future<void> getSalahTimings() async {
    final response = await http.get(Uri.parse(
        'https://muslimsalat.com/$currentCity.json?key=b5d2a83a49d376f6d991fb308f513559%22'));
    if (response.statusCode == 200) {
      data = jsonDecode(response.body.toString());
      return data;
    } else {
      debugPrint('\n\nSomething went wrong\n');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSalahTimings();
    _getLocationAndCityName();
  }

  ///Method to get only city name of user from its current location
  Future<void> _getLocationAndCityName() async {
    try {
      var locationData = await location.getLocation();
      List<gc.Placemark> placemarks = await gc.placemarkFromCoordinates(
        locationData.latitude!.toDouble(),
        locationData.longitude!.toDouble(),
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          currentCity = placemarks[0].locality!;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.now();
    final todayHijri = hijri.toFormat('MMMM dd yyyy');
    final dateFormat = DateFormat.yMMMEd();
    final currentDate = dateFormat.format(_currentTime);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Quran & Islam',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        backgroundColor: appBarColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: bgColor,
          child: Column(
            children: [

              ///Image of quran
              Container(
                height: 190.h,
                alignment: Alignment.center,
                width: double.infinity,
                decoration: const BoxDecoration(
                    border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.black, width: 1))),
                child: Image.asset(
                  'assets/images/quran_home.jpg',
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
              ),

              ///Column below image of quran
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: blueLightColor,
                      ),
                      height: 112.h,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            ///Calender image
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const CalenderView());
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 90.h,
                                width: 70.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: blueColor, width: 2.sp),
                                ),
                                child: Card(
                                  elevation: 10,
                                  color: whiteColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Image.asset(
                                      'assets/icons/my_calender.png',
                                      height: 50.h,
                                      width: 45.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            ///SizedBox
                            SizedBox(
                              width: 5.w,
                            ),

                            ///Current city/current time/current date
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                ///Name of current city
                                Container(
                                  alignment: Alignment.center,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    color: blackColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      currentCity.toString(),
                                      style: whiteStyle(size: 13.sp),
                                    ),
                                  ),
                                ),

                                ///Current time update using Getx
                                Obx(
                                  () => Text(
                                      DateFormat('h:mm a').format(
                                          timeController.currentTime.value),
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                ),

                                ///Today hijri date
                                SizedBox(
                                  width: 135.w,
                                  height: 27.h,
                                  child: Text(todayHijri.toString(),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12.sp, color: blackColor)),
                                ),

                                ///Current Date
                                Text(currentDate,
                                    style: TextStyle(
                                        fontSize: 13.sp, color: blackColor)),
                              ],
                            ),

                            ///Vertical divider
                            const VerticalDivider(
                              color: Colors.white,
                              thickness: 1,
                            ),

                            ///Displaying daily prayer times of a city using FutureBuilder
                            SizedBox(
                              height: 90.h,
                              width: 95.w,
                              child: FutureBuilder(
                                  future: getSalahTimings(),
                                  builder: ((context, snapshot) {
                                    if (snapshot.hasData) {
                                      List<String> prayerTimes = [
                                        data['items'][0]['fajr'],
                                        data['items'][0]['shurooq'],
                                        data['items'][0]['dhuhr'],
                                        data['items'][0]['asr'],
                                        data['items'][0]['maghrib'],
                                        data['items'][0]['isha']
                                      ];
                                      return ListView.builder(
                                          itemCount: prayerNames.length,
                                          itemBuilder: ((context, index) {
                                            return Obx(
                                              ///Visible only current index widget
                                              () => Visibility(
                                                visible: index ==
                                                    prayerTimeController
                                                        .currentIndex.value,
                                                child: PrayerContainer(
                                                  prayerName:
                                                      prayerNames[index],
                                                  prayerTime:
                                                      prayerTimes[index],
                                                  prayerBgColor: index == 1
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                            );
                                          }));
                                    } else {
                                      return ListView.builder(
                                          itemCount: prayerNames.length,
                                          itemBuilder: ((context, index) {
                                            return Obx(
                                              ///Visible only current index widget
                                              () => Visibility(
                                                visible: index ==
                                                    prayerTimeController
                                                        .currentIndex.value,
                                                child: PrayerContainer(
                                                  prayerName:
                                                      prayerNames[index],
                                                  prayerTime:
                                                      prayerTimesOffline[index],
                                                  prayerBgColor: index == 1
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                            );
                                          }));
                                    }
                                  })),
                            ),
                          ],
                        ),
                      ),
                    ),

                    ///SizedBox
                    SizedBox(
                      height: 3.h,
                    ),

                    ///Row1 containing 3 main components of home screen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MainCategory(
                            title: "القرآن / Quran",
                            onTap: () {
                              Get.to(() => const ArabicToEnglishSurahList());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/noble_quran.png',
                            subtitle: 'Arabic / English'),
                        MainCategory(
                            title: 'القرآن',
                            onTap: () {
                              Get.to(() => const OnlyArabicSurahList());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/arabic_q.png',
                            subtitle: 'Arabic Only'),
                        MainCategory(
                            title: 'القرآن',
                            onTap: () {
                              Get.to(() => const ColorCodedSurahList());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/color_coded_quran.png',
                            subtitle: 'Color Coded'),
                      ],
                    ),

                    ///SizedBox
                    SizedBox(
                      height: 3.h,
                    ),

                    ///Row2 containing 3 main components of home screen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MainCategory(
                            title: 'Quran',
                            onTap: () {
                              Get.to(() => const EnglishOnlyQuran());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/english_only.png',
                            subtitle: 'English Only'),
                        MainCategory(
                            title: 'Noble Quran',
                            onTap: () {
                              Get.to(() => const WordByWordSurahList());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/quran_meaning.png',
                            subtitle: 'Word-meanings'),
                        MainCategory(
                            title: 'Islamic Dua\'s ',
                            onTap: () {
                              Get.to(() => const DuasListView());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/dua_hands.png',
                            subtitle: 'Arabic / English'),
                      ],
                    ),

                    ///SizedBox
                    SizedBox(
                      height: 3.h,
                    ),

                    ///Row3 containing 3 main components of home screen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MainCategory(
                            title: 'Audio Quran',
                            onTap: () {
                              Get.to(() => const SurahBySurahAudio());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/volume.png',
                            subtitle: 'Audio-Only'),
                        MainCategory(
                            title: 'Salah Timings',
                            onTap: () {
                              Get.to(() => const SalahTimings());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/prayer.png',
                            subtitle: ' '),
                        MainCategory(
                            title: 'Islamic Creed',
                            onTap: () {
                              Get.to(() => const AboutIslamView());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/islam_creed.png',
                            subtitle: ' '),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MainCategory(
                            title: 'Hijri Calender',
                            onTap: () {
                              Get.to(() => const HijriCalender());
                            },
                            categoryColor: const Color(0xffffffff),
                            iconUrl: 'assets/icons/date_converter.png',
                            subtitle: ' '),

                      ],
                    ),
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



