import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/services.dart';
import '../../utils/colors.dart';
import '../../utils/page_transitions.dart';
import '../../models/transaction_model.dart';
import 'transaction_chat_screen.dart';

class ContactSelectionScreen extends StatefulWidget {
  final List<TransactionModel>? transactions;
  
  const ContactSelectionScreen({
    this.transactions,
    super.key,
  });

  @override
  State<ContactSelectionScreen> createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filtered = [];
  bool _loading = true;
  String _query = '';
  bool _useSample = false;
  String? _lastDebug;
  static const MethodChannel _nativeChan = MethodChannel('neupe.contacts');
  final List<Map<String, String>> _sampleContacts = const [
    {'name': 'Test Rahul', 'phone': '9876500001'},
    {'name': 'Test Priya', 'phone': '9876500002'},
    {'name': 'Test Amit', 'phone': '9876500003'},
  ];

  @override
  void initState() {
    super.initState();
    _initContacts();
  }

  Future<void> _initContacts() async {
    setState(() {
      _loading = true;
      _lastDebug = null;
    });

    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      // Note: FlutterContacts.requestPermission() might return false even if system permission is granted.
      // We already have system permission from above, so we'll skip this check and try to fetch.
      
      // Try with properties first
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      // If none found, try a lighter fetch to check differences
      if (contacts.isEmpty) {
        final lite = await FlutterContacts.getContacts(withProperties: false);
        _lastDebug = 'withProperties=0 found ${lite.length}, withProperties=1 found ${contacts.length}';
        // prefer lite if it has entries
        if (lite.isNotEmpty) {
          lite.sort((a, b) => a.displayName.compareTo(b.displayName));
          setState(() {
            _contacts = lite;
            _filtered = lite;
            _loading = false;
          });
          return;
        }

        // If both plugin fetches returned empty, try the native MethodChannel fallback automatically
        _lastDebug = 'Plugin returned 0 contacts; attempting native fallback';
        
        // Call native fallback and wait for result
        final res = await _nativeChan.invokeMethod<List>('getContacts');
        // ignore: avoid_print
        print('Native getContacts returned: ${res?.length} items');
        final list = (res ?? []).cast<dynamic>();
        
        final parsed = <Contact>[];
        for (final e in list) {
          try {
            if (e is Map) {
              final name = (e['name'] ?? '').toString().trim();
              final phone = (e['phone'] ?? '').toString().trim();
              if (phone.isNotEmpty) {
                // Create Contact with displayable name and phone
                final contact = Contact(
                  name: Name(first: name.isNotEmpty ? name : phone),
                  phones: [Phone(phone)],
                );
                parsed.add(contact);
              }
            }
          } catch (itemErr) {
            // ignore: avoid_print
            print('Failed to parse contact item: $itemErr');
          }
        }
        // ignore: avoid_print
        print('Parsed ${parsed.length} valid contacts from ${list.length} raw items');

        if (parsed.isNotEmpty) {
          parsed.sort((a, b) => a.displayName.compareTo(b.displayName));
          setState(() {
            _contacts = parsed;
            _filtered = parsed;
            _loading = false;
          });
          return;
        }
      }

      contacts.sort((a, b) => (a.displayName).compareTo(b.displayName));
      setState(() {
        _contacts = contacts;
        _filtered = contacts;
        _loading = false;
      });
      // store a brief preview for debug
      if (contacts.isNotEmpty) {
        _lastDebug = 'First: ${contacts.first.displayName} / phones:${contacts.first.phones.length}';
      }
    } catch (e) {
      setState(() => _loading = false);
      _lastDebug = e.toString();
    }
  }

  Future<void> _tryNativeQuery() async {
    setState(() {
      _loading = true;
      _lastDebug = null;
    });
    try {
      final res = await _nativeChan.invokeMethod<List>('getContacts');
      // ignore: avoid_print
      print('Native getContacts returned: ${res?.length} items');
      final list = (res ?? []).cast<dynamic>();
      
      final parsed = <Contact>[];
      for (final e in list) {
        try {
          if (e is Map) {
            final name = (e['name'] ?? '').toString().trim();
            final phone = (e['phone'] ?? '').toString().trim();
            if (name.isNotEmpty && phone.isNotEmpty) {
              final contact = Contact(
                name: Name(first: name),
                phones: [Phone(phone)],
              );
              parsed.add(contact);
            }
          }
        } catch (itemErr) {
          // ignore: avoid_print
          print('Failed to parse contact item: $itemErr');
        }
      }
      // ignore: avoid_print
      print('Parsed ${parsed.length} valid contacts from ${list.length} raw items');

      if (parsed.isEmpty) {
        setState(() {
          _loading = false;
          _lastDebug = 'Native returned 0 valid contacts from ${list.length} items';
        });
        return;
      }

      parsed.sort((a, b) => a.displayName.compareTo(b.displayName));

      setState(() {
        _contacts = parsed;
        _filtered = parsed;
        _loading = false;
        // show a short preview (first 5)
        final preview = parsed.take(5).map((c) => c.displayName).join(', ');
        _lastDebug = 'Native: ${parsed.length} contacts – first: $preview';
      });
    } catch (e, stack) {
      // ignore: avoid_print
      print('Native query error: $e\n$stack');
      setState(() {
        _loading = false;
        _lastDebug = 'Native query error: ${e.toString()}';
      });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _filtered = _contacts;
      } else {
        final lower = q.toLowerCase();
        _filtered = _contacts.where((c) {
          final name = c.displayName.toLowerCase();
          final phones = c.phones.map((p) => p.number).join(' ');
          return name.contains(lower) || phones.contains(lower);
        }).toList();
      }
    });
  }

  Color _avatarColorFor(String seed) {
    // Deterministic blend between primary and secondary for variety.
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    final t = ((hash % 100) / 100.0).clamp(0.0, 1.0);
    return Color.lerp(AppColors.primary, AppColors.secondary, t) ?? AppColors.primary;
  }

  Widget _buildContactTile(Contact c) {
    final name = c.displayName;
    final phone = c.phones.isNotEmpty ? c.phones.first.number.replaceAll(RegExp(r'\s+|-'), '') : '';
    final heroTag = 'contactHero:${(phone.isNotEmpty ? phone : name).trim().toLowerCase()}';

    return ListTile(
      leading: Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: CircleAvatar(
            backgroundColor: _avatarColorFor(name.isNotEmpty ? name : phone),
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        phone,
        style: TextStyle(color: Colors.white.withOpacity(0.70)),
      ),
      onTap: phone.isNotEmpty
          ? () {
            // Filter transactions with this contact (best-effort by name)
              final contactTransactions = widget.transactions != null
                  ? widget.transactions!
                .where((txn) => txn.title.toLowerCase().contains(name.toLowerCase()))
                      .toList()
                  : <TransactionModel>[];

              Navigator.push(
                context,
                smoothFadeScaleRoute(
                  (context) => TransactionChatScreen(
                    contactName: name,
                    contactPhone: phone,
                    transactions: contactTransactions,
                  ),
                  contentFadeInStart: 0.42,
                ),
              );
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select Contact'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search contacts or numbers',
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.70)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.55)),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _useSample
              ? ListView.separated(
                  itemCount: _sampleContacts.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                  itemBuilder: (context, index) {
                    final c = _sampleContacts[index];
                    return ListTile(
                      leading: Hero(
                        tag: 'contactHero:${c['phone']!.trim().toLowerCase()}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: CircleAvatar(
                            backgroundColor: _avatarColorFor(c['name']!),
                            child: Text(
                              c['name']![0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      title: Text(c['name']!, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(c['phone']!, style: TextStyle(color: Colors.white.withOpacity(0.70))),
                      onTap: () {
                        // Filter transactions with this contact's phone
                        final phone = c['phone']!;
                        final contactTransactions = widget.transactions != null
                            ? widget.transactions!
                            .where((txn) => txn.title.toLowerCase().contains(c['name']!.toLowerCase()))
                                .toList()
                            : <TransactionModel>[];

                        Navigator.push(
                          context,
                          smoothFadeScaleRoute(
                            (context) => TransactionChatScreen(
                              contactName: c['name']!,
                              contactPhone: phone,
                              transactions: contactTransactions,
                            ),
                            contentFadeInStart: 0.42,
                          ),
                        );
                      },
                    );
                  },
                )
              : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No contacts found',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 36.0),
                            child: Text(
                              'Make sure this app has Contacts permission and that your device has at least one contact. You can also add contacts to the emulator or use the sample list for testing.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: _initContacts,
                                child: const Text('Retry'),
                              ),
                              ElevatedButton(
                                onPressed: _tryNativeQuery,
                                child: const Text('Try native query'),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  await openAppSettings();
                                },
                                child: const Text('Open Settings'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _useSample = true;
                                  });
                                },
                                child: const Text('Use sample contacts'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_lastDebug != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                              child: Text(
                                'Debug: $_lastDebug\nContacts found: ${_contacts.length}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.55)),
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                      itemBuilder: (context, index) {
                        final c = _filtered[index];
                        return _buildContactTile(c);
                      },
                    ),
    );
  }
}
