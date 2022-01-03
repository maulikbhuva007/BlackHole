import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blackhole/APIs/api.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/model/subscription_status_response.dart';
import 'package:blackhole/util/const.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import '../splash_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isLoading = false;
  List<IAPItem> products = [];
  late StreamSubscription<dynamic> _subscription;
  List<String> lstStr = [
    'A personal library for your favourite music Simple tools to create your own yoga playlist',
    'Largest selection of yoga music from artists around the world.',
    "Curated playlists by top global yoga dj's",
    'Offline streaming',
    'Ad free',
    'High quality audio',
    'Performance rights',
  ];

  List<String> lstDescription = [
    'YogiTunes will enable an auto-renewing subscription, with the following standard iTunes terms:',
    '· Payment will be charged to iTunes Account at confirmation of purchase.',
    '· Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
    '· Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal.',
    "· Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase.",
    '· Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.'
  ];
  late Map<String, dynamic> argument;
  bool isFirstTime = false;
  StreamSubscription? purchaseUpdatedSubscription;
  StreamSubscription? purchaseErrorSubscription;
  bool buttonLoading = false;
  @override
  void initState() {
    asyncInitState();

    super.initState();
  }

  void asyncInitState() async {
    await FlutterInappPurchase.instance.initialize();
    fetchDate();
  }

  Future<void> fetchDate() async {
    setState(() {
      isLoading = true;
    });
    // final Stream purchaseUpdated = FlutterInappPurchase.instance.purchaseStream;
    // _subscription = purchaseUpdated.listen((purchaseDetailsList) {
    //   _listenToPurchaseUpdated(List<PurchaseDetails>.from(
    //       List.from(purchaseDetailsList as Iterable<dynamic>)));
    // }, onDone: () {
    //   _subscription.cancel();
    // }, onError: (error) {
    //   // handle error here.
    // });

    ///=========

    List<IAPItem> items =
        await FlutterInappPurchase.instance.getSubscriptions(Platform.isIOS
            ? [
                iosInAppPackage,
              ]
            : [
                androidInAppPackage,
              ]);
    debugPrint("items  ::  ${items}");
    for (final item in items) {
      products.add(item);
    }
    // final ProductDetailsResponse response =
    //     await InAppPurchase.instance.queryProductDetails(_kIds);
    // await Future.delayed(const Duration(seconds: 2));
    // if (response.notFoundIDs.isNotEmpty) {
    //   // Handle the error.
    //   debugPrint("Error ");
    // }
    // products = response.productDetails;
    // if (products.isNotEmpty) {
    //   debugPrint(products[0].price);
    // }
    // debugPrint("products :: " + products.length.toString());
    purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) async {
      debugPrint('purchase-updated: $productItem');
      if (productItem != null) {
        String dateStr =
            '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
        final SubscriptionStatusResponse? paymentSuccessResponse =
            await YogitunesAPI().paymentSuccess(
          subscriptionId:
              Platform.isIOS ? iosInAppPackage : androidInAppPackage,
          paymentDate: productItem.transactionDate!.toIso8601String(),
          paymentId: '0${productItem.transactionId}',
          paymentToken: productItem.transactionReceipt.toString(),
        );

        if (paymentSuccessResponse != null) {
          if (paymentSuccessResponse.status!) {
            redirectAfterAuthentication(context);
          } else {
            ShowSnackBar()
                .showSnackBar(context, paymentSuccessResponse.message!);
          }
        }
      }
      setState(() {
        buttonLoading = false;
      });
    });

    purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      debugPrint('purchase-error: $purchaseError');
      setState(() {
        buttonLoading = false;
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    FlutterInappPurchase.instance.finalize();
    if (purchaseUpdatedSubscription != null) {
      purchaseUpdatedSubscription!.cancel();
    }
    if (purchaseErrorSubscription != null) {
      purchaseErrorSubscription!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final objargument = ModalRoute.of(context)!.settings.arguments;
    if (objargument != null) {
      argument = objargument as Map<String, dynamic>;
      if (argument['isFirstTime'] is bool) {
        final bool isFtime = argument['isFirstTime'] as bool;
        if (isFtime) {
          isFirstTime = isFtime;
        }
      }
    }
    return SafeArea(
      child: GradientContainer(
        child: Scaffold(
          appBar: AppBar(
            leading: isFirstTime ? Container() : null,
            title: Text("Subscription"),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lstStr.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check, color: Colors.green),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      lstStr[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lstDescription.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                lstDescription[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                        // if (products.isNotEmpty)
                        //   Text(
                        //     jsonDecode(products[0].originalJson!)['price']
                        //         .toString(),
                        //     style: TextStyle(
                        //       fontSize: 22,
                        //       fontWeight: FontWeight.bold,
                        //       color: Theme.of(context).colorScheme.secondary,
                        //     ),
                        //   ),
                        SizedBox(
                          height: 20,
                        ),
                        if (products.isNotEmpty)
                          Text(
                            'You will be charges at ${products[0].localizedPrice.toString()}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        SizedBox(
                          height: 20,
                        ),
                        if (products.isNotEmpty)
                          if (buttonLoading)
                            CircularProgressIndicator()
                          else
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  buttonLoading = true;
                                });
                                FlutterInappPurchase.instance
                                    .requestPurchase(products[0].productId!);
                                // final PurchaseParam purchaseParam =
                                //     PurchaseParam(productDetails: products[0]);

                                // InAppPurchase.instance
                                //     .buyNonConsumable(purchaseParam: purchaseParam);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: Center(
                                  child: Text(
                                    'Subscribe',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  //   purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
  //     if (purchaseDetails.status == PurchaseStatus.pending) {
  //       // _showPendingUI();
  //     } else {
  //       if (purchaseDetails.status == PurchaseStatus.error) {
  //         // _handleError(purchaseDetails.error!);
  //       } else if (purchaseDetails.status == PurchaseStatus.purchased ||
  //           purchaseDetails.status == PurchaseStatus.restored) {
  //         bool valid = await _verifyPurchase(purchaseDetails) as bool;
  //         if (valid) {
  //           // _deliverProduct(purchaseDetails);
  //         } else {
  //           // _handleInvalidPurchase(purchaseDetails);
  //         }
  //       }
  //       if (purchaseDetails.pendingCompletePurchase) {
  //         await InAppPurchase.instance.completePurchase(purchaseDetails);
  //       }
  //     }
  //   });
  // }

  // Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
  //   // IMPORTANT!! Always verify a purchase before delivering the product.
  //   // For the purpose of an example, we directly return true.
  //   return Future<bool>.value(true);
  // }
}
