import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';
import 'package:rss_reader_plus/services/update_service.dart';

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _updateTimeController = TextEditingController();
  TextEditingController _networkProxyUsernameController = TextEditingController();
  TextEditingController _networkProxyPasswordController = TextEditingController();
  bool _useNetworProxy;
  bool _initialized;

@override
  void initState() {
    _initialized = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PrefsService _prefsService = Provider.of<PrefsService>(context);
    UpdateService _updateService = Provider.of<UpdateService>(context);
    
    if (!_initialized) {
      _initialized = true;
      final updateRate = _prefsService.getFeedUpdateRate();
      _updateTimeController.text = updateRate.toString();
      _networkProxyUsernameController.text = _prefsService.getNetworkProxyUsername().toString();
      _networkProxyPasswordController.text = _prefsService.getNetworkProxyPassword().toString();

      _useNetworProxy = _prefsService.getUseNetworkProxy();
    }

    return _buildAll(context, _prefsService, _updateService);
  }

  Widget _buildAll(BuildContext context, PrefsService prefsService, UpdateService updateService) {
    return WillPopScope(
      onWillPop: () async {
        final validForm = _formKey.currentState.validate();

        if (validForm) {
          await savePrefs(prefsService, updateService);
        }

        return validForm;     // If invalid, won't pop scope
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Preferences'),
        ),
        body: _buildContent(context)
      ),
    );
  }

  Future<void> savePrefs(PrefsService prefsService, UpdateService updateService) async {
    final updateRate = int.parse(_updateTimeController.text);
    await prefsService.setFeedUpdateRate(updateRate);
    await prefsService.setUseNetworkProxy(_useNetworProxy);
    await prefsService.setNetworkProxyUsername(_networkProxyUsernameController.text);
    await prefsService.setNetworkProxyPassword(_networkProxyPasswordController.text);
    
    updateService.setUpdateRate(updateRate);
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),      
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Feeds',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20),),
                Divider(),
                TextFormField(
                  controller: _updateTimeController,
                  decoration: InputDecoration(
                    labelText: 'Feed update time, in minutes',
                    hintText: 'Update time in minutes'),
                  keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                  validator: (value) {
                    if (value == null || value.isEmpty || int.parse(value) <= 0) {
                      return 'Update time must be a non-zero positive number';
                    }

                    return null;
                  },
                  // onChanged: (String value) {
                  //   setState(() {
                  //     final numberizedString =onlyNumbers(value);
                  //     if (numberizedString.length > 0) {
                  //       _updateTime = int.parse(numberizedString);
                  //     }
                  //   });
                  // },
                ),
                SizedBox(height: 10,),
                Divider(),
                Text('Network Proxy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),),
                  CheckboxListTile(
                    title: Text('Use Network Proxy'),
                    value: _useNetworProxy,
                    onChanged: (bool value) {
                    setState(() {
                      _useNetworProxy = value;
                    });
                  }),
                  TextFormField(
                    controller: _networkProxyUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Network proxy username',
                      hintText: 'Enter your network proxy username'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _networkProxyPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Network proxy password',
                      hintText: 'Enter your network proxy password'),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }

                      return null;
                    },
                  ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}