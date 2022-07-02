import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inno_cart/ticket.dart';
import 'completed_popup_window.dart';
import 'in_progress_popup_window.dart';
import 'see_requests_window.dart';
import '../backend_functions.dart';
import 'waiting_popup_ticket.dart';
import '../UI/Buttons/elevated_button_style.dart';
import '../navigation_bar.dart';
import '../main.dart';
import 'app_bar.dart';

class PageOfShopperOrders extends StatefulWidget {
  const PageOfShopperOrders({Key? key}) : super(key: key);

  @override
  State<PageOfShopperOrders> createState() => PageOfShopperOrdersState();
}

class PageOfShopperOrdersState extends State<PageOfShopperOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
            onHorizontalDragEnd: ((DragEndDetails details) {
              if (details.primaryVelocity! < 0.0) {
                pageUpdate((selectedPage + 1) % 5, context);
              } else if (details.primaryVelocity! > 0.0) {
                pageUpdate((selectedPage + 4) % 5, context);
              }
            }),
            child: Scaffold(
                backgroundColor: Colors.white,
                appBar: const ThisAppBar(),
                bottomNavigationBar: const MainNavigationBar(),
                body: FutureBuilder<List<Widget>>(
                    future: Tickets(context, this).getTickets(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView(children: snapshot.data!);
                      } else {
                        return const Text('Waiting for data');
                      }
                    })))); // This trailing comma makes auto-formatting nicer for build methods.
  }
}

class Tickets {
  late PageOfShopperOrdersState page;

  Tickets(BuildContext context, this.page);

  Future<List<Widget>> getTickets() async {
    Map<String, dynamic> waitingForAcceptHistoryTickets =
        await getTicketHistory(0, 0);
    Map<String, dynamic> inProgressHistoryTickets =
        await getTicketHistory(1, 0);
    Map<String, dynamic> completedHistoryTickets = await getTicketHistory(2, 0);
    List<Widget> listToReturn = [];
    listToReturn.add(generateHeader('Waiting for accept'));
    for (Map<String, dynamic> tokenNote
        in waitingForAcceptHistoryTickets['tickets']) {
      listToReturn.add(createTicketFromData(tokenNote));
    }
    listToReturn.add(generateHeader('In progress'));
    for (Map<String, dynamic> tokenNote
        in inProgressHistoryTickets['tickets']) {
      listToReturn.add(createTicketFromData(tokenNote));
    }
    listToReturn.add(generateHeader('Completed'));
    for (Map<String, dynamic> tokenNote in completedHistoryTickets['tickets']) {
      listToReturn.add(createTicketFromData(tokenNote));
    }
    return listToReturn;
  }

  TicketTMP createTicketFromData(Map<String, dynamic> data) {
    final int type = data['status'] + 1;
    int angelId = -1;
    String buttonText = "See requests";

    if (type == 2) {
      buttonText = "Complete order";
      angelId = data['angel_id'];
    } else {
      buttonText = "Rate Angel";
      angelId = data['angel_id'];
    }

    return TicketTMP(
      type,
      data['ticket_id'],
      angelId,
      data['shopper_id'],
      data['title'],
      data['weight'],
      data['reward'],
      data['description'],
      buttonText,
      page,
    );
  }

  Widget generateHeader(String text) {
    return Container(
        width: 161,
        height: 22,
        margin: const EdgeInsets.only(left: 29, bottom: bottomPadding),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ));
  }
}

class TicketTMP extends StatelessWidget {
  final int type;
  final int ticketId;
  final int shopperId;
  final int angelId;

  final String orderImage = 'assets/images/rolls.jpg';
  final String orderName;
  final double orderWeight;
  final double orderDistance = 100; // OVERRIDE IN MVP V2
  final String orderDate = "23.06.2022"; // OVERRIDE IN MVP V2
  final String orderTime = "14:00";
  final double orderPrice;
  final String buttonText;
  final PageOfShopperOrdersState page;
  final String orderDescription;

  TicketTMP(
      this.type,
      this.ticketId,
      this.angelId,
      this.shopperId,
      this.orderName,
      this.orderWeight,
      this.orderPrice,
      this.orderDescription,
      this.buttonText,
      this.page,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == 1) {
          waitingPopUpTicket(context, this);
        } else if (type == 2) {
          inProgressPopUpTicket(context, this);
        } else {
          completedPopUpTicket(context, this);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: bottomPadding),
        width: 345,
        height: 208,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //PICTURE
                Flexible(
                  flex: 3,
                  child: Container(
                    width: 130,
                    height: 130,
                    color: Colors.blueGrey,
                    margin:
                        const EdgeInsets.only(top: 12, left: 12, bottom: 10),
                    child: Image.asset(
                      orderImage,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                //TICKET INFO
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: Text(
                            orderName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 20),
                          )),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Bag_alt_light.svg',
                            color: Colors.black,
                            width: 24,
                            height: 24,
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(orderWeight.toString())),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Pin_alt_light.svg',
                            color: Colors.black,
                            width: 24,
                            height: 24,
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(orderDistance.toString())),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Time_light.svg',
                            color: Colors.black,
                            width: 24,
                            height: 24,
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(orderTime)),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                      margin: const EdgeInsets.all(12),
                      color: Colors.yellowAccent,
                      padding: const EdgeInsets.all(7),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              orderPrice.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child:
                                SvgPicture.asset('assets/icons/Currency.svg'),
                          ),
                        ],
                      )),
                ),
              ],
            ),
            //Button

            ElevatedButton(
                onPressed: () async {
                  if (type == 1) {
                    seeRequestWindow(page.context, ticketId, page);
                  } else if (type == 2) {
                    if (kDebugMode) {
                      print("BUTTON OF COMPLETING ORDER HAS BEEN PRESSED");
                    }
                    bool result = await completeOrder(ticketId);
                    if (result) {
                      Navigator.of(page.context)
                          .pushReplacementNamed('/ShopperOrders');
                    }
                  }
                  //onButtonPress();
                },
                style: roundedWhite,
                child: SizedBox(
                  width: 150,
                  height: 32,
                  child: TextAndArrowButtonChild(buttonText: buttonText),
                )),
          ],
        ),
      ),
    );
  }
}
