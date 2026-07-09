# ⚽ ProFootball iOS

> AI-powered football training platform for coaches and young players.

ProFootball is a native iOS application that enables football coaches to create personalized training drills and automatically generate interactive 3D training videos for players.

The application combines **Swift**, **Unity**, **Firebase**, and **AI** technologies to deliver an end-to-end coaching experience.

---

## 📱 Features

- 🔐 Secure user authentication
- ⚽ Interactive football field editor
- 🎯 Place cones, goals, ladders, players and training equipment
- ✏️ Draw player and ball trajectories
- 🤖 AI-powered drill generation
- 🎮 Unity integration for real-time 3D simulation
- 🎥 Automatic video generation directly on the device
- ☁️ Firebase authentication, database and storage
- 📂 Personal training video library

---

## 🏗 Architecture

```
SwiftUI (iOS Client)
        │
        ▼
Unity Framework
        │
        ▼
Video Generation
        │
        ▼
Firebase
(Authentication • Firestore • Storage)
```

---

## 🛠 Tech Stack

### Mobile
- Swift
- SwiftUI
- AVFoundation

### Game Engine
- Unity
- Unity Framework (iOS)

### Backend Services
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### AI
- Gemini AI
- RAG (Retrieval-Augmented Generation)

---

## 📸 Screenshots

> Add screenshots here

| Login | Editor | AI Chat | Videos |
|-------|--------|---------|--------|
| Screenshot | Screenshot | Screenshot | Screenshot |

---

## 🚀 How It Works

1. Coach logs into the application.
2. Creates a football drill using the editor.
3. Places players and training equipment.
4. Draws movement trajectories.
5. Unity generates a 3D simulation.
6. The video is saved locally and can be viewed inside the app.

---

## 📂 Project Structure

```
ProFootball
│
├── Views/
├── Models/
├── Services/
├── ViewModels/
├── Components/
├── Unity/
├── Assets/
└── Resources/
```

---

## 🎯 Motivation

Young football players often train alone without visual guidance.

ProFootball helps bridge this gap by allowing coaches to create customized visual training sessions that players can easily follow on their mobile devices.

---

## 💡 Key Design Decisions

- Native iOS development using **SwiftUI**
- Unity rendering performed **on-device** instead of on the server
- AI assistant enhanced with **RAG** to reduce hallucinations
- Firebase used for secure cloud synchronization

---

## 📈 Results

- ⚡ Up to **75% faster** video generation
- 📱 Native iOS performance
- 🎮 Real-time Unity rendering
- ☁️ Cloud synchronization
- 🤖 AI-assisted training creation

---

## 🔮 Future Work

- Android (Kotlin) version
- Computer Vision for player tracking
- Wearable sensor integration
- Advanced AI tactical recommendations
- Professional coach marketplace

---

## 👨‍💻 Authors

**Selemon Neguse**

Computer Science Graduate

GitHub: https://github.com/selemonneguse

---

## 📄 License

This project was developed as part of the Computer Science Final Project.
