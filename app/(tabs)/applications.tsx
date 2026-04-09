import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export default function Applications() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>My Applications</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {/* Active Loan Application */}
        <Text style={styles.sectionTitle}>Active Loans</Text>
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <View>
              <Text style={styles.appName}>Federal Direct Subsidized</Text>
              <Text style={styles.appType}>Student Loan • FAFSA</Text>
            </View>
            <View style={styles.statusBadge}>
              <Text style={styles.statusText}>In Review</Text>
            </View>
          </View>
          
          {/* Timeline */}
          <View style={styles.timeline}>
            <View style={styles.timelineItem}>
              <View style={[styles.dot, styles.dotCompleted]}>
                <MaterialCommunityIcons name="check" size={12} color="#FFF" />
              </View>
              <View style={styles.timelineContent}>
                <Text style={styles.timelineTitle}>Application Submitted</Text>
                <Text style={styles.timelineSub}>Oct 10, 2026</Text>
              </View>
            </View>
            <View style={styles.timelineLine} />
            <View style={styles.timelineItem}>
              <View style={[styles.dot, styles.dotActive]}>
                <View style={styles.innerDot} />
              </View>
              <View style={styles.timelineContent}>
                <Text style={[styles.timelineTitle, { color: '#FFF' }]}>Document Verification</Text>
                <Text style={styles.timelineSub}>Pending AI review of tax forms</Text>
              </View>
            </View>
            <View style={styles.timelineLineInactive} />
            <View style={styles.timelineItem}>
              <View style={styles.dotInactive} />
              <View style={styles.timelineContent}>
                <Text style={styles.timelineTitleInactive}>Final Approval</Text>
              </View>
            </View>
          </View>

          {/* AI Insight */}
          <LinearGradient colors={['rgba(52, 211, 153, 0.1)', 'rgba(52, 211, 153, 0.05)']} style={styles.aiInsight}>
            <MaterialCommunityIcons name="lightning-bolt" size={20} color="#34D399" />
            <View style={{ marginLeft: 10, flex: 1 }}>
              <Text style={styles.insightTitle}>AI Prediction</Text>
              <Text style={styles.insightText}>Based on historical data, your application is 94% likely to be approved within 3 days.</Text>
            </View>
          </LinearGradient>
        </View>

        {/* Scholarships */}
        <Text style={[styles.sectionTitle, { marginTop: 10 }]}>Scholarships</Text>
        
        <View style={styles.card}>
          <View style={styles.cardHeader}>
             <View>
              <Text style={styles.appName}>National Merit Grant</Text>
              <Text style={styles.appType}>Auto-Applied • $10k</Text>
            </View>
            <View style={[styles.statusBadge, { backgroundColor: 'rgba(52, 211, 153, 0.1)' }]}>
              <Text style={[styles.statusText, { color: '#34D399' }]}>Approved</Text>
            </View>
          </View>
          <TouchableOpacity style={styles.actionBtn}>
             <Text style={styles.actionBtnText}>View Award Letter</Text>
          </TouchableOpacity>
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
  header: {
    paddingHorizontal: 20,
    paddingVertical: 15,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FFF',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 100,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#FFF',
    marginBottom: 15,
  },
  card: {
    backgroundColor: '#151E3D',
    borderRadius: 20,
    padding: 20,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: '#1E293B',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 20,
  },
  appName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFF',
    marginBottom: 4,
  },
  appType: {
    fontSize: 13,
    color: '#94A3B8',
  },
  statusBadge: {
    backgroundColor: 'rgba(251, 191, 36, 0.1)',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 12,
  },
  statusText: {
    color: '#FBBF24',
    fontSize: 12,
    fontWeight: 'bold',
  },
  timeline: {
    marginBottom: 20,
  },
  timelineItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  dot: {
    width: 24,
    height: 24,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 2,
  },
  dotCompleted: {
    backgroundColor: '#34D399',
  },
  dotActive: {
    backgroundColor: 'rgba(59, 130, 246, 0.2)',
    borderWidth: 2,
    borderColor: '#3B82F6',
  },
  innerDot: {
    width: 8,
    height: 8,
    backgroundColor: '#3B82F6',
    borderRadius: 4,
  },
  dotInactive: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#1E293B',
    zIndex: 2,
  },
  timelineLine: {
    width: 2,
    height: 30,
    backgroundColor: '#34D399',
    marginLeft: 11,
    marginTop: -4,
    marginBottom: -4,
    zIndex: 1,
  },
  timelineLineInactive: {
    width: 2,
    height: 30,
    backgroundColor: '#1E293B',
    marginLeft: 11,
    marginTop: -4,
    marginBottom: -4,
    zIndex: 1,
  },
  timelineContent: {
    marginLeft: 15,
    flex: 1,
  },
  timelineTitle: {
    color: '#94A3B8',
    fontSize: 15,
    fontWeight: '600',
  },
  timelineTitleInactive: {
    color: '#475569',
    fontSize: 15,
    fontWeight: '600',
  },
  timelineSub: {
    color: '#64748B',
    fontSize: 13,
    marginTop: 2,
  },
  aiInsight: {
    flexDirection: 'row',
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(52, 211, 153, 0.3)',
  },
  insightTitle: {
    color: '#34D399',
    fontWeight: 'bold',
    fontSize: 14,
    marginBottom: 4,
  },
  insightText: {
    color: '#E2E8F0',
    fontSize: 13,
    lineHeight: 20,
  },
  actionBtn: {
    backgroundColor: '#1E293B',
    paddingVertical: 12,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 10,
  },
  actionBtnText: {
    color: '#FFF',
    fontWeight: '600',
  }
});
