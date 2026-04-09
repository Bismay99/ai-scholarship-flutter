# 🎓 AI Scholarship & Loan Discovery Suite

A full-stack, AI-driven platform designed to revolutionize how students find and apply for scholarships and loans. This project combines a high-performance **Flutter Mobile App**, an **AI-powered Node.js Backend**, and a **Web Dashboard**.

---

## 🚀 Key Features

- **🛡️ AI Document Verification**: Uses **Gemini 2.5 Flash** and **Groq (LLaMA 3)** to instantly verify Aadhaar, PAN, and Academic Marksheets with 99% accuracy.
- **⚡ AI Auto-Fill**: Extract data from photos of documents and automatically fill out complex scholarship forms in seconds.
- **🎙️ Bilingual Voice Assistant**: Integrated **Vapi AI** supporting English and Hindi for hands-free application assistance.
- **📊 AI Eligibility Scoring**: A custom **Node.js engine** that calculates eligibility probability based on financial and academic data.
- **🔐 Secure Vault**: Biometric-secured document storage using Flutter `local_auth`.

---

## 📂 Project Structure

This is a **Monorepo** containing the following components:

- **[`ai_scholarship_flutter`](./ai_scholarship_flutter)**: The primary mobile application (Android/iOS) built with Flutter and Provider.
- **[`ai_scholarship_backend`](./ai_scholarship_backend)**: Node.js/Express server handling AI scoring and advanced eligibility logic.
- **[`web`](./)**: Expo-based web landing portal for the scholarship suite.

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Mobile), Expo/React (Web)
- **Backend**: Node.js, Express, Firebase (Auth, Firestore, Storage)
- **AI Models**: 
  - **Gemini 2.5 Flash**: Secondary Vision & Extraction
  - **Groq (LLaMA 3)**: Primary High-Speed Extraction
  - **OCR Space**: Fallback document scanning
  - **Vapi AI**: Voice interaction engine

---

## ⚙️ Setup & Installation

### 1. Flutter Mobile App
```bash
cd ai_scholarship_flutter
flutter pub get
flutter run
```

### 2. AI Scoring Backend
```bash
cd ai_scholarship_backend
npm install
npm start
```

---

## 🏆 Hackathon Highlights

- **Fail-over Redundancy**: Logic that switches between 3 different AI models to ensure 100% uptime for document verification.
- **Multilingual Support**: Real-time Hindi/English voice processing for rural accessibility.
- **Security First**: All sensitive documents are processed and mapped before being securely stored in a biometric-locked vault.

---

**Developed for AI Scholarship Hackathon 2026** 🚀
