import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  bool _isStreaming = false;
  String? _currentChatId;
  String _streamingMessageId = '';
  String _streamingContent = '';
  int _messageCount = 0;
  static const int _freeMessageLimit = 10;
  static const String _messageCountKey = 'message_count';
  static const String _lastResetDateKey = 'last_reset_date';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  bool get isStreaming => _isStreaming;
  String? get currentChatId => _currentChatId;
  int get messageCount => _messageCount;
  int get remainingMessages => _freeMessageLimit - _messageCount;
  bool get hasReachedLimit => _messageCount >= _freeMessageLimit;

  ChatProvider() {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadChatHistory();
    await _loadMessageCount();
    if (_messages.isEmpty) {
      await _addWelcomeMessage();
    }
  }

  Future<void> _addWelcomeMessage() async {
    _isLoading = true;
    notifyListeners();

    try {
      const welcomeText = "Hello! I'm Sage, your mental wellness companion here in Personify. I'm here to support you on your mental health journey through therapeutic conversations, mindfulness guidance, and helpful coping strategies. How are you feeling today?";
      
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(welcomeMessage);
      await _saveChatHistory();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> sendMessage(String content, {String userName = 'User'}) async {
    if (content.trim().isEmpty) return null;

    // Check message limit
    if (hasReachedLimit) {
      return {'quota_exceeded': true};
    }

    // Add user message with role "user"
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    
    // Set typing state but don't add a fake message
    _isTyping = true;
    _isStreaming = true;
    notifyListeners();

    try {
      // Prepare for AI response
      _streamingMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
      _streamingContent = '';
      
      // Don't add placeholder message, just start streaming
      notifyListeners();

      // Generate user ID (in production, this would come from authentication)
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Stream the response
      final stream = ApiService.sendMessageStream(userId, content, userName: userName);
      
      await for (final chunk in stream) {
        // Check if it's a crisis response
        if (chunk.startsWith('{') && chunk.contains('crisis')) {
          try {
            final crisisData = json.decode(chunk);
            if (crisisData['crisis'] == true) {
              _isTyping = false;
              _isStreaming = false;
              notifyListeners();
              return {'crisis': true};
            }
          } catch (e) {
            // Continue with normal processing if JSON parsing fails
          }
        }
        
        _streamingContent += chunk + ' ';
        
        // If this is the first chunk, create the AI message
        if (_messages.where((msg) => msg.id == _streamingMessageId).isEmpty) {
          final aiMessage = ChatMessage(
            id: _streamingMessageId,
            content: _streamingContent.trim(),
            isUser: false,
            timestamp: DateTime.now(),
          );
          _messages.add(aiMessage);
        } else {
          // Update existing AI message
          _updateStreamingMessage(_streamingContent.trim());
        }
        notifyListeners();
      }
      
      // Finalize the streaming message
      _finalizeStreamingMessage();
      
      // Increment message count and save
      _messageCount++;
      await _saveMessageCount();
      await _saveChatHistory();
      
      return null; // Success
      
    } on QuotaExceededException {
      _removeStreamingMessage();
      return {'quota_exceeded': true};
    } on NetworkException catch (e) {
      _removeStreamingMessage();
      return {'network_error': true, 'message': e.toString()};
    } on ApiException catch (e) {
      _removeStreamingMessage();
      return {'api_error': true, 'message': e.toString()};
    } catch (e) {
      _removeStreamingMessage();
      return {'error': true, 'message': e.toString()};
    } finally {
      _isTyping = false;
      _isStreaming = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> retryLastMessage({String userName = 'User'}) async {
    if (_messages.length < 2) return null;
    
    // Find the last user message
    ChatMessage? lastUserMessage;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        lastUserMessage = _messages[i];
        break;
      }
    }
    
    if (lastUserMessage == null) return null;
    
    // Remove any AI responses after the last user message
    _messages.removeWhere((msg) => 
      !msg.isUser && msg.timestamp.isAfter(lastUserMessage!.timestamp));
    
    notifyListeners();
    
    // Resend the message
    return await sendMessage(lastUserMessage.content, userName: userName);
  }

  void _updateStreamingMessage(String content) {
    final messageIndex = _messages.indexWhere((msg) => msg.id == _streamingMessageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(
        content: content,
        isTyping: false, // AI messages are never in typing state
      );
    }
  }

  void _finalizeStreamingMessage() {
    final messageIndex = _messages.indexWhere((msg) => msg.id == _streamingMessageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(
        content: _streamingContent.trim(),
        isTyping: false,
      );
    }
    _streamingContent = '';
    _streamingMessageId = '';
  }

  void _removeStreamingMessage() {
    _messages.removeWhere((msg) => msg.id == _streamingMessageId);
    _streamingContent = '';
    _streamingMessageId = '';
    notifyListeners();
  }

  Future<void> clearChat() async {
    _messages.clear();
    // Don't reset message count - persist across chat clears
    await _clearChatHistory();
    await _addWelcomeMessage();
    notifyListeners();
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages
          .where((msg) => !msg.isTyping) // Don't save typing messages
          .map((msg) => msg.toJson())
          .toList();
      await prefs.setString('chat_history', json.encode(messagesJson));
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistoryString = prefs.getString('chat_history');
      
      if (chatHistoryString != null) {
        final List<dynamic> messagesJson = json.decode(chatHistoryString);
        _messages = messagesJson
            .map((json) => ChatMessage.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      _messages = [];
    }
  }

  Future<void> _clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history');
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
    }
  }

  Future<void> _saveMessageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_messageCountKey, _messageCount);
      // Also save current date as last usage date
      await prefs.setString(_lastResetDateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving message count: $e');
    }
  }

  Future<void> _loadMessageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if we need to reset the counter (24 hours have passed)
      final lastResetString = prefs.getString(_lastResetDateKey);
      if (lastResetString != null) {
        final lastResetDate = DateTime.parse(lastResetString);
        final now = DateTime.now();
        final difference = now.difference(lastResetDate);
        
        // Reset counter if more than 24 hours have passed
        if (difference.inHours >= 24) {
          _messageCount = 0;
          await _saveMessageCount(); // Save the reset
          debugPrint('Message count reset after 24 hours');
          return;
        }
      }
      
      // Load existing count if within 24 hours
      _messageCount = prefs.getInt(_messageCountKey) ?? 0;
    } catch (e) {
      debugPrint('Error loading message count: $e');
      _messageCount = 0;
    }
  }
}
