import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../constants.dart';
import '../../classes/app/paging.dart';
import '../../classes/general/search.dart';
import '../../classes/unify/response.dart';
import '../../models/auth_model.dart';
import '../../web_client.dart';
import '../../classes/contacts/contact_details.dart';
import '../../../utils/null_or_empty.dart';

class ContactRepository {
  final WebClient webClient;

  const ContactRepository({
    this.webClient = const WebClient(),
  });

  Future<ResponseMessage> loadList(AuthModel auth,
      {@required Paging paging, Search search}) async {
    dynamic _response;

    // search = SearchModel(search: "Prospect", filters: [5]);

    // -- Search By Filters --
    if (search != null && search.search.toString().isNotEmpty) {
      final response = await webClient.post(
          kApiUrl + '/search/contacts/${paging.rows}/${paging.page}',
          json.encode(search),
          auth: auth);

      _response = response;
    } else {
      // -- Get List --
      final response = await webClient
          .get(kApiUrl + '/contacts/${paging.rows}/${paging.page}', auth: auth);
      _response = response;
    }

    var result = ResponseMessage.fromJson(_response);

    return result;
  }

  Future<ResponseMessage> getInfo(AuthModel auth, {@required String id}) async {
    dynamic _response;

    // -- Get List --
    final response =
        await webClient.get(kApiUrl + '/contacts/details/$id', auth: auth);
    _response = response;

    var result = ResponseMessage.fromJson(_response);

    return result;
  }

  Future<bool> deleteContact(AuthModel auth, {@required String id}) async {
    var url = kApiUrl + '/contacts/details/' + id.toString();
    var response;
    response = await webClient.delete(url, auth: auth);
    print(response);
    if (response["Status"].toString().contains("Success")) return true;
    return false;
  }

  Future<bool> saveData(AuthModel auth,
      {@required ContactDetails contact, String id}) async {
    var data = contact.toJson();
    print(data);
    var response;

    if (isNullOrEmpty(id)) {
      print("Creating Contact...");
      response = await webClient
          .post(kApiUrl + '/contacts/add', json.encode(data), auth: auth);
      print(response);
      if (response["Status"].toString().contains("Success")) return true;
      return false;
    } else {
      print("Editing Contact... $id");
      var url = kApiUrl + '/contacts/details/' + id.toString();
      response = await webClient.put(url, json.encode(data), auth: auth);
      print(response);
      if (response["Status"].toString().contains("Success")) return true;
      return false;
    }
  }

  Future<bool> importData(AuthModel auth,
      {@required List<ContactDetails> contacts}) async {
    var data = json.encode(contacts);
    print(data);
    var response;

    response = await webClient.post(kApiUrl + '/contacts/batch/import', data,
        auth: auth);
    print(response);
    if (response["Status"].toString().contains("Success")) return true;
    return false;
  }
}