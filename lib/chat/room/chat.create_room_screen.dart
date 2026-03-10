import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/util/util.functions.dart';

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
        title: Text("Create Room"),
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
                : Text("Create"),
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
                  labelText: 'Room Name *',
                  hintText: "Enter room name",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Room name is required";
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
                  labelText: "Room Description",
                  hintText: "Enter room description",
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
                  title: Text("Open Room"),
                  subtitle: Text("Allow anyone to join this room"),
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
                  title: Text("Block Advertisement"),
                  subtitle: Text("Block advertisement messages in this room"),
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
                            Text("Creating..."),
                          ],
                        )
                      : Text(
                          "Create Room",
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
      // test: PhilgoConfig.isProduction == true ? true : null,
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
          showErrorSnackBar(context, "Failed to create room: $error");
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }
}
