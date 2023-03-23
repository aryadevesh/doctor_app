import 'package:doctor_app/tabPages/earning_tab.dart';
import 'package:doctor_app/tabPages/home_tab.dart';
import 'package:doctor_app/tabPages/profile_tab.dart';
import 'package:doctor_app/tabPages/ratings_tab.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget
{
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin
{
  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;

    });
  }
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    tabController = TabController(length: 4, vsync: this);
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: TabBarView(
        physics:const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          HomeTabPage(),
          EarningsTabPage(),
          RatingsTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [

          BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Treatments",
        ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "Ratings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
