import React from 'react';
import { View, Text, StyleSheet, ScrollView, Animated } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default function Dashboard() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>Welcome back,</Text>
            <Text style={styles.name}>Alex M.</Text>
          </View>
          <View style={styles.avatarContainer}>
            <LinearGradient colors={['#34D399', '#059669']} style={styles.avatarGradient}>
              <Text style={styles.avatarText}>A</Text>
            </LinearGradient>
          </View>
        </View>

        {/* AI Eligibility Widget */}
        <LinearGradient colors={['#1E293B', '#111827']} style={styles.widgetCard}>
          <View style={styles.widgetHeader}>
            <MaterialCommunityIcons name="robot-outline" size={24} color="#818CF8" />
            <Text style={styles.widgetTitle}>AI Eligibility Score</Text>
          </View>
          <View style={styles.scoreRow}>
            <Text style={styles.scoreText}>85</Text>
            <Text style={styles.scoreSub}>/ 100</Text>
          </View>
          {/* Progress Bar */}
          <View style={styles.progressBarBg}>
            <LinearGradient
              colors={['#818CF8', '#34D399']}
              style={[styles.progressBarFill, { width: '85%' }]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            />
          </View>
          <Text style={styles.scoreCaption}>
            High probability of approval for federal & private student loans.
          </Text>
        </LinearGradient>

        {/* Quick Stats Grid */}
        <View style={styles.statsGrid}>
          <View style={styles.statCard}>
            <MaterialCommunityIcons name="currency-usd" size={28} color="#34D399" />
            <Text style={styles.statValue}>$15k</Text>
            <Text style={styles.statLabel}>Max Loan limit</Text>
          </View>
          <View style={styles.statCard}>
            <MaterialCommunityIcons name="school-outline" size={28} color="#FBBF24" />
            <Text style={styles.statValue}>12</Text>
            <Text style={styles.statLabel}>Scholarships Found</Text>
          </View>
        </View>

        {/* Next Action items */}
        <Text style={styles.sectionTitle}>Required Actions</Text>

        <View style={styles.actionCard}>
          <View style={styles.actionIconBg}>
            <MaterialCommunityIcons name="file-document-alert-outline" size={20} color="#F87171" />
          </View>
          <View style={styles.actionTextContent}>
            <Text style={styles.actionTitle}>Upload Tax Returns</Text>
            <Text style={styles.actionSub}>Required for FAFSA processing</Text>
          </View>
          <MaterialCommunityIcons name="chevron-right" size={24} color="#64748B" />
        </View>

        <View style={styles.actionCard}>
          <View style={[styles.actionIconBg, { backgroundColor: 'rgba(52, 211, 153, 0.1)' }]}>
            <MaterialCommunityIcons name="check-decagram" size={20} color="#34D399" />
          </View>
          <View style={styles.actionTextContent}>
            <Text style={styles.actionTitle}>Identity Verified</Text>
            <Text style={styles.actionSub}>AI document scan completed</Text>
          </View>
        </View>

      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0A0F24',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 100,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 30,
    marginTop: 10,
  },
  greeting: {
    fontSize: 16,
    color: '#94A3B8',
    fontFamily: 'System',
  },
  name: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginTop: 4,
  },
  avatarContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    overflow: 'hidden',
  },
  avatarGradient: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    color: '#FFF',
    fontSize: 20,
    fontWeight: 'bold',
  },
  widgetCard: {
    padding: 20,
    borderRadius: 24,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: '#1E293B',
  },
  widgetHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  widgetTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#E2E8F0',
    marginLeft: 10,
  },
  scoreRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginBottom: 15,
  },
  scoreText: {
    fontSize: 48,
    fontWeight: '800',
    color: '#34D399',
  },
  scoreSub: {
    fontSize: 18,
    color: '#94A3B8',
    marginLeft: 5,
    fontWeight: '600',
  },
  progressBarBg: {
    height: 8,
    backgroundColor: '#334155',
    borderRadius: 4,
    marginBottom: 15,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    borderRadius: 4,
  },
  scoreCaption: {
    fontSize: 13,
    color: '#94A3B8',
    lineHeight: 20,
  },
  statsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 30,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#151E3D',
    padding: 20,
    borderRadius: 20,
    marginHorizontal: 5,
    borderWidth: 1,
    borderColor: '#1E293B',
    alignItems: 'flex-start',
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FFF',
    marginTop: 10,
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: '#94A3B8',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#FFF',
    marginBottom: 15,
  },
  actionCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#151E3D',
    padding: 16,
    borderRadius: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#1E293B',
  },
  actionIconBg: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'rgba(248, 113, 113, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  actionTextContent: {
    flex: 1,
  },
  actionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFF',
    marginBottom: 4,
  },
  actionSub: {
    fontSize: 13,
    color: '#94A3B8',
  },
});
