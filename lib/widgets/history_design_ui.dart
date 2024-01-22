import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/treatments_history_model.dart';



class HistoryDesignUIWidget extends StatefulWidget
{
  TreatmentsHistoryModel? treatmentsHistoryModel;

  HistoryDesignUIWidget({super.key, this.treatmentsHistoryModel});

  @override
  State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
}




class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget>
{
  String formatDateAndTime(String dateTimeFromDB)
  {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

    // Dec 10                            //2022                         //1:12 pm
    String formattedDatetime = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDatetime;
  }

  @override
  Widget build(BuildContext context)
  {
    return Container(
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //driver name + Fare Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    "Patient : ${widget.treatmentsHistoryModel!.userName!}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12,),

                Text(
                  "\$ ${widget.treatmentsHistoryModel!.base_price!}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2,),

            // car details
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  color: Colors.red,
                  size: 28,
                ),

                const SizedBox(width: 12,),

                Text(
                  widget.treatmentsHistoryModel!.userPhone!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20,),

            //icon + pickup
            Row(
              children: [

                // Image.asset(
                //   "images/origin.png",
                //   height: 26,
                //   width: 26,
                // ),

                const SizedBox(width: 12,),

                Expanded(
                  child: Container(
                    child: Text(
                      widget.treatmentsHistoryModel!.originAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 14,),

            //icon + dropOff
            const Row(
              children: [

                // Image.asset(
                //   "images/destination.png",
                //   height: 24,
                //   width: 24,
                // ),

                SizedBox(width: 12,),

                // Expanded(
                //   child: Text(
                //     widget.treatmentsHistoryModel!.destinationAddress!,
                //     overflow: TextOverflow.ellipsis,
                //     style: const TextStyle(
                //       fontSize: 16,
                //     ),
                //   ),
                // ),

              ],
            ),

            const SizedBox(height: 14,),

            //trip time and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(
                  formatDateAndTime(widget.treatmentsHistoryModel!.time!),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2,),

          ],
        ),
      ),
    );
  }
}
