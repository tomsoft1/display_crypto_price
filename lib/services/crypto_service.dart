import 'package:http/http.dart' as http;
import 'dart:convert';

class CryptoService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  static const String _corsProxy = 'https://cors-anywhere.herokuapp.com/';

  Future<List<Map<String, dynamic>>> getCryptoList() async {
    final response = await http.get(Uri.parse(
        '$_corsProxy$_baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map((crypto) => {
                'id': crypto['id'],
                'name': crypto['name'],
                'image': crypto['image'],
              })
          .toList()
          .cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load crypto list: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getCryptoPrices(
      String cryptoId, String duration) async {
    final response = await http.get(Uri.parse(
        '$_corsProxy$_baseUrl/coins/$cryptoId/market_chart?vs_currency=usd&days=$duration'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load price data: ${response.statusCode}');
    }
  }
}
