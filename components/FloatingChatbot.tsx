import React, { useRef, useState } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  Animated, 
  PanResponder, 
  TouchableOpacity, 
  Dimensions,
  ScrollView,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  SafeAreaView
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { MaterialCommunityIcons } from '@expo/vector-icons';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');
const BUTTON_WIDTH = 70;
const BUTTON_HEIGHT = 70;

const MOCK_MESSAGES = [
  {
    id: '1',
    sender: 'ai',
    text: "Hi Alex! You can ask me anything about loan eligibility, scholarship recommendations, or your document status!"
  }
];

export default function FloatingChatbot() {
  const pan = useRef(new Animated.ValueXY({ x: SCREEN_WIDTH - BUTTON_WIDTH - 20, y: SCREEN_HEIGHT - BUTTON_HEIGHT - 120 })).current;
  const [isExpanded, setIsExpanded] = useState(false);
  const [messages, setMessages] = useState(MOCK_MESSAGES);
  const [inputText, setInputText] = useState('');

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (_, gestureState) => {
        // Only allow dragging if we move a bit, preventing tap conflicts
        return Math.abs(gestureState.dx) > 5 || Math.abs(gestureState.dy) > 5;
      },
      onPanResponderGrant: () => {
        pan.setOffset({
          x: (pan.x as any)._value,
          y: (pan.y as any)._value
        });
        pan.setValue({ x: 0, y: 0 });
      },
      onPanResponderMove: Animated.event(
        [
          null,
          { dx: pan.x, dy: pan.y }
        ],
        { useNativeDriver: false }
      ),
      onPanResponderRelease: (_, gestureState) => {
        pan.flattenOffset();
        
        let newX = (pan.x as any)._value;
        let newY = (pan.y as any)._value;

        // Boundaries matching the limits to prevent getting lost off-screen
        if (newX < 10) newX = 10;
        if (newX > SCREEN_WIDTH - BUTTON_WIDTH - 10) newX = SCREEN_WIDTH - BUTTON_WIDTH - 10;
        
        if (newY < 50) newY = 50; 
        if (newY > SCREEN_HEIGHT - BUTTON_HEIGHT - 90) newY = SCREEN_HEIGHT - BUTTON_HEIGHT - 90;

        Animated.spring(pan, {
          toValue: { x: newX, y: newY },
          friction: 5,
          useNativeDriver: false
        }).start();
      }
    })
  ).current;

  const handleSend = () => {
    if (!inputText.trim()) return;

    const newMsg = { id: Date.now().toString(), sender: 'user', text: inputText };
    setMessages(prev => [...prev, newMsg]);
    setInputText('');

    // Mock AI response logic
    setTimeout(() => {
      let aiText = "I'm analyzing your request...";
      const query = newMsg.text.toLowerCase();
      if (query.includes('eligibility') || query.includes('loan')) {
         aiText = "Based on your 3.8 GPA and submitted FAFSA, your loan eligibility score is excellent (85/100). You qualify for up to $15k in Federal Direct Loans.";
      } else if (query.includes('scholarship')) {
         aiText = "I proactively found 'National Merit Grant' which matches your profile 85%. Should I auto-apply on your behalf?";
      } else if (query.includes('document') || query.includes('tax')) {
         aiText = "Your tax returns are still pending review. It usually takes our AI about 2-3 hours to fully verify OCR data against the IRS mock records.";
      }

      setMessages(prev => [...prev, { id: Date.now().toString() + '_ai', sender: 'ai', text: aiText }]);
    }, 1000);
  };

  if (isExpanded) {
    return (
      <View style={styles.expandedOverlay}>
        <SafeAreaView style={styles.expandedContainer}>
          <KeyboardAvoidingView 
            behavior={Platform.OS === 'ios' ? 'padding' : undefined} 
            style={styles.flex1}
          >
            {/* Header */}
            <View style={styles.expandedHeader}>
              <View style={styles.headerTitleRow}>
                <MaterialCommunityIcons name="robot-outline" size={24} color="#34D399" />
                <Text style={styles.headerTitle}>AI Intel Analyst</Text>
              </View>
              <TouchableOpacity onPress={() => setIsExpanded(false)} style={styles.closeBtn}>
                <MaterialCommunityIcons name="chevron-down" size={28} color="#94A3B8" />
              </TouchableOpacity>
            </View>

            {/* Chat Body */}
            <ScrollView contentContainerStyle={styles.chatScrollBody}>
              {messages.map(msg => (
                <View key={msg.id} style={[styles.messageRow, msg.sender === 'user' ? styles.userRow : styles.aiRow]}>
                  {msg.sender === 'ai' && (
                    <LinearGradient colors={['#3B82F6', '#818CF8']} style={styles.chatAvatar}>
                      <MaterialCommunityIcons name="lightning-bolt" size={16} color="#FFF" />
                    </LinearGradient>
                  )}
                  <View style={[styles.messageBubble, msg.sender === 'user' ? styles.userBubble : styles.aiBubble]}>
                    <Text style={msg.sender === 'user' ? styles.userMsgText : styles.aiMsgText}>
                      {msg.text}
                    </Text>
                  </View>
                </View>
              ))}
            </ScrollView>

            {/* Input Row */}
            <View style={styles.inputContainer}>
              <View style={styles.inputBox}>
                <TextInput 
                  style={styles.input}
                  placeholder="Ask about loans or scholarships..."
                  placeholderTextColor="#64748B"
                  value={inputText}
                  onChangeText={setInputText}
                  onSubmitEditing={handleSend}
                />
                <TouchableOpacity onPress={handleSend} style={styles.sendBtn}>
                  <MaterialCommunityIcons name="send" size={18} color="#FFF" />
                </TouchableOpacity>
              </View>
            </View>

          </KeyboardAvoidingView>
        </SafeAreaView>
      </View>
    );
  }

  // Idle Draggable Bubble
  return (
    <Animated.View
      style={[
        styles.draggableButton,
        {
          transform: [{ translateX: pan.x }, { translateY: pan.y }]
        }
      ]}
      {...panResponder.panHandlers}
    >
      <TouchableOpacity 
         style={styles.opacityBtn} 
         activeOpacity={0.8}
         onPress={() => setIsExpanded(true)}
      >
        <LinearGradient 
          colors={['rgba(59, 130, 246, 0.9)', 'rgba(52, 211, 153, 0.8)']} 
          style={styles.gradientCylinder}
        >
          <MaterialCommunityIcons name="robot-outline" size={28} color="#FFF" />
        </LinearGradient>
      </TouchableOpacity>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  // Expanded Screen
  expandedOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(10, 15, 36, 0.85)', // Very dark blur
    zIndex: 9999, // Ensure absolute top
    justifyContent: 'flex-end',
  },
  expandedContainer: {
    height: '85%',
    backgroundColor: '#0A0F24',
    borderTopLeftRadius: 30,
    borderTopRightRadius: 30,
    borderWidth: 1,
    borderColor: '#1E293B',
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -10 },
    shadowOpacity: 0.5,
    shadowRadius: 20,
    elevation: 20,
  },
  flex1: {
    flex: 1,
  },
  expandedHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#1E293B',
    backgroundColor: '#151E3D'
  },
  headerTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#E2E8F0',
    marginLeft: 10,
  },
  closeBtn: {
    padding: 5,
  },
  chatScrollBody: {
    padding: 20,
    paddingBottom: 40,
  },
  messageRow: {
    flexDirection: 'row',
    marginBottom: 15,
    alignItems: 'flex-end',
  },
  userRow: {
    justifyContent: 'flex-end',
  },
  aiRow: {
    justifyContent: 'flex-start',
  },
  chatAvatar: {
    width: 28,
    height: 28,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  messageBubble: {
    maxWidth: '80%',
    padding: 14,
    borderRadius: 20,
  },
  aiBubble: {
    backgroundColor: '#1E293B',
    borderBottomLeftRadius: 4,
  },
  userBubble: {
    backgroundColor: '#34D399',
    borderBottomRightRadius: 4,
  },
  aiMsgText: {
    color: '#E2E8F0',
    fontSize: 15,
    lineHeight: 22,
  },
  userMsgText: {
    color: '#064E3B',
    fontSize: 15,
    fontWeight: '500',
    lineHeight: 22,
  },
  inputContainer: {
    paddingHorizontal: 20,
    paddingVertical: 15,
    backgroundColor: '#0A0F24',
    borderTopWidth: 1,
    borderTopColor: '#1E293B',
  },
  inputBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#151E3D',
    borderRadius: 24,
    paddingHorizontal: 15,
    paddingVertical: 8,
  },
  input: {
    flex: 1,
    color: '#FFF',
    fontSize: 15,
    minHeight: 40,
  },
  sendBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#3B82F6',
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 10,
  },

  // Draggable Button
  draggableButton: {
    position: 'absolute',
    width: BUTTON_WIDTH,
    height: BUTTON_HEIGHT,
    zIndex: 9999, // Float on top of everything
  },
  opacityBtn: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  gradientCylinder: {
    width: 60,
    height: 60,
    borderRadius: 30, // Oval / perfect circle cylinder look
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#34D399',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.6,
    shadowRadius: 10,
    elevation: 8,
  }
});
