import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:philgo_api/philgo_v6_flutter.dart';

class CreateChatRoomScreen extends StatefulWidget {
  static const String routeName = '/create-chat-room';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  final Function(String roomId) onRoomCreated;
  const CreateChatRoomScreen({super.key, required this.onRoomCreated});

  @override
  State<CreateChatRoomScreen> createState() => _CreateChatRoomScreenState();
}

class _CreateChatRoomScreenState extends State<CreateChatRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isOpen = false;
  bool _blockAdvertisement = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(PhilgoTr.of(context)!.create_room),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => {
            if (Navigator.of(context).canPop())
              Navigator.of(context).pop(), // Close the create room screen
          },
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : handleCreateRoom,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(PhilgoTr.of(context)!.create),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${PhilgoTr.of(context)!.room_name} *',
                  hintText: PhilgoTr.of(context)!.enter_room_name,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return PhilgoTr.of(context)!.room_name_required;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Room Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: PhilgoTr.of(context)!.room_description,
                  hintText: PhilgoTr.of(context)!.enter_room_description,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24), // Open Room Toggle
              Card(
                child: SwitchListTile(
                  title: Text(PhilgoTr.of(context)!.open_room),
                  subtitle: Text(PhilgoTr.of(context)!.open_room_description),
                  value: _isOpen,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _isOpen = value;
                          });
                        },
                  secondary: Icon(_isOpen ? Icons.public : Icons.lock),
                ),
              ),

              const SizedBox(height: 16), // Block Advertisement Toggle
              Card(
                child: SwitchListTile(
                  title: Text(PhilgoTr.of(context)!.block_advertisement),
                  subtitle: Text(
                    PhilgoTr.of(context)!.block_advertisement_description,
                  ),
                  value: _blockAdvertisement,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _blockAdvertisement = value;
                          });
                        },
                  secondary: Icon(
                    _blockAdvertisement ? Icons.block : Icons.ads_click,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Create Room Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : handleCreateRoom,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(PhilgoTr.of(context)!.creating),
                          ],
                        )
                      : Text(
                          PhilgoTr.of(context)!.create_room,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleCreateRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    createChatRoom(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      open: _isOpen,
      test: PhilgoConfig.isProduction == true ? true : null,
      blockAdvertisement: _blockAdvertisement ? true : null,
      onCreate: (roomId) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Close the create room screen
        }
        widget.onRoomCreated(roomId);
        setState(() {
          _isLoading = false;
        });
      },
      onError: (error) {
        if (context.mounted) {
          showErrorSnackBar(
            context,
            PhilgoTr.of(context)!.failed_to_create_room(error),
          );
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }
}
