import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:momo_vn/momo_vn.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MomoVn _momoPay;
  late PaymentResponse _momoPaymentResult;
  final TextEditingController partnerCodeController = TextEditingController();
  final TextEditingController partnerNameController = TextEditingController();
  final TextEditingController orderInfoController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  // ignore: non_constant_identifier_names
  late String _paymentStatus;
  static String payUrl = "";

  @override
  void initState() {
    super.initState();
    _momoPay = MomoVn();
    _momoPay.on(MomoVn.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _momoPay.on(MomoVn.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _paymentStatus = "";
    initPlatformState();
  }
  Future<void> initPlatformState() async {
    if (!mounted) return;
    setState(() {
    });
  }
  Future<dynamic> postCreate(String partnerCode, String partnerName,
      String orderId, String orderInfo, String signature) async {
    const url = 'https://test-payment.momo.vn/v2/gateway/api/create';

    final msg = jsonEncode({
      "partnerCode": partnerCode,
      "partnerName": partnerName,
      "storeId": partnerCode,
      "requestType": "captureWallet",
      "ipnUrl": "https://momo.vn",
      "redirectUrl": "https://momo.vn",
      "orderId": orderId,
      "amount": 150000,
      "lang": "vi",
      "orderInfo": orderInfo,
      "requestId": orderId,
      "extraData": "",
      "signature": signature
    });
    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: msg);
    print(response.body);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      payUrl = json['payUrl'];
      print(json['payUrl']);
      return json;
    } else {
      //throw HttpRequestException();
      throw 'loi';
    }
  }

  @override
  Widget build(BuildContext context) {
    partnerCodeController.text = 'MOMOIR9N20211104';
    partnerNameController.text = 'Công ty cổ phần Hosco Việt Nam';
    orderInfoController.text = '1-DHB.CNT.170225';
    orderIdController.text = '1-DHB.CNT.170225';
    String accessKey = 'EX38Eckrco16SEnE';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('THANH TOÁN QUA ỨNG DỤNG MOMO'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Column(
                children: [
                  TextField(
                    controller: partnerCodeController,
                    decoration: InputDecoration(labelText: 'Partnercode'),
                  ),
                  TextField(
                    controller: partnerNameController,
                    decoration: InputDecoration(labelText: 'PartnerName'),
                  ),
                  TextField(
                    controller: orderInfoController,
                    decoration: InputDecoration(labelText: 'orderInfo'),
                  ),
                  TextField(
                    controller: orderIdController,
                    decoration: InputDecoration(labelText: 'orderId'),
                  ),
                  FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(8.0),
                    splashColor: Colors.blueAccent,
                    child: Text('DEMO PAYMENT WITH MOMO.VN'),
                    onPressed: () async {
                      // MomoPaymentInfo options = MomoPaymentInfo(
                      //     merchantName: "Công ty cổ phần Hosco Việt Nam",
                      //     appScheme: "momoir9n20211104",
                      //     merchantCode: 'MOMOIR9N20211104',
                      //     partnerCode: 'MOMOIR9N20211104',
                      //     amount: 60000,
                      //     orderId: '12321312',
                      //     orderLabel: '1-DHB.CNT.170222',
                      //     merchantNameLabel: "Hosco Mua Hàng",
                      //     fee: 0,
                      //     description: '1-DHB.CNT.170222',
                      //     username: 'Hosco',
                      //     partner: 'merchant',
                      //     extra: "{\"Name\":\"Hosco\",\"Giá tiền\":\"60000\"}",
                      //     isTestMode: true
                      // );
                      // try {
                      //   _momoPay.open(options);
                      // } catch (e) {
                      //   debugPrint(e.toString());
                      // }
                      var signature =
                          "accessKey=$accessKey&amount=150000&extraData=&ipnUrl=https://momo.vn&orderId=" +
                              orderIdController.text +
                              "&orderInfo=" +
                              orderInfoController.text +
                              "&partnerCode=" +
                              partnerCodeController.text +
                              "&redirectUrl=https://momo.vn&requestId=" +
                              orderIdController.text +
                              "&requestType=captureWallet";
                      var key = utf8.encode("1ZLd2kzBhL3lEVJcVxx59pl5QJ5I7ZTn");
                      var data = utf8.encode(signature);
                      var hmacSha256 = Hmac(sha256, key);
                      var digest = hmacSha256.convert(data);
                      postCreate(
                          partnerCodeController.text,
                          partnerNameController.text,
                          orderIdController.text,
                          orderInfoController.text,
                          digest.toString());
                      print(signature);
                      print(digest.toString());
                      print('Url'+payUrl);
                      // print(signature);
                      // print(partnerCodeController.text);
                      // print(orderInfoController.text);
                      // print(signature);

                      // if (await canLaunch(payUrl)) {
                      //   await launch(payUrl,
                      //     forceSafariVC: true,
                      //     forceWebView: true,
                      //     webOnlyWindowName: '_blank',);
                      // } else {
                      //   throw 'Could not launch $payUrl';
                      // }
                       launch(payUrl,forceWebView: true,webOnlyWindowName: '_blank');

                    },
                  ),
                ],
              ),
              // Text(_paymentStatus.isEmpty ? "CHƯA THANH TOÁN" : _paymentStatus)
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
    _momoPay.clear();
  }
  void _setState() {
    _paymentStatus = 'Đã chuyển thanh toán';
    if (_momoPaymentResult.isSuccess == true) {
      _paymentStatus += "\nTình trạng: Thành công.";
      _paymentStatus += "\nSố điện thoại: " + _momoPaymentResult.phoneNumber.toString();
      _paymentStatus += "\nExtra: " + _momoPaymentResult.extra!;
      _paymentStatus += "\nToken: " + _momoPaymentResult.token.toString();
      _paymentStatus += "\nTrang thai" + _momoPaymentResult.data!;
      _paymentStatus += "\nMã lỗi: " + _momoPaymentResult.status.toString();
    }
    else {
      _paymentStatus += "\nTình trạng: Thất bại.";
      _paymentStatus += "\nExtra: " + _momoPaymentResult.extra.toString();
      _paymentStatus += "\nMã lỗi: " + _momoPaymentResult.status.toString();
    }
  }
  void _handlePaymentSuccess(PaymentResponse response) {
    setState(() {
      _momoPaymentResult = response;
      _setState();
    });
    Fluttertoast.showToast(msg: "THÀNH CÔNG: " + response.phoneNumber.toString(), toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentResponse response) {
    setState(() {
      _momoPaymentResult = response;
      _setState();
    });
    Fluttertoast.showToast(msg: "THẤT BẠI: " + response.message.toString(), toastLength: Toast.LENGTH_SHORT);
  }
}