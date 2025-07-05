// lib/presentation/debug/debug_screen.dart

import 'package:flutter/material.dart';
import 'package:dear_flutter/data/datasources/remote/debug_api_service.dart';
import 'package:dear_flutter/core/config/app_config.dart';
import 'package:dear_flutter/core/di/injection.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final DebugApiService _debugService = getIt<DebugApiService>();
  Map<String, dynamic>? _lastResponse;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableDebugEndpoints) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug')),
        body: const Center(
          child: Text(
            'Debug endpoints not available in release mode',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Panel'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Config Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Base URL: ${AppConfig.baseUrl}'),
                    Text('Debug URL: ${AppConfig.debugBaseUrl}'),
                    Text('Is Debug: ${AppConfig.isDebug}'),
                    Text('Is Release: ${AppConfig.isRelease}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _ping,
                    child: const Text('Ping'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDatabase,
                    child: const Text('Test DB'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getSystemInfo,
                    child: const Text('System Info'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Loading indicator
            if (_isLoading) const LinearProgressIndicator(),
            
            // Error display
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                    ],
                  ),
                ),
              ),
            ],
            
            // Response display
            if (_lastResponse != null) ...[
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Response',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _formatJson(_lastResponse!),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _ping() async {
    await _makeRequest(() => _debugService.ping());
  }

  Future<void> _testDatabase() async {
    await _makeRequest(() => _debugService.testDatabase());
  }

  Future<void> _getSystemInfo() async {
    await _makeRequest(() => _debugService.getSystemInfo());
  }

  Future<void> _makeRequest(Future<Map<String, dynamic>> Function() request) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastResponse = null;
    });

    try {
      final response = await request();
      setState(() {
        _lastResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatJson(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    _formatJsonRecursive(json, buffer, 0);
    return buffer.toString();
  }

  void _formatJsonRecursive(dynamic obj, StringBuffer buffer, int indent) {
    final indentStr = '  ' * indent;
    
    if (obj is Map<String, dynamic>) {
      buffer.writeln('{');
      final entries = obj.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.write('$indentStr  "${entry.key}": ');
        _formatJsonRecursive(entry.value, buffer, indent + 1);
        if (i < entries.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$indentStr}');
    } else if (obj is List) {
      buffer.write('[');
      for (int i = 0; i < obj.length; i++) {
        _formatJsonRecursive(obj[i], buffer, indent);
        if (i < obj.length - 1) buffer.write(', ');
      }
      buffer.write(']');
    } else if (obj is String) {
      buffer.write('"$obj"');
    } else {
      buffer.write(obj.toString());
    }
  }
}
