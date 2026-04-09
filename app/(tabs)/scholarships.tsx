import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const SCHOLARSHIPS = [
  {
    id: 1,
    name: 'Future Innovators Tech Scholarship',
    amount: '$5,000',
    deadline: 'Oct 31, 2026',
    match: 98,
    tags: ['Tech', 'Undergrad'],
  },
  {
    id: 2,
    name: 'National Merit Grant',
    amount: '$10,000',
    deadline: 'Nov 15, 2026',
    match: 85,
    tags: ['Merit', 'Federal'],
  },
  {
    id: 3,
    name: 'Women in STEM Initiative',
    amount: '$2,500',
    deadline: 'Dec 01, 2026',
    match: 76,
    tags: ['STEM', 'Diversity'],
  },
];

export default function Scholarships() {
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>Scholarships</Text>
        <TouchableOpacity style={styles.filterBtn}>
          <MaterialCommunityIcons name="tune-variant" size={20} color="#94A3B8" />
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <LinearGradient colors={['rgba(99, 102, 241, 0.15)', 'rgba(16, 185, 129, 0.1)']} style={styles.aiBanner}>
          <MaterialCommunityIcons name="auto-fix" size={24} color="#818CF8" />
          <View style={styles.aiBannerText}>
            <Text style={styles.aiBannerTitle}>AI Recommendations</Text>
            <Text style={styles.aiBannerSub}>Ranked based on your profile and eligibility criteria.</Text>
          </View>
        </LinearGradient>

        {SCHOLARSHIPS.map((item) => (
          <View key={item.id} style={styles.card}>
            <View style={styles.cardHeader}>
              <View style={styles.matchBadge}>
                <MaterialCommunityIcons name="lightning-bolt" size={14} color="#FBBF24" />
                <Text style={styles.matchText}>{item.match}% Match</Text>
              </View>
              <Text style={styles.amountText}>{item.amount}</Text>
            </View>

            <Text style={styles.scholarshipName}>{item.name}</Text>
            
            <View style={styles.tagsRow}>
              {item.tags.map(t => (
                <View key={t} style={styles.tag}>
                  <Text style={styles.tagText}>{t}</Text>
                </View>
              ))}
            </View>

            <View style={styles.footerRow}>
              <View style={styles.deadlineRow}>
                <MaterialCommunityIcons name="clock-outline" size={16} color="#94A3B8" />
                <Text style={styles.deadlineText}>Due {item.deadline}</Text>
              </View>
              
              <TouchableOpacity>
                <LinearGradient colors={['#3B82F6', '#6366F1']} style={styles.applyBtn}>
                  <Text style={styles.applyBtnText}>Auto-Apply</Text>
                </LinearGradient>
              </TouchableOpacity>
            </View>
          </View>
        ))}
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
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 15,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FFF',
  },
  filterBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#1E293B',
    justifyContent: 'center',
    alignItems: 'center',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 100,
  },
  aiBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 16,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: 'rgba(129, 140, 248, 0.3)',
  },
  aiBannerText: {
    marginLeft: 12,
    flex: 1,
  },
  aiBannerTitle: {
    color: '#818CF8',
    fontWeight: 'bold',
    fontSize: 15,
    marginBottom: 2,
  },
  aiBannerSub: {
    color: '#94A3B8',
    fontSize: 13,
  },
  card: {
    backgroundColor: '#151E3D',
    borderRadius: 20,
    padding: 20,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#1E293B',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  matchBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(251, 191, 36, 0.1)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  matchText: {
    color: '#FBBF24',
    fontSize: 12,
    fontWeight: 'bold',
    marginLeft: 4,
  },
  amountText: {
    color: '#34D399',
    fontSize: 18,
    fontWeight: 'bold',
  },
  scholarshipName: {
    color: '#FFF',
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  tagsRow: {
    flexDirection: 'row',
    marginBottom: 20,
  },
  tag: {
    backgroundColor: '#1E293B',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
    marginRight: 8,
  },
  tagText: {
    color: '#94A3B8',
    fontSize: 12,
  },
  footerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: '#1E293B',
    paddingTop: 16,
  },
  deadlineRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  deadlineText: {
    color: '#94A3B8',
    fontSize: 13,
    marginLeft: 6,
  },
  applyBtn: {
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 20,
  },
  applyBtnText: {
    color: '#FFF',
    fontWeight: 'bold',
    fontSize: 13,
  },
});
