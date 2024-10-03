import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_app_name/Services/notification_service.dart';

/// A screen for the user to customize their notification preferences.
class PreferencesScreen extends StatefulWidget {
  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

/// The state of the [PreferencesScreen].
class _PreferencesScreenState extends State<PreferencesScreen> {
  String _selectedFrequency = '1 min';
  final List<String> _frequencies = ['5 sec', '10 sec', '1 min', 'daily', 'weekly'];

  bool _newUpdates = false;
  bool _promotions = false;
  bool _offers = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Load the user's notification preferences from SharedPreferences.
  _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFrequency = prefs.getString('notificationFrequency') ?? '1 min';
      _newUpdates = prefs.getBool('newUpdates') ?? false;
      _promotions = prefs.getBool('promotions') ?? false;
      _offers = prefs.getBool('offers') ?? false;
    });
  }

  /// Save the user's notification preferences to SharedPreferences.
  _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationFrequency', _selectedFrequency);
    await prefs.setBool('newUpdates', _newUpdates);
    await prefs.setBool('promotions', _promotions);
    await prefs.setBool('offers', _offers);
    NotificationService().updateNotificationPreferences(_selectedFrequency, _newUpdates, _promotions, _offers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Preferences')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Frequency:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedFrequency,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFrequency = newValue;
                  });
                  _savePreferences();
                }
              },
              items: _frequencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Notification Types:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text('New Updates'),
              value: _newUpdates,
              onChanged: (bool value) {
                setState(() {
                  _newUpdates = value;
                });
                _savePreferences();
              },
            ),
            SwitchListTile(
              title: Text('Promotions'),
              value: _promotions,
              onChanged: (bool value) {
                setState(() {
                  _promotions = value;
                });
                _savePreferences();
              },
            ),
            SwitchListTile(
              title: Text('Offers'),
              value: _offers,
              onChanged: (bool value) {
                setState(() {
                  _offers = value;
                });
                _savePreferences();
              },
            ),
          ],
        ),
      ),
    );
  }
}