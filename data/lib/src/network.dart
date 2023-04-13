import 'package:data/data.dart';
import 'package:dio/dio.dart';

class Network {
  late final String baseUrl;
  late final Dio dio;
  late final Map<String, String> _headers;
  final Messages _messages;
  //if you are using android studio emulator, change localhost to 10.0.2.2

  Network(String url, String? token, this._messages) {
    baseUrl = url;
    BaseOptions options = BaseOptions(baseUrl: baseUrl);
    dio = Dio(options);
    _headers = token != null ? _setHeadersWithToken(token) : _setHeaders();
  }

  _setHeadersWithToken(String token) => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
  Future<NetworkResponse> postData(url, data,
      {Map<String, String>? headers}) async {
    try {
      headers ??= {};
      _headers.forEach((key, value) {
        if (!headers!.containsKey(key)) {
          headers[key] = value;
        }
      });
      Response response =
          await dio.post(url, data: data, options: Options(headers: headers));
      return NetworkResponse.fromFromResponse(this, response);
    } catch (e) {
      return NetworkResponse.fromException(this, e);
    }
  }
}

class NetworkResponse {
  bool success;
  String message;
  Response<dynamic>? response;
  dynamic data;

  /* String getMessage(){
    return message;
  }*/

  NetworkResponse.fromFromResponse(Network network, Response this.response,
      [String? defaultText])
      : success = false,
        message = "",
        data = <String, dynamic>{} {
    if (response != null) {
      switch (response?.statusCode) {
        case 200: // success, foundif (response?.data != null &&
          if (response!.data is Map<String, dynamic> &&
              response?.data.containsKey('success')) {
            success = response!.data['success'] == true;
          } else {
            success = false;
          }
          if (response!.data is Map<String, dynamic> &&
              response?.data.containsKey('data')) {
            data = response!.data['data'];
          }
          if (response!.data is Map<String, dynamic> &&
              response?.data.containsKey('message')) {
            message = response!.data['message'];
          }
          break;
        case 204: // sucess, no content
          success = false;
          break;
      }
    }
    if (defaultText != null) {
      message = defaultText;
    }
  }

  NetworkResponse.fromException(Network network, exception,
      [String? defaultText])
      : success = false,
        message = "",
        data = <String, dynamic>{} {
    success = false;

    if (exception is DioError) {
      if (exception.response != null) {
        response = exception.response;
        if (response!.data != null) {
          if (response!.data is String) {
            message = response!.data as String;
            return;
          }
          if (response!.data.containsKey('success')) {
            message = response!.data['message'];
            return;
          }
        }
        switch (response?.statusCode) {
          case 401: // unauthorized
            message = network._messages.network.unauthorized;
            break;
          case 403: // forbidden
            message = network._messages.network.forbidden;
            break;
          case 500: // Server error
            message = network._messages.network.servererror;
            break;
          case null:
            switch (exception.type) {
              case DioErrorType.cancel:
                message = network._messages.network.canceled;
                break;
              case DioErrorType.receiveTimeout:
              case DioErrorType.sendTimeout:
              case DioErrorType.badResponse:
                message = network._messages.network.error;
                break;
              case DioErrorType.connectionTimeout:
              case DioErrorType.connectionError:
                message = network._messages.network.errorconnect;
                break;
              case DioErrorType.badCertificate:
                message = network._messages.network.badCertificate;
                break;
              default:
                message = network._messages.network.unexpected;
                break;
            }
            break;
          default:
            message =
                network._messages.network.httperror(response?.statusCode ?? 0);
            break;
        }
      }
    } else {
      // andere exceptie
      message = network._messages.network.unexpected;
    }
  }
}
