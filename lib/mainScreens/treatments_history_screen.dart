import 'package:flutter/material.dart';

import 'package:provider/provider.dart';


import '../infoHandler/app_info.dart';
import '../widgets/history_design_ui.dart';



class TreatmentsHistoryScreen extends StatefulWidget
{
  const TreatmentsHistoryScreen({super.key});

  @override
  State<TreatmentsHistoryScreen> createState() => _TreatmentsHistoryScreenState();
}

class _TreatmentsHistoryScreenState extends State<TreatmentsHistoryScreen>
{



  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Treatments History"
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: ()
          {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, i)=> const Divider(
          color: Colors.blue,
          thickness: 2,
          height: 2,
        ),
        itemBuilder: (context, i)
        {
          return Card(
            color: Colors.white,
            child: HistoryDesignUIWidget(
              treatmentsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTreatmentsHistoryInformationList[i],
            ),
          );
        },
        itemCount: Provider.of<AppInfo>(context, listen: false).allTreatmentsHistoryInformationList.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
