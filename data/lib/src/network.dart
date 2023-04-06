import 'package:dio/dio.dart';

class Network {
  late final String baseUrl;
  late final Dio dio;
  late final Map<String, String> _headers;
  //if you are using android studio emulator, change localhost to 10.0.2.2

  Network(String url, String? token) {
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
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }
/*  // Login request
  Future<NetworkResponse> authData(data, apiUrl) async {
    try {
      Response response = await dio.post(apiUrl,
          data: data, options: Options(headers: _setHeaders()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }

  // Used to get data to routes where a user is authenticated
  Future<NetworkResponse> getData(apiUrl) async {
    try {
      await _getToken();
      Response response = await dio.get(apiUrl,
          options: Options(headers: _setHeadersWithToken()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }

  // Used to delete data
  Future<NetworkResponse> deleteData(apiUrl) async {
    try {
      await _getToken();
      Response response = await dio.delete(apiUrl,
          options: Options(headers: _setHeadersWithToken()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }

  // Used to send data to routes where a user is authenticated
  Future<NetworkResponse> postData(data, apiUrl) async {
    try {
      await _getToken();
      Response response = await dio.post(apiUrl,
          data: data, options: Options(headers: _setHeadersWithToken()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }

  // Used to send data to routes where a user is authenticated
  Future<NetworkResponse> putData(data, apiUrl) async {
    try {
      await _getToken();
      Response response = await dio.put(apiUrl,
          data: data, options: Options(headers: _setHeadersWithToken()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }

  // Used to send data to routes where a user is not authenticated
  Future<Response<dynamic>> getDownload(String apiUrl) async {
    await _getToken();
    return dio.get(apiUrl,
        options: Options(
            headers: _setHeadersWithToken(), responseType: ResponseType.bytes));
  }
*/
/* Used to send data to routes where a user is not authenticated */ /*
  Future<NetworkResponse> postDataUnauthenticated(data, apiUrl) async {
    try {
      Response response = await dio.post(apiUrl,
          data: data, options: Options(headers: _setHeadersWithToken()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }

  // Request when uploading a file
  Future<NetworkResponse> uploadFile(
      List<int> fileBytes, String url, String fileName) async {
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    try {
      await _getToken();
      Response response = await dio.post(url,
          data: formData, options: Options(headers: _setHeadersWithToken()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }
  // Request when uploading a file
  Future<NetworkResponse> uploadFormData(
       String url, FormData formData) async {
    try {
      await _getToken();
      Response response = await dio.post(url,
          data: formData, options: Options(headers: _setHeadersWithToken()));
      return NetworkResponse.fromFromResponse(response);
    } catch (e) {
      return NetworkResponse.fromException(e);
    }
  }

  _setHeadersWithToken() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  Future<bool> isLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var localString = localStorage.getString('token');
    if (localString != null) {
      return true;
    }
    return false;
  }*/
}

class NetworkResponse {
  bool success;
  String message;
  Response<dynamic>? response;
  dynamic data;

  /* String getMessage(){
    return message;
  }*/

  NetworkResponse.fromFromResponse(Response this.response,
      [String? defaultText])
      : success = false,
        message = "",
        data = <String, dynamic>{} {
    if (response != null) {
      switch (response?.statusCode) {
        case 200: // success, found
          if (response?.data != null &&
              response!.data is Map<String, dynamic> &&
              response?.data.containsKey('data')) {
            data = response?.data['data'];
            message = response?.data['message'];
            success = response?.data['success'] == true;
          } else {
            //    message = response['message'];
            success = false;
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

  NetworkResponse.fromException(exception, [String? defaultText])
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
            message = "U bent niet geautoriseerd voor deze pagina.";
            break;
          case 403: // forbidden
            message = "U heeft geen rechten tot deze functie.";
            break;
          case 422: //
            message = check422Error();
            break;
          case 500: // Server error
            message =
                "Er is een intern probleem opgetreden. Probeer dit later opnieuw. als dit probleem blijft optreden neem contact op met support@opti4.nl";
            break;
          case null:
            message = "Er is een fout opgetreden";
            break;
          default:
            message =
                "Er is een fout opgetreden http:${response?.statusCode ?? 0}";
            break;
        }
      }
      switch (exception.type) {
        case DioErrorType.cancel:
          message = "Afgebroken";
          break;
        case DioErrorType.connectionTimeout:
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
          message = "Netwerk fout";
          break;
        case DioErrorType.connectionError:
        case DioErrorType.badCertificate:
        default:
          message = "Er is een fout opgetreden";
          break;
      }
    } else {
      // andere exceptie
      message = "Er trad een onverwachte fout op";
    }
    if (defaultText != null) {
      message = defaultText;
    }
  }
  String check422Error([String message = "Fout in ingevoerde gegevens"]) {
    /* if (response?.data.containsKey('errors') ?? false) {
      // if (response?.data['errors'].runtimeType == Map<String, dynamic>) {
      Map<String, dynamic> errors = response?.data['errors'];
      if (errors.containsKey('email')) {
        if (errors['email'][0] == "The email has already been taken.") {
          message = "E-mailadres al in gebruik";
        } else if (errors['email'][0] ==
            "These credentials do not match our records.") {
          message = "Incorrecte login";
        }
      }
      //   }
    }*/
    return message;
  }
}
