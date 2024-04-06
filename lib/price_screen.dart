import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'coin_data.dart';
import 'dart:io' show Platform;

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String? selectedCurrency = 'USD';
  int rateToBTC = 0;
  int rateToETH = 0;
  int rateToLTC = 0;
  CoinData coinData = CoinData();

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in currenciesList) {
      var newItem = DropdownMenuItem(value: currency, child: Text(currency));
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropdownItems,
      onChanged: (value) async {
        selectedCurrency = value;
        List<dynamic> coinBatch = [];
        var futures = <Future>[
          coinData.getCoinData('BTC', selectedCurrency),
          coinData.getCoinData('ETH', selectedCurrency),
          coinData.getCoinData('LTC', selectedCurrency),
        ];

        coinBatch = await Future.wait(futures);

        updateUI(coinBatch);
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Widget> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(Center(
        child: Text(currency),
      ));
    }
    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) async {
        selectedCurrency = currenciesList[selectedIndex];
        List<dynamic> coinBatch = [];
        var futures = <Future>[
          coinData.getCoinData('BTC', selectedCurrency),
          coinData.getCoinData('ETH', selectedCurrency),
          coinData.getCoinData('LTC', selectedCurrency),
        ];

        coinBatch = await Future.wait(futures);
        updateUI(coinBatch);
      },
      children: pickerItems,
    );
  }

  void updateUI(List<dynamic> coinData) {
    setState(() {
      for (dynamic coin in coinData) {
        if (coin != null) {
          if (coin['asset_id_base'] == 'BTC') {
            rateToBTC = coin['rate'].toInt();
          } else if (coin['asset_id_base'] == 'ETH') {
            rateToETH = coin['rate'].toInt();
          } else {
            rateToLTC = coin['rate'].toInt();
          }
        }
      }
    });
  }

  List<Widget> cryptoItems() {
    List<Widget> cryptos = [];
    List<int> cryptoRates = [rateToBTC, rateToETH, rateToLTC];
    for (int i = 0; i < cryptoList.length; i++) {
      String crypto = cryptoList[i];
      int rateToCrypto = cryptoRates[i];
      Widget newItem = Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $crypto = $rateToCrypto $selectedCurrency',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      );
      cryptos.add(newItem);
    }
    return cryptos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // rateToBTC
          Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
              child: Column(
                children: cryptoItems(),
              )),
          Container(
              height: 150.0,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 30.0),
              color: Colors.lightBlue,
              child: Platform.isIOS ? iOSPicker() : androidDropdown())
        ],
      ),
    );
  }
}