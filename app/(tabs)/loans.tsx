import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// Mock Loan Data
const LOANS_DATA = [
  {
    id: 1,
    name: 'Federal Direct Subsidized',
    type: 'Federal Student',
    interestRate: '4.99%',
    maxAmount: '$5,500 / yr',
    tenure: '10-25 Years',
    criteria: 'Undergraduate, Financial Need',
    matchScore: 98,
    isRecommended: true
  },
  {
    id: 2,
    name: 'College Ave Private Student Loan',
    type: 'Private Student',
    interestRate: '5.59% - 16.99%',
    maxAmount: 'Up to 100% of attendance',
    tenure: '5-15 Years',
    criteria: 'Good Credit / Co-signer',
    matchScore: 82,
    isRecommended: false
  },
  {
    id: 3,
    name: 'Sofi Graduate Loan',
    type: 'Graduate / Professional',
    interestRate: '5.24% Fixed',
    maxAmount: '$15,000 / yr',
    tenure: '5, 7, 10, or 15 Years',
    criteria: 'Grad Student status',
    matchScore: 45,
    isRecommended: false
  }
];

export default function Loans() {
  const insets = useSafeAreaInsets();
  const [filter, setFilter] = useState('All');

  const filterOptions = ['All', 'Best Match', 'Federal', 'Private'];

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>Loan Options</Text>
        <TouchableOpacity style={styles.filterMenuBtn}>
          <MaterialCommunityIcons name="tune" size={24} color="#94A3B8" />
        </TouchableOpacity>
      </View>

      <View style={styles.scrollContent}>
        {/* Horizontal Filters */}
        <View style={styles.filterScrollWrapper}>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.filterScroll}>
            {filterOptions.map(opt => (
              <TouchableOpacity key={opt} onPress={() => setFilter(opt)}>
                <LinearGradient 
                  colors={filter === opt ? ['#3B82F6', '#818CF8'] : ['#1E293B', '#1E293B']}
                  style={styles.filterPill}
                >
                  <Text style={[styles.filterText, filter === opt && styles.filterTextActive]}>
                    {opt}
                  </Text>
                </LinearGradient>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        <ScrollView contentContainerStyle={styles.listContainer}>
          {LOANS_DATA.map((loan) => (
            <View key={loan.id} style={styles.card}>
              
              {loan.isRecommended && (
                <LinearGradient 
                  colors={['#10B981', '#34D399']} 
                  style={styles.recommendedBadge}
                  start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }}
                >
                  <MaterialCommunityIcons name="star-shooting-outline" size={12} color="#FFF" />
                  <Text style={styles.recommendedText}>AI Top Pick</Text>
                </LinearGradient>
              )}

              <View style={styles.cardHeader}>
                <View style={[styles.matchScoreBadge, loan.matchScore > 80 ? styles.matchHigh : styles.matchMed]}>
                  <Text style={[styles.matchScoreText, loan.matchScore > 80 ? styles.matchHighText : styles.matchMedText]}>
                    {loan.matchScore}% Match
                  </Text>
                </View>
                <Text style={styles.cardType}>{loan.type}</Text>
              </View>

              <Text style={styles.cardTitle}>{loan.name}</Text>
              
              <View style={styles.statsGrid}>
                <View style={styles.statBox}>
                  <Text style={styles.statLabel}>Interest Rate</Text>
                  <Text style={styles.statValue}>{loan.interestRate}</Text>
                </View>
                <View style={styles.statBox}>
                  <Text style={styles.statLabel}>Max Amount</Text>
                  <Text style={styles.statValue}>{loan.maxAmount}</Text>
                </View>
                <View style={styles.statBox}>
                  <Text style={styles.statLabel}>Tenure</Text>
                  <Text style={styles.statValue}>{loan.tenure}</Text>
                </View>
              </View>

              <View style={styles.criteriaRow}>
                <MaterialCommunityIcons name="check-decagram-outline" size={16} color="#94A3B8" />
                <Text style={styles.criteriaText}>Needs: {loan.criteria}</Text>
              </View>

              <TouchableOpacity style={styles.applyBtn}>
                 <LinearGradient colors={['#3B82F6', '#6366F1']} style={styles.applyBtnGradient}>
                    <Text style={styles.applyBtnText}>Quick Apply</Text>
                 </LinearGradient>
              </TouchableOpacity>

            </View>
          ))}
        </ScrollView>
      </View>
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
  filterMenuBtn: {
    padding: 8,
    borderRadius: 20,
    backgroundColor: '#1E293B',
  },
  scrollContent: {
    flex: 1,
  },
  filterScrollWrapper: {
    height: 50,
    marginBottom: 5,
  },
  filterScroll: {
    paddingHorizontal: 20,
    alignItems: 'center',
  },
  filterPill: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    marginRight: 10,
  },
  filterText: {
    color: '#94A3B8',
    fontWeight: '600',
    fontSize: 14,
  },
  filterTextActive: {
    color: '#FFF',
  },
  listContainer: {
    padding: 20,
    paddingBottom: 100,
  },
  card: {
    backgroundColor: '#151E3D',
    borderRadius: 20,
    padding: 20,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#1E293B',
    position: 'relative',
  },
  recommendedBadge: {
    position: 'absolute',
    top: -10,
    right: 20,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
    zIndex: 10,
  },
  recommendedText: {
    color: '#FFF',
    fontSize: 11,
    fontWeight: 'bold',
    marginLeft: 4,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  matchScoreBadge: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 10,
  },
  matchScoreText: {
    fontSize: 12,
  },
  matchHigh: {
    backgroundColor: 'rgba(52, 211, 153, 0.1)',
  },
  matchMed: {
    backgroundColor: 'rgba(251, 191, 36, 0.1)',
  },
  matchHighText: {
    color: '#34D399',
    fontWeight: 'bold',
    fontSize: 12,
  },
  matchMedText: {
    color: '#FBBF24',
    fontWeight: 'bold',
    fontSize: 12,
  },
  cardType: {
    color: '#94A3B8',
    fontSize: 13,
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFF',
    marginBottom: 16,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    backgroundColor: '#0A0F24',
    padding: 12,
    borderRadius: 12,
    marginBottom: 15,
    borderWidth: 1,
    borderColor: '#1E293B',
  },
  statBox: {
    width: '48%',
    marginBottom: 10,
  },
  statLabel: {
    color: '#64748B',
    fontSize: 11,
    marginBottom: 2,
    textTransform: 'uppercase',
  },
  statValue: {
    color: '#E2E8F0',
    fontSize: 14,
    fontWeight: '600',
  },
  criteriaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 15,
  },
  criteriaText: {
    color: '#94A3B8',
    fontSize: 13,
    marginLeft: 6,
    flex: 1,
  },
  applyBtn: {
    width: '100%',
  },
  applyBtnGradient: {
    paddingVertical: 12,
    borderRadius: 14,
    alignItems: 'center',
  },
  applyBtnText: {
    color: '#FFF',
    fontWeight: 'bold',
    fontSize: 15,
  }
});
