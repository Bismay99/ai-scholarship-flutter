const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = 3000;

app.post('/calculate-score', (req, res) => {
    try {
        const { income, marks, location, category, creditScore } = req.body;
        
        let score = 0;
        let breakdown = {
            income: 0,
            marks: 0,
            location: 0,
            category: 0
        };
        let suggestions = [];
        let explanations = [];

        // Income Score (30% weight)
        const incomeNum = Number(income) || 0;
        if (incomeNum < 200000) {
            breakdown.income = 30;
            explanations.push("Lower income brackets strongly improve your eligibility.");
        } else if (incomeNum <= 500000) {
            breakdown.income = 20;
            explanations.push("Your medium income range provided average eligibility score.");
            suggestions.push("Check out specialized mid-income schemes to boost the chances.");
        } else {
            breakdown.income = 10;
            explanations.push("Higher income relative to limits reduced your financial score.");
            suggestions.push("Explore merit-based scholarships not restricted by income caps.");
        }

        // Academic Score (30% weight)
        const marksNum = Number(marks) || 0;
        if (marksNum > 85) {
            breakdown.marks = 30;
            explanations.push("Excellent academic marks significantly improved your eligibility.");
        } else if (marksNum >= 60) {
            breakdown.marks = 20;
            explanations.push("Decent academic marks contributed positively.");
            suggestions.push("Improving academic performance will increase approval chances significantly.");
        } else {
            breakdown.marks = 10;
            explanations.push("Lower academic score reduced your eligibility.");
            suggestions.push("Work on improving your marks or look for minimum-requirement schemes.");
        }

        // Location Score (20% weight)
        const loc = (location || '').toLowerCase();
        if (loc === 'rural') {
            breakdown.location = 20;
            explanations.push("Rural backgrounds grant higher regional priority points.");
        } else if (loc === 'semi-urban') {
            breakdown.location = 15;
            explanations.push("Semi-urban region granted standard priority points.");
        } else {
            breakdown.location = 10;
            explanations.push("Urban applicant category gives lower regional preference weight.");
        }

        // Category Score (20% weight)
        const cat = (category || '').toUpperCase();
        if (cat === 'SC' || cat === 'ST' || cat === 'SC/ST') {
            breakdown.category = 20;
            explanations.push("Category reservations maximized demographic points.");
        } else if (cat === 'OBC') {
            breakdown.category = 15;
            explanations.push("Category prioritization provided positive points.");
        } else {
            breakdown.category = 10;
            explanations.push("Unreserved category provides base demographic points.");
        }

        score = breakdown.income + breakdown.marks + breakdown.location + breakdown.category;
        
        let probability = 0;
        let risk = '';
        if (score >= 80) {
            probability = 80 + Math.floor((score - 80) * (15 / 20));
            risk = 'Low';
        } else if (score >= 60) {
            probability = 50 + Math.floor((score - 60) * (30 / 19));
            risk = 'Medium';
        } else {
            probability = 20 + Math.floor(score * (30 / 59));
            risk = 'High';
        }

        res.json({
            score: score,
            probability: probability,
            risk: risk,
            breakdown: breakdown,
            explanations: explanations,
            suggestions: suggestions
        });

    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.listen(PORT, () => console.log(`AI Score Backend running on port ${PORT}`));
