# 📱 Oxalis Hub

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

---

## 📌 Project Overview

Oxalis Hub нь их сургуулийн кампус доторх барилга, анги танхим, үйлчилгээний байршлыг хялбар олох боломж олгодог мобайл аппликейшн юм.

Энэхүү апп нь хэрэглэгчийн байршилд тулгуурлан хамгийн ойр замыг харуулж, QR код болон газрын зураг ашиглан навигаци хийдэг.

---

## 🎯 Objectives

* Кампус дотор төөрөх асуудлыг шийдэх
* Анги, өрөө хурдан олох
* Цаг хэмнэх
* Мэдээллийг төвлөрүүлэх

---

## 👥 Team Members

| Name      | Role                 | Branch             |
| --------- | -------------------- | ------------------ |
| Haru      | fullstack            | feature-dev3       |
| Dawka     | fullstack            | feature-dev2       |
| Dashmii   | missing(idk)         | feature-dev1       |

---

## 🛠 Tech Stack

### Frontend

* Flutter

### Backend

* Firebase (Auth, Firestore)

### Tools

* Git & GitHub
* Figma (UI Design)

---

## 📂 Project Structure

```
lib/
 ├── models/        # Data models
 ├── services/      # API & Firebase services
 ├── screens/       # UI screens
 ├── widgets/       # Reusable components
 ├── controllers/   # Logic control
```

---

## 🚀 Features

### 📍 Navigation

* Map view
* Current location detection
* Route guidance

### 🔍 Search

* Search building
* Search room

### 📷 QR Code

* Scan QR to find location

### 🔔 Notifications

* Event notifications

### 📅 Student Features

* View schedule
* To-do list

---

## 🔄 Workflow (Team Rules)

### ⚠️ Important Rules

* Do NOT push directly to `main`
* Always use Pull Request
* Work only on your assigned branch
* Push your code daily

---

## 💻 Git Commands

### Clone project

```
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### Switch branch

```
git checkout feature-your-branch
```

### Pull latest changes

```
git pull origin feature-your-branch
```

### Push changes

```
git add .
git commit -m "your message"
git push origin feature-your-branch
```

---

## 📅 Development Phases

1. Planning
2. Design (UI + Database)
3. Development
4. Testing
5. Deployment

---

## ⚠️ Challenges / Risks

* GPS accuracy issues
* Map data availability
* Real-time updates complexity

---

## 📈 Future Improvements

* Real-time navigation
* Indoor positioning system
* AI-based route optimization

---

## 🛠 Setup notes

### Floor plan assets

Per-floor PNGs for the indoor map live in `assets/floorplans/floor_b1.png`,
`floor_1.png`, `floor_2.png`, `floor_3.png`. See
`assets/floorplans/README.md` for how to extract them from the source PDF.

### Firestore seeding

Drop a Firebase service account JSON at the project root as
`service-account.json`, then run:

```sh
node scripts/seed-building.js              # creates "Сүлжээ Хичээлийн I байр" + rooms
node scripts/migrate-room-occupants.js     # migrates legacy occupantId → occupantIds[]
node scripts/grant-admin.js me@example.com # promotes a user to admin
```

### Admin web build

```sh
flutter build web -t lib/admin/main_admin.dart
```

Deploy the `build/web` output to Firebase Hosting. End users get the mobile
app; staff use the web admin URL.

## 📜 License

This project is for educational purposes.

## shortest path find algo
Dijkstra’s Algorithm
Bellman–Ford Algorithm
