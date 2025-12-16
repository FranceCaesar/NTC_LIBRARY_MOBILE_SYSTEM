# 📚 NTC Library Mobile Application

---

## 📖 Project Description

The **NTC Library App** is a native mobile application designed to digitize and streamline the library services of **The National Teachers College (NTC)**.  
It aims to replace traditional, manual library operations with a **modern and accessible mobile platform**.

This application allows students and faculty to:

- Browse the full book catalog  
- Check real-time availability  
- Borrow items via QR code  
- Reserve study rooms and computer stations  
- Manage their entire library account from their smartphone  

The goal is to eliminate physical queues, manual inquiries, and outdated processes.

---

## 📸 Side-by-Side Comparison

### 📱 FlutterFlow Prototype (Left) vs. Native Flutter App (Right)

| FlutterFlow Prototype | Native Flutter Implementation |
|----------------------|------------------------------|
| ![Prototype Screenshot](<img width="233" height="497" alt="FlutterFlow (1)" src="https://github.com/user-attachments/assets/e4e1f883-0dd1-4764-ac20-736396f8322d" />) | ![Native App Screenshot](<img width="223" height="487" alt="FlutterNative (1)" src="https://github.com/user-attachments/assets/389473ce-5e1a-4b72-a8d4-0410294e2093" />)) |
| ![Prototype Screenshot](<img width="222" height="471" alt="FlutterFlow (3)" src="https://github.com/user-attachments/assets/4c925837-858b-4c6d-a920-62c4fb471650" />) | ![Native App Screenshot](<img width="215" height="463" alt="FlutterNative (3)" src="https://github.com/user-attachments/assets/5b378a91-360e-4f0a-9f85-7e3728d38c7b" />) |
| ![Prototype Screenshot](<img width="219" height="542" alt="FlutterFlow (2)" src="https://github.com/user-attachments/assets/a152e62d-31ab-4bce-9e1c-87070424af9f" />) | ![Native App Screenshot](<img width="238" height="528" alt="FlutterNative (2)" src="https://github.com/user-attachments/assets/f82663d4-7014-4264-8e76-bc9e46245ca4" />) |
| ![Prototype Screenshot](<img width="245" height="556" alt="FlutterFlow (4)" src="https://github.com/user-attachments/assets/15ef292e-4875-424f-abee-473ccb5b935d" />) | ![Native App Screenshot](<img width="246" height="554" alt="FlutterNative (4)" src="https://github.com/user-attachments/assets/103f522e-c33b-4fdb-baa1-849db68fed34" />) |


## 🚀 Features

This application includes the following core features:

### 🔐 User Authentication
- Secure login using NTC student credentials  
- Firebase Authentication integration  

### 📚 Book Management Dashboard
- Browse books by category (Computer Science, Natural Science, etc.)  
- “New Arrivals” and “Most Borrowed” sections  

### 🔎 Real-time Search
- Search books by title or author  
- Instant filtering with dynamic UI updates  

### 📘 Digital Borrowing System
- Generate unique QR codes for borrowing books  
- Real-time loan status and availability updates  

### 🏫 Reservation System
- Book **study rooms** or **computer stations**  
- Calendar with logic to prevent double-booking  
  - Reserved slots turn **red/unselectable**  
- Generate reservation tickets with QR codes  

### 📂 My Library
A personalized dashboard containing:

- **Saved Lists** – Create custom book collections  
- **On Borrow** – Track borrowed items, due dates, and penalties  
- **Returned History** – Complete log of returned books  

### 👤 Account Management
- View and edit profile details  
- Manage app settings  

---

## 🛠 How to Run the Application

Follow the steps below to set up and run the project on your machine.

### **Prerequisites**
- Flutter SDK installed  
- IDE (VS Code or Android Studio)  
- Physical device or emulator  

---

## APK you can download the Application 
 - link : https://drive.google.com/file/d/1_PO1JjN0sbqUsO0m9QWIecttlgky64bW/view?usp=drive_link

---

# 📥 Installation

### **1. Clone the Repository**

```bash
git clone https://github.com/your-username/ntc_library.git
cd ntc_library
```

---

### **2. Install Packages**

```bash
flutter pub get
```

---

### **3. Firebase Configuration (If required)**

If your app uses Firebase:

1. Download `google-services.json` from Firebase Console  
2. Place it here:

```
android/app/google-services.json
```

Optional CLI setup:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

### **4. Check for Issues**

```bash
flutter doctor
```

---

# ▶️ Running the Application

## **Option A — Run on Android Emulator**

1. Start your emulator from Android Studio  
2. Run:

```bash
flutter run
```

---

## **Option B — Run on Physical Android Device**

```bash
flutter devices
flutter run
```

---

## **Option C — Run from VS Code**

1. Open the project folder  
2. Select a device (bottom-right)  
3. Press:

```
F5
```

---

## **Option D — Run from Android Studio**

1. Open the project  
2. Select device/emulator  
3. Press **Run ▶️**

---

# 🎉 You're Done!

The NTC Library Mobile App should now launch on your emulator or physical device.

---
## TEAM MEMEBRS

**Student Name:** France Jefferson Sulibio | 422000391  
**Student Name:** Orias, Christian B. | 422000350  
**Student Name:** Elmido, Thea D. | 423000602  

Course Code: PC16  








