# MedTrack AI — System Specification & Documentation

## Table of Contents
1. [Software Requirements Specification (SRS)](#1-software-requirements-specification-srs)
2. [Data Flow Diagram (DFD)](#2-data-flow-diagram-dfd)
3. [Use Case Diagram](#3-use-case-diagram)
4. [Class Diagram](#4-class-diagram)
5. [Technical Documentation](#5-technical-documentation)
6. [API Specification](#6-api-specification)
7. [Database Schema](#7-database-schema)
8. [Security & Privacy](#8-security--privacy)

---

## 1. Software Requirements Specification (SRS)

### 1.1 Introduction

MedTrack AI is a high-fidelity, industrial-grade medication management platform designed to provide users with precision tracking, AI-powered prescription scanning, and predictive health insights. The system prioritizes a minimalist "monochrome" aesthetic while delivering complex data density.

### 1.2 Project Overview

- **Project Name**: MedTrack AI
- **Project Type**: Cross-platform Healthcare Application (Web, Mobile)
- **Core Functionality**: AI-powered medication management with prescription scanning, intake logging, predictive health insights, and inventory tracking
- **Target Users**: Patients, Caregivers, Healthcare Providers, Family Members

### 1.3 Functional Requirements (FR)

#### FR-01: Authentication & Security
| ID | Requirement | Description |
|----|-------------|-------------|
| FR-01.1 | Email/Password Login | Users can authenticate using email and password |
| FR-01.2 | Google OAuth | Users can sign in with Google account |
| FR-01.3 | Apple OAuth | Users can sign in with Apple ID |
| FR-01.4 | User Registration | New users can create an account |
| FR-01.5 | Password Reset | Users can reset forgotten password via email |
| FR-01.6 | Email Verification | Users must verify email address after registration |
| FR-01.7 | OTP Verification | Optional OTP-based authentication for enhanced security |
| FR-01.8 | Two-Factor Authentication (2FA) | Users can enable 2FA for additional security |
| FR-01.9 | Biometric Login | Fingerprint/Face ID authentication on mobile devices |
| FR-01.10 | Logout | Users can securely logout from all devices |

#### FR-02: Pill Scanning (MedScan AI)
| ID | Requirement | Description |
|----|-------------|-------------|
| FR-02.1 | Camera Integration | Access device camera for scanning |
| FR-02.2 | Label Scanning | Scan clinical labels using AI analysis |
| FR-02.3 | Pill Identification | Identify pills by visual characteristics |
| FR-02.4 | Data Extraction | Extract name, dosage, frequency from labels |
| FR-02.5 | Manual Entry | Fallback manual medication entry |
| FR-02.6 | AI Analysis | Google Gemma 4 via OpenRouter for prescription parsing |

#### FR-03: Precision Logging
| ID | Requirement | Description |
|----|-------------|-------------|
| FR-03.1 | Log Intake | Log medication as Adherent, Missed, or Snoozed |
| FR-03.2 | Scheduled Reminders | Receive reminders at scheduled times |
| FR-03.3 | Quick Actions | One-tap logging from notifications |
| FR-03.4 | Historical Log | View intake history by date range |
| FR-03.5 | Notes & Symptoms | Add notes and report symptoms with logs |

#### FR-04: Multi-Profile Management
| ID | Requirement | Description |
|----|-------------|-------------|
| FR-04.1 | Profile Creation | Create managed profiles for dependents |
| FR-04.2 | Profile Switching | Switch between user profiles |
| FR-04.3 | Caregiver Access | Grant caregiver access to profiles |
| FR-04.4 | Profile Permissions | Manage permissions for each profile |
| FR-04.5 | Family Dashboard | View all family members' medication status |

#### FR-05: Predictive Insights
| ID | Requirement | Description |
|----|-------------|-------------|
| FR-05.1 | Body Impact Score | Calculate health impact based on adherence |
| FR-05.2 | AI Coach | Personalized health recommendations |
| FR-05.3 | Adherence Analytics | Track adherence patterns over time |
| FR-05.4 | Streak Tracking | Monitor medication-taking streaks |
| FR-05.5 | Symptom Analysis | AI-powered symptom pattern analysis |

#### FR-06: Inventory Controls
| ID | Requirement | Description |
|----|-------------|-------------|
| FR-06.1 | Pill Count | Track remaining pill count |
| FR-06.2 | Low Stock Alerts | Automated low stock notifications |
| FR-06.3 | Refill Reminders | Reminders to refill prescriptions |
| FR-06.4 | Supply Calculation | Calculate days remaining based on dosage |

#### FR-07: Notifications & Reminders
| ID | Requirement | Description |
|----|-------------|-------------|
| FR-07.1 | Scheduled Notifications | Time-based medication reminders |
| FR-07.2 | Push Notifications | Cross-platform push notifications |
| FR-07.3 | Email Notifications | Important medication alerts via email |
| FR-07.4 | Custom Schedules | Flexible dosing schedules |

### 1.4 Non-Functional Requirements (NFR)

| ID | Requirement | Description | Priority |
|----|-------------|-------------|-----------|
| NFR-01 | High-Fidelity UI | "Cal AI" monochrome design system with glassmorphism and bento-grid layouts | Required |
| NFR-02 | Performance | App must launch and display dashboard in under 2 seconds | Required |
| NFR-03 | Reliability | Offline-first architecture for logging without network | Required |
| NFR-04 | Scalability | Support expansion from logging to clinical trial auditing | Required |
| NFR-05 | Accessibility | WCAG 2.1 AA compliance | Required |
| NFR-06 | Data Privacy | HIPAA-compliant data handling | Required |
| NFR-07 | Cross-Platform | Web, iOS, Android, and Flutter support | Required |

---

## 2. Data Flow Diagram (DFD)

### Level 0: Context Diagram

```mermaid
graph LR
    User((User)) -- "Scans Label / Logs Dose" --> MedTrackAI[MedTrack AI System]
    MedTrackAI -- "Notifications / Health Insights" --> User
    MedTrackAI -- "Medical Data" --> Firebase[(Cloud Storage/DB)]
    Firebase -- "Sync/Auth" --> MedTrackAI
    MedTrackAI -- "AI Analysis" --> OpenRouter[OpenRouter API]
    OpenRouter -- "Analysis Results" --> MedTrackAI
```

### Level 1: Functional DFD

```mermaid
graph TD
    subgraph "Client Layer"
        A[User] -->|Camera Stream| B[MedScan AI Processor]
        A -->|Manual Entry| C[Medication Repository]
    end
    
    subgraph "Application Layer"
        B -->|Extracted Labels| C
        C -->|State Updates| D[AppState Controller]
        D -->|Persistence| E[(Local Database / Prefs)]
        D -->|Sync| F[Cloud Data Source]
        D -->|Uptime/Stats| G[Analytics Engine]
    end
    
    subgraph "AI Layer"
        B -->|Image Analysis| H[OpenRouter API]
        H -->|Gemma 4 Response| B
    end
    
    G -->|Insights| A
```

### Level 2: Authentication Flow

```mermaid
graph TD
    A[User] -->|Credentials| B[Auth Controller]
    B -->|Validate| C[User Repository]
    C -->|Verify| D[(PostgreSQL DB)]
    D -->|User Data| C
    C -->|Auth Result| B
    B -->|JWT Token| A
    
    A -->|OAuth Google| E[Google OAuth]
    E -->|Token| B
    
    A -->|OAuth Apple| F[Apple OAuth]
    F -->|Token| B
    
    A -->|Biometric| G[Biometric Auth]
    G -->|Verify| B
```

### Level 3: Medication Logging Flow

```mermaid
graph TD
    A[User] -->|Select Med| B[Medication Selector]
    B -->|Get Schedule| C[(Redis Cache)]
    C -->|Schedule Data| B
    B -->|Log Action| D[Log Processor]
    D -->|Validate| E[Business Logic]
    E -->|Save| F[(PostgreSQL)]
    F -->|Confirm| D
    D -->|Notify| G[Notification Service]
    G -->|Push| A
    D -->|Update Stats| H[Analytics Engine]
    H -->|Insights| A
```

---

## 3. Use Case Diagram

```mermaid
usecaseDiagram
    actor "Patient / User" as User
    actor "Caregiver" as Caregiver
    actor "AI Engine" as AI
    actor "System" as System
    
    package "Authentication" {
        usecase "Login with Email" as UC1
        usecase "Login with Google" as UC2
        usecase "Login with Apple" as UC3
        usecase "User Registration" as UC4
        usecase "Password Reset" as UC5
        usecase "Email Verification" as UC6
        usecase "Enable 2FA" as UC7
        usecase "Biometric Login" as UC8
        usecase "Logout" as UC9
    }
    
    package "Medication Management" {
        usecase "Scan Prescription" as UC10
        usecase "Add Medication" as UC11
        usecase "Log Intake" as UC12
        usecase "View History" as UC13
        usecase "Manage Inventory" as UC14
    }
    
    package "Profile Management" {
        usecase "Create Profile" as UC15
        usecase "Switch Profile" as UC16
        usecase "Manage Dependents" as UC17
    }
    
    package "Insights & Analytics" {
        usecase "View Adherence Score" as UC18
        usecase "View AI Coach" as UC19
        usecase "View Body Impact" as UC20
    }
    
    package "Notifications" {
        usecase "Set Reminder" as UC21
        usecase "Receive Alert" as UC22
    }
    
    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    User --> UC9
    User --> UC10
    User --> UC11
    User --> UC12
    User --> UC13
    User --> UC14
    User --> UC15
    User --> UC16
    User --> UC17
    User --> UC18
    User --> UC19
    User --> UC20
    User --> UC21
    User --> UC22
    
    Caregiver --> UC16
    Caregiver --> UC17
    
    UC10 ..> AI : <<include>>
    UC18 ..> AI : <<include>>
    UC19 ..> AI : <<include>>
    UC20 ..> AI : <<include>>
```

---

## 4. Class Diagram

### Core Domain Entities

```mermaid
classDiagram
    class User {
        +UUID id
        +String email
        +String passwordHash
        +String firstName
        +String lastName
        +String? phone
        +Boolean emailVerified
        +Boolean twoFactorEnabled
        +Enum authProvider
        +DateTime createdAt
        +DateTime updatedAt
        +validatePassword(password) bool
        +generateJWT() string
    }
    
    class UserProfile {
        +UUID id
        +UUID userId
        +String name
        +Enum profileType
        +DateTime dateOfBirth
        +String? gender
        +String? medicalConditions
        +Boolean isActive
    }
    
    class Medication {
        +UUID id
        +UUID userId
        +String name
        +String genericName
        +String dosage
        +String form
        +String frequency
        +Int pillCount
        +Int refillThreshold
        +String? instructions
        +DateTime startDate
        +DateTime? endDate
        +Boolean isActive
        +checkLowStock() bool
    }
    
    class DoseSchedule {
        +UUID id
        +UUID medicationId
        +Time scheduledTime
        +Enum doseStatus
        +String? notes
    }
    
    class DoseLog {
        +UUID id
        +UUID userId
        +UUID medicationId
        +DateTime scheduledTime
        +DateTime? takenTime
        +Enum intakeStatus
        +String? notes
        +String? symptoms
    }
    
    class Reminder {
        +UUID id
        +UUID userId
        +UUID medicationId
        +DateTime scheduledTime
        +Boolean isActive
        +Enum reminderType
        +Int snoozeCount
    }
    
    class Notification {
        +UUID id
        +UUID userId
        +String title
        +String body
        +Enum notificationType
        +Boolean isRead
        +DateTime sentAt
    }
    
    class AdherenceStats {
        +UUID id
        +UUID userId
        +DateTime date
        +Double adherenceScore
        +Int totalDoses
        +Int takenDoses
        +Int missedDoses
        +Int snoozedDoses
        +Int streakCount
    }
    
    User "1" --> "*" UserProfile : has
    User "1" --> "*" Medication : prescribes
    User "1" --> "*" DoseLog : logs
    Medication "1" --> "*" DoseSchedule : schedules
    Medication "1" --> "*" Reminder : triggers
    DoseLog "*" --> "1" Medication : for
    UserProfile "1" --> "*" AdherenceStats : tracks
```

### Authentication & Security Classes

```mermaid
classDiagram
    class AuthService {
        +login(email, password) AuthResult
        +register(userData) User
        +resetPassword(email) boolean
        +verifyEmail(token) boolean
        +enable2FA(userId) string
        +verify2FA(userId, code) boolean
        +oauthLogin(provider, token) User
        +logout(userId) void
    }
    
    class BiometricService {
        +canAuthenticate() boolean
        +authenticate() Promise~boolean~
        +enroll() Promise~boolean~
    }
    
    class JWTService {
        +generateToken(user) string
        +verifyToken(token) JWTPayload
        +refreshToken(token) string
    }
    
    class OAuthProvider {
        +google: OAuth2Client
        +apple: OAuth2Client
    }
    
    class PasswordHasher {
        +hash(password) string
        +verify(password, hash) boolean
    }
    
    class TwoFactorService {
        +generateSecret() string
        +generateQRCode(secret) string
        +verifyCode(code, secret) boolean
    }
```

### AI & Analytics Classes

```mermaid
classDiagram
    class AIService {
        +analyzePrescription(image) PrescriptionResult
        +identifyPill(image) PillResult
        +generateInsights(userId) Insights
        +analyzeSymptoms(symptoms) SymptomAnalysis
    }
    
    class PrescriptionAnalyzer {
        +extractMedicationName(ocrText) string
        +extractDosage(ocrText) string
        +extractFrequency(ocrText) string
        +extractInstructions(ocrText) string
    }
    
    class AnalyticsEngine {
        +calculateAdherenceScore(userId) number
        +calculateStreak(userId) number
        +generateBodyImpact(userId) BodyImpact
        +generateAICoach(userId) CoachInsights
    }
    
    class NotificationService {
        +sendPush(userId, notification) void
        +sendEmail(userId, email) void
        +scheduleReminder(reminder) void
        +cancelReminder(reminderId) void
    }
    
    class InventoryService {
        +checkLowStock(medicationId) boolean
        +calculateDaysRemaining(medicationId) number
        +updatePillCount(medicationId, count) void
        +sendLowStockAlert(userId, medicationId) void
    }
```

---

## 5. Technical Documentation

### 5.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CLIENT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   Next.js  │  │  Flutter   │  │  Mobile    │  │    Web     │       │
│  │   Web App  │  │   Mobile   │  │   App      │  │   PWA      │       │
│  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘       │
│        │             │             │             │                 │
├────────┼─────────────┼─────────────┼─────────────┼─────────────────┤
│        │        API GATEWAY         │             │                 │
│        └──────────┬───────────────┘             │                 │
│                   │                             │                 │
├──────────────────┼─────────────────────────────┼─────────────────┤
│                  │    APPLICATION LAYER        │                 │
│         ┌────────┴────────┐        ┌─────────┴────────┐          │
│         │  NestJS API    │        │    WebSocket   │          │
│         │   Server      │        │    Server     │          │
│         └───────┬───────┘        └───────┬────────┘          │
│                 │                    │                      │
├─────────────────┼────────────────────┼──────────────────────┤
│                 │   SERVICE LAYER    │                      │
│    ┌────────────┼────────────┐      │                      │
│    │            │             │      │                      │
│ ┌──┴───┐  ┌────┴────┐  ┌────┴────┐│ ┌──┴────┐            │
│ │Auth  │  │ Med     │  │ AI      ││ │Notif  │            │
│ │Svc   │  │ Service │  │ Service ││ │Svc    │            │
│ └──┬───┘  └───┬────┘  └───┬────┘│ └──┬────┘            │
│    │          │           │     │    │                  │
├────┼──────────┼───────────┼─────┼────┼──────────────────┤
│    │     DATA LAYER       │     │    │                  │
│    │   ┌─────────────────┐ │     │    │                  │
│    └───│   Prisma ORM   │◄────┴────┴────              │
│        │  PostgreSQL    │                                      │
│        │     Redis     │                                      │
│        └───────────────┘                                      │
└───────────────────────────────────────────────────────────────┘
```

### 5.2 Tech Stack

#### Backend
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | NestJS | ^10.0.0 |
| Database | PostgreSQL | ^15.0.0 |
| ORM | Prisma | ^5.0.0 |
| Cache | Redis | ^7.0.0 |
| Authentication | Passport.js | ^0.7.0 |
| JWT | jsonwebtoken | ^9.0.0 |
| Validation | class-validator | ^0.14.0 |
| API Documentation | Swagger | ^7.0.0 |
| WebSocket | Socket.io | ^4.7.0 |
| Email | Nodemailer | ^6.9.0 |

#### Frontend (Web)
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Next.js | ^14.0.0 |
| Language | TypeScript | ^5.0.0 |
| UI Library | shadcn/ui | latest |
| Styling | Tailwind CSS | ^3.4.0 |
| State Management | Zustand | ^4.4.0 |
| API Client | Axios | ^1.6.0 |
| Icons | Lucide React | latest |
| Charts | Recharts | ^2.10.0 |

#### Mobile (Flutter)
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | ^3.16.0 |
| Language | Dart | ^3.2.0 |
| State Management | Provider | ^6.1.0 |
| Local Storage | shared_preferences | ^2.2.0 |
| Camera | camera | ^0.10.0 |
| Biometrics | local_auth | ^1.2.0 |
| Notifications | flutter_local_notifications | ^16.3.0 |
| SQLite | sqflite | ^2.3.0 |

#### AI Integration
| Component | Technology | Details |
|-----------|------------|---------|
| AI Provider | OpenRouter API | google/gemma-4-31b-it:free |
| API Key | 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 |
| Model | Google Gemma 4 31B | Free tier, instruction-tuned |

### 5.3 Folder Structure

#### Backend (NestJS)
```
backend/
├── src/
│   ├── auth/
│   │   ├── dto/
│   │   ├── guards/
│   │   ├── strategies/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   └── auth.module.ts
│   ├── users/
│   │   ├── dto/
│   │   ├── entities/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── users.module.ts
│   ├── medications/
│   │   ├── dto/
│   │   ├── entities/
│   │   ├── medications.controller.ts
│   │   ├── medications.service.ts
│   │   └── medications.module.ts
│   ├── dose-logs/
│   │   ├── dto/
│   │   ├── entities/
���   │   ├── dose-logs.controller.ts
│   │   ├── dose-logs.service.ts
│   │   └── dose-logs.module.ts
│   ├── ai/
│   │   ├── ai.controller.ts
│   │   ├── ai.service.ts
│   │   └── ai.module.ts
│   ├── notifications/
│   │   ├── notifications.controller.ts
│   │   ├── notifications.service.ts
│   │   └── notifications.module.ts
│   ├── analytics/
│   │   ├── analytics.controller.ts
│   │   ├── analytics.service.ts
│   │   └── analytics.module.ts
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── prisma.service.ts
│   ├── common/
│   │   ├── decorators/
│   │   ├── filters/
│   │   ├── interceptors/
│   │   └── pipes/
│   ├── config/
│   │   └── configuration.ts
│   ├── app.controller.ts
│   ├── app.service.ts
│   └── main.ts
├── test/
├── prisma/
│   └── schema.prisma
├── .env
├── package.json
├── tsconfig.json
└── nest-cli.json
```

#### Frontend (Next.js)
```
frontend/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   ├── register/
│   │   │   ├── forgot-password/
│   │   │   └── reset-password/
│   │   ├── (dashboard)/
│   │   │   ├── dashboard/
│   │   │   ├── medications/
│   │   │   ├── scan/
│   │   │   ├── history/
│   │   │   ├── insights/
│   │   │   ├── profiles/
│   │   │   └── settings/
│   │   ├── api/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── ui/
│   │   ├── forms/
│   │   ├── charts/
│   │   └── layouts/
│   ├── lib/
│   │   ├── utils.ts
│   │   ├── api.ts
│   │   └── auth.ts
│   ├── hooks/
│   ├── stores/
│   ├── types/
│   ├── styles/
├── public/
├── .env.local
├── package.json
├── tailwind.config.ts
├── tsconfig.json
└── next.config.js
```

#### Mobile (Flutter)
```
mobile/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme/
│   │   ├── constants/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── medications/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── scan/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   ├── history/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   └── insights/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   ├── services/
│   │   ├── api/
│   │   ├── auth/
│   │   ├── ai/
│   │   └── notifications/
│   ├── models/
│   └── widgets/
├── pubspec.yaml
└── ios/
```

### 5.4 Design System (Cal AI Inspired)

#### Color Palette
```css
:root {
  /* Monochrome Base */
  --background: #000000;
  --foreground: #ffffff;
  --card: #0a0a0a;
  --card-foreground: #ffffff;
  --popover: #0a0a0a;
  --popover-foreground: #ffffff;
  --primary: #ffffff;
  --primary-foreground: #000000;
  --secondary: #1a1a1a;
  --secondary-foreground: #ffffff;
  --muted: #1a1a1a;
  --muted-foreground: #737373;
  --accent: #1a1a1a;
  --accent-foreground: #ffffff;
  --destructive: #ff3333;
  --destructive-foreground: #ffffff;
  --border: #262626;
  --input: #262626;
  --ring: #ffffff;
  
  /* Semantic Colors */
  --success: #22c55e;
  --warning: #f59e0b;
  --error: #ef4444;
  --info: #3b82f6;
  
  /* Glassmorphism */
  --glass-background: rgba(255, 255, 255, 0.05);
  --glass-border: rgba(255, 255, 255, 0.1);
  --glass-blur: blur(20px);
}
```

#### Typography
```css
:root {
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  
  /* Font Sizes */
  --text-xs: 0.75rem;     /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;   /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  --text-4xl: 2.25rem;   /* 36px */
  
  /* Font Weights */
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;
}
```

#### Spacing System
```css
:root {
  --spacing-0: 0;
  --spacing-1: 0.25rem;   /* 4px */
  --spacing-2: 0.5rem;    /* 8px */
  --spacing-3: 0.75rem;  /* 12px */
  --spacing-4: 1rem;      /* 16px */
  --spacing-5: 1.25rem;   /* 20px */
  --spacing-6: 1.5rem;   /* 24px */
  --spacing-8: 2rem;      /* 32px */
  --spacing-10: 2.5rem;   /* 40px */
  --spacing-12: 3rem;     /* 48px */
  --spacing-16: 4rem;     /* 64px */
}
```

#### Border Radius
```css
:root {
  --radius-sm: 0.25rem;    /* 4px */
  --radius: 0.5rem;       /* 8px */
  --radius-md: 0.75rem;   /* 12px */
  --radius-lg: 1rem;      /* 16px */
  --radius-xl: 1.5rem;   /* 24px */
  --radius-2xl: 2rem;     /* 32px */
  --radius-full: 9999px;
}
```

#### Shadows
```css
:root {
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
  --shadow-glow: 0 0 20px rgba(255, 255, 255, 0.1);
}
```

---

## 6. API Specification

### 6.1 Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|--------------|
| POST | `/api/auth/register` | Register new user | No |
| POST | `/api/auth/login` | Login with email/password | No |
| POST | `/api/auth/login/google` | Login with Google | No |
| POST | `/api/auth/login/apple` | Login with Apple | No |
| POST | `/api/auth/logout` | Logout user | Yes |
| POST | `/api/auth/forgot-password` | Request password reset | No |
| POST | `/api/auth/reset-password` | Reset password | No |
| POST | `/api/auth/verify-email` | Verify email | No |
| POST | `/api/auth/resend-verification` | Resend verification email | No |
| POST | `/api/auth/enable-2fa` | Enable 2FA | Yes |
| POST | `/api/auth/verify-2fa` | Verify 2FA code | No |
| POST | `/api/auth/disable-2fa` | Disable 2FA | Yes |
| GET | `/api/auth/me` | Get current user | Yes |
| POST | `/api/auth/refresh-token` | Refresh JWT token | Yes |

### 6.2 Medication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|--------------|
| GET | `/api/medications` | List all medications | Yes |
| POST | `/api/medications` | Add new medication | Yes |
| GET | `/api/medications/:id` | Get medication details | Yes |
| PUT | `/api/medications/:id` | Update medication | Yes |
| DELETE | `/api/medications/:id` | Delete medication | Yes |
| POST | `/api/medications/scan` | Scan prescription image | Yes |
| GET | `/api/medications/:id/inventory` | Get inventory status | Yes |
| PUT | `/api/medications/:id/count` | Update pill count | Yes |

### 6.3 Dose Logging Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|--------------|
| GET | `/api/dose-logs` | Get dose logs (with filters) | Yes |
| POST | `/api/dose-logs` | Log medication intake | Yes |
| PUT | `/api/dose-logs/:id` | Update dose log | Yes |
| DELETE | `/api/dose-logs/:id` | Delete dose log | Yes |
| GET | `/api/dose-logs/today` | Get today's logs | Yes |
| GET | `/api/dose-logs/history` | Get log history | Yes |

### 6.4 Profile Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|--------------|
| GET | `/api/profiles` | List profiles | Yes |
| POST | `/api/profiles` | Create profile | Yes |
| GET | `/api/profiles/:id` | Get profile details | Yes |
| PUT | `/api/profiles/:id` | Update profile | Yes |
| DELETE | `/api/profiles/:id` | Delete profile | Yes |
| POST | `/api/profiles/:id/switch` | Switch active profile | Yes |

### 6.5 AI Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|--------------|
| POST | `/api/ai/analyze-prescription` | Analyze prescription image | Yes |
| POST | `/api/ai/identify-pill` | Identify pill from image | Yes |
| GET | `/api/ai/insights` | Get AI insights | Yes |
| POST | `/api/ai/analyze-symptoms` | Analyze symptoms | Yes |

### 6.6 Analytics Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|--------------|
| GET | `/api/analytics/adherence` | Get adherence score | Yes |
| GET | `/api/analytics/streak` | Get streak data | Yes |
| GET | `/api/analytics/body-impact` | Get body impact score | Yes |
| GET | `/api/analytics/ai-coach` | Get AI coach insights | Yes |

### 6.7 Notification Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|--------------|
| GET | `/api/notifications` | List notifications | Yes |
| PUT | `/api/notifications/:id/read` | Mark as read | Yes |
| PUT | `/api/notifications/read-all` | Mark all as read | Yes |
| DELETE | `/api/notifications/:id` | Delete notification | Yes |

---

## 7. Database Schema

### 7.1 Prisma Schema

```prisma
// schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum AuthProvider {
  EMAIL
  GOOGLE
  APPLE
}

enum ProfileType {
  SELF
  DEPENDENT
  CAREGIVER
}

enum IntakeStatus {
  PENDING
  TAKEN
  MISSED
  SNOOZED
}

enum NotificationType {
  REMINDER
  LOW_STOCK
  REFILL
  ADHERENCE
  SYSTEM
}

enum DoseForm {
  TABLET
  CAPSULE
  LIQUID
  INJECTION
  TOPICAL
  INHALER
  OTHER
}

model User {
  id              String      @id @default(uuid())
  email           String      @unique
  passwordHash   String?
  firstName      String
  lastName       String
  phone          String?
  emailVerified  Boolean     @default(false)
  twoFactorEnabled Boolean   @default(false)
  twoFactorSecret String?
  authProvider   AuthProvider @default(EMAIL)
  createdAt      DateTime     @default(now())
  updatedAt      DateTime     @updatedAt
  
  medications    Medication[]
  doseLogs       DoseLog[]
  profiles      UserProfile[]
  reminders     Reminder[]
  notifications Notification[]
  adherenceStats AdherenceStats[]
  
  @@map("users")
}

model UserProfile {
  id                String      @id @default(uuid())
  userId            String
  name              String
  profileType       ProfileType @default(DEPENDENT)
  dateOfBirth      DateTime?
  gender           String?
  medicalConditions String?
  isActive          Boolean     @default(true)
  createdAt         DateTime    @default(now())
  updatedAt         DateTime    @updatedAt
  
  user              User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  adherenceStats  AdherenceStats[]
  
  @@map("user_profiles")
}

model Medication {
  id              String      @id @default(uuid())
  userId         String
  name           String
  genericName    String?
  dosage         String
  form           DoseForm   @default(TABLET)
  frequency      String
  pillCount      Int         @default(0)
  refillThreshold Int        @default(7)
  instructions  String?
  startDate     DateTime    @default(now())
  endDate       DateTime?
  isActive      Boolean    @default(true)
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @updatedAt
  
  user          User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  doseSchedules DoseSchedule[]
  doseLogs      DoseLog[]
  reminders    Reminder[]
  
  @@map("medications")
}

model DoseSchedule {
  id              String      @id @default(uuid())
  medicationId   String
  scheduledTime  String
  doseStatus     IntakeStatus @default(PENDING)
  notes          String?
  createdAt      DateTime    @default(now())
  updatedAt      DateTime    @updatedAt
  
  medication    Medication  @relation(fields: [medicationId], references: [id], onDelete: Cascade)
  
  @@map("dose_schedules")
}

model DoseLog {
  id              String       @id @default(uuid())
  userId          String
  medicationId   String
  scheduledTime  DateTime
  takenTime       DateTime?
  intakeStatus   IntakeStatus @default(PENDING)
  notes          String?
  symptoms       String?
  createdAt       DateTime    @default(now())
  updatedAt      DateTime    @updatedAt
  
  user           User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  medication     Medication  @relation(fields: [medicationId], references: [id], onDelete: Cascade)
  
  @@map("dose_logs")
}

model Reminder {
  id              String           @id @default(uuid())
  userId          String
  medicationId   String
  scheduledTime  DateTime
  isActive       Boolean          @default(true)
  reminderType  NotificationType @default(REMINDER)
  snoozeCount    Int               @default(0)
  createdAt      DateTime         @default(now())
  updatedAt     DateTime         @updatedAt
  
  user           User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  medication    Medication  @relation(fields: [medicationId], references: [id], onDelete: Cascade)
  
  @@map("reminders")
}

model Notification {
  id              String           @id @default(uuid())
  userId          String
  title          String
  body          String
  notificationType NotificationType @default(SYSTEM)
  isRead         Boolean          @default(false)
  sentAt         DateTime         @default(now())
  
  user           User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("notifications")
}

model AdherenceStats {
  id              String      @id @default(uuid())
  userId          String
  date            DateTime    @db.date
  adherenceScore Float
  totalDoses     Int
  takenDoses     Int
  missedDoses    Int
  snoozedDoses    Int
  streakCount    Int
  createdAt      DateTime    @default(now())
  updatedAt      DateTime    @updatedAt
  
  user           User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@unique([userId, date])
  @@map("adherence_stats")
}
```

---

## 8. Security & Privacy

### 8.1 Authentication Security

- **Password Requirements**:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character

- **Password Hashing**: Argon2id algorithm
- **JWT Settings**:
  - Access token expiry: 15 minutes
  - Refresh token expiry: 7 days
  - Algorithm: RS256
- **Rate Limiting**:
  - Login attempts: 5 per 15 minutes
  - API requests: 100 per minute

### 8.2 Data Privacy

- **HIPAA Compliance**:
  - All PHI encrypted at rest (AES-256)
  - All PHI encrypted in transit (TLS 1.3)
  - Audit logging for all data access
  - Automatic session timeout: 15 minutes

- **Data Retention**:
  - Active medications: Until deleted by user
  - Dose logs: 7 years (regulatory requirement)
  - Analytics data: Aggregated, anonymized after 1 year
  - Account deletion: Complete data wipe within 30 days

### 8.3 OAuth Configuration

#### Google OAuth
```
Client ID: Required from Google Cloud Console
Client Secret: Required from Google Cloud Console
Scopes: email, profile
Redirect URI: https://api.medtrack.ai/auth/google/callback
```

#### Apple OAuth
```
Client ID: Required from Apple Developer Portal
Client Secret: Required from Apple Developer Portal
Scope: name, email
Redirect URI: https://api.medtrack.ai/auth/apple/callback
```

### 8.4 Environment Variables

```env
# Backend
DATABASE_URL=postgresql://user:password@localhost:5432/medtrack
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-jwt-secret-key
JWT_PUBLIC_KEY=your-public-key
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
APPLE_CLIENT_ID=your-apple-client-id
APPLE_CLIENT_SECRET=your-apple-client-secret

# AI Integration
OPENROUTER_API_KEY=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

# Frontend
NEXT_PUBLIC_API_URL=https://api.medtrack.ai
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your-google-client-id
```

---

## 9. Implementation Checklist

### Phase 1: Authentication
- [ ] User registration with email verification
- [ ] Email/password login
- [ ] Google OAuth integration
- [ ] Apple OAuth integration
- [ ] Password reset flow
- [ ] JWT token management
- [ ] 2FA setup and verification
- [ ] Biometric authentication (mobile)

### Phase 2: Core Features
- [ ] Medication CRUD operations
- [ ] Dose logging (Adherent/Missed/Snoozed)
- [ ] Medication schedules
- [ ] Reminder notifications
- [ ] Dashboard with adherence score

### Phase 3: AI Integration
- [ ] Prescription image scanning via OpenRouter
- [ ] Medicine identification
- [ ] AI Coach insights
- [ ] Body Impact calculations
- [ ] Symptom analysis

### Phase 4: Profile Management
- [ ] Multi-profile creation
- [ ] Profile switching
- [ ] Caregiver access
- [ ] Family dashboard

### Phase 5: Inventory & Analytics
- [ ] Pill count tracking
- [ ] Low stock alerts
- [ ] Adherence analytics
- [ ] Streak tracking
- [ ] Historical reports

---

## Appendix A: API Response Formats

### Success Response
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com"
  },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "AUTH_INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  }
}
```

### Paginated Response
```json
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

---

## Appendix B: WebSocket Events

### Events
| Event | Direction | Description |
|-------|-----------|-------------|
| `dose:logged` | Server → Client | When dose is logged |
| `reminder:triggered` | Server → Client | When reminder fires |
| `inventory:low` | Server → Client | When stock is low |
| `profile:updated` | Server → Client | When profile updates |

---

*Document Version: 1.0*  
*Last Updated: 2026-04-10*  
*Author: MedTrack AI Team*