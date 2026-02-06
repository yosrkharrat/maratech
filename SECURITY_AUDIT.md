# 🔒 Security Audit Report — Running Club Tunis (RCT)

**Date**: 2025  
**Auditor**: Automated Code Review  
**Application**: RCT Mobile App (Flutter + Firebase)  
**Version**: 1.0

## 📋 Executive Summary

This report covers a comprehensive security review of the RCT mobile application codebase. The application uses Flutter (Dart) for the frontend and Firebase (Auth, Firestore, Storage, FCM) for the backend. The audit evaluates authentication, authorization, data validation, secure storage, network security, and Firebase security rules.

**Overall Risk Level**: 🟡 MODERATE (with mitigations in place)

---

## 1. Authentication & Authorization

### ✅ Strengths
| # | Finding | Status |
|---|---------|--------|
| 1 | Firebase Auth used for all user sessions | ✅ Secure |
| 2 | Role-based access control (5 roles) enforced at service layer | ✅ Implemented |
| 3 | Visitor mode has no write access (read-only) | ✅ Secure |
| 4 | Admin operations require role checks before execution | ✅ Implemented |
| 5 | `updateProfile()` blocks changes to `role`, `password`, `isActive` | ✅ Secure |

### ⚠️ Recommendations
| # | Issue | Severity | Recommendation |
|---|-------|----------|----------------|
| 1 | 3-digit CIN password is weak (1000 combinations) | 🔴 HIGH | Consider adding rate limiting on Firebase Auth, or using Firebase App Check to prevent brute force attacks |
| 2 | No account lockout after failed attempts | 🟡 MEDIUM | Implement Cloud Function to track failed login attempts and lock accounts after 5 failures |
| 3 | No 2FA/MFA support | 🟡 MEDIUM | Consider adding phone verification for admin accounts |
| 4 | Session tokens stored by Firebase SDK | ✅ OK | Firebase handles token refresh and expiry automatically |

### 🔧 Mitigations Applied
- `AuthService.login()` sanitizes input (trims whitespace)
- Firebase Auth handles session management and token refresh
- CIN password is never stored in plaintext (Firebase Auth handles hashing)
- Role validation checks exist at both service and Firestore rules level

---

## 2. Firestore Security Rules

### ✅ Implemented Rules
| Collection | Read | Write | Notes |
|-----------|------|-------|-------|
| `/users/{uid}` | Public | Owner (restricted) / Admin | Users cannot change their own role |
| `/events/{id}` | Public | Admin create/delete, users can update participation only | Field-level restriction on participation updates |
| `/events/{id}/media` | Public | Auth users (own uploads only) | `uploadedBy` must match auth UID |
| `/events/{id}/notes` | Public | Auth users (own notes only) | `authorId` must match auth UID |
| `/events/{id}/comments` | Public | Auth users (own comments only) | Author validation enforced |
| `/events/{id}/classement` | Public | Auth users | Rankings auto-computed |
| `/strava_tokens/{uid}` | Owner only | Owner only | Private token storage |
| `/fcm_tokens` | Admin read | Auth users (own tokens only) | Push notification tokens |
| `/{other}` | Denied | Denied | Default deny rule |

### ⚠️ Recommendations
| # | Issue | Severity | Recommendation |
|---|-------|----------|----------------|
| 1 | No rate limiting on Firestore writes | 🟡 MEDIUM | Implement Cloud Functions to throttle write operations |
| 2 | Media upload size not validated in rules | 🟡 MEDIUM | Storage rules validate but Firestore metadata doesn't double-check |
| 3 | `viewCount` can be incremented by any auth user | 🟢 LOW | Acceptable risk, consider Cloud Function for accurate counting |

---

## 3. Data Validation & Input Sanitization

### ✅ Client-Side Validation
| Location | Validation | Status |
|----------|-----------|--------|
| Login form | Name ≥ 2 chars, CIN = 3 digits | ✅ |
| Event create | Title, location, description required | ✅ |
| Event create | Distance as numeric only | ✅ |
| Media upload | File type check (image/video) | ✅ |
| Media upload | Max resolution 1920px, quality 80% | ✅ |
| Media caption | Max 200 characters | ✅ |
| User creation | Name required, CIN = 3 digits | ✅ |

### ✅ Server-Side Validation (Firestore Rules)
| Validation | Status |
|-----------|--------|
| Event title max 200 chars | ✅ |
| `uploadedBy` matches auth UID | ✅ |
| `authorId` matches auth UID | ✅ |
| Role changes blocked for non-admins | ✅ |
| User can only modify allowed fields | ✅ |

### ⚠️ Recommendations
| # | Issue | Severity | Recommendation |
|---|-------|----------|----------------|
| 1 | No HTML/XSS sanitization in text fields | 🟡 MEDIUM | Add XSS filtering for description, notes, comments before Firestore write |
| 2 | URLs in user content not validated | 🟢 LOW | Consider URL validation for link safety |

---

## 4. Secure Storage & Secrets

### ✅ Strengths
| # | Finding | Status |
|---|---------|--------|
| 1 | Strava tokens stored via `FlutterSecureStorage` (Keychain/Keystore) | ✅ Secure |
| 2 | Strava Client Secret in constants (needs improvement) | ⚠️ See below |
| 3 | Firebase credentials handled by FlutterFire CLI | ✅ OK |
| 4 | No hardcoded API keys in Dart source (use env/config) | ⚠️ See below |

### ⚠️ Recommendations
| # | Issue | Severity | Recommendation |
|---|-------|----------|----------------|
| 1 | Strava client ID/secret in `app_constants.dart` | 🔴 HIGH | Move to environment variables or remote config. Use `--dart-define` or `flutter_dotenv` |
| 2 | Firebase options contain API keys | 🟢 LOW | This is expected behavior per Firebase docs; restrict API keys in Google Cloud Console |

### 🔧 Recommended Fix for Strava Secrets
```dart
// Instead of hardcoding in app_constants.dart:
// Use --dart-define at build time:
// flutter build apk --dart-define=STRAVA_CLIENT_ID=xxx --dart-define=STRAVA_CLIENT_SECRET=yyy
static const stravaClientId = String.fromEnvironment('STRAVA_CLIENT_ID');
static const stravaClientSecret = String.fromEnvironment('STRAVA_CLIENT_SECRET');
```

---

## 5. Network Security

### ✅ Strengths
| # | Finding | Status |
|---|---------|--------|
| 1 | All Firebase communication uses TLS/HTTPS | ✅ Secure |
| 2 | Strava API uses HTTPS | ✅ Secure |
| 3 | OAuth 2.0 flow for Strava authentication | ✅ Standard |
| 4 | Token refresh handled before API calls | ✅ Implemented |

### ⚠️ Recommendations
| # | Issue | Severity | Recommendation |
|---|-------|----------|----------------|
| 1 | No certificate pinning | 🟡 MEDIUM | Consider adding SSL pinning for Strava API calls |
| 2 | No request timeout configured on Dio | 🟢 LOW | Add timeout: `dio.options.connectTimeout = Duration(seconds: 10)` |

---

## 6. Privacy & Data Protection

### ✅ Compliance Measures
| # | Measure | Status |
|---|---------|--------|
| 1 | Strava tokens scoped to `activity:read_all` | ✅ Minimal scope |
| 2 | User data not shared with third parties | ✅ |
| 3 | Media uploads attributed to authenticated users | ✅ |
| 4 | Strava disconnect removes stored tokens | ✅ |
| 5 | User deletion available to admins | ✅ |

### ⚠️ GDPR Considerations
| # | Item | Status |
|---|------|--------|
| 1 | Right to deletion (admin can delete users) | ✅ |
| 2 | Data export feature | ❌ Not implemented |
| 3 | Privacy policy display | ❌ Not implemented |
| 4 | Consent for data collection | ❌ Not implemented |

---

## 7. Accessibility Security

| # | Finding | Status |
|---|---------|--------|
| 1 | Semantic labels don't expose sensitive data | ✅ |
| 2 | Password field uses `obscureText: true` | ✅ |
| 3 | Screen reader announces form errors | ✅ |
| 4 | No sensitive data in accessibility announcements | ✅ |

---

## 8. Dependency Security

### Key Dependencies Audit
| Package | Risk | Notes |
|---------|------|-------|
| firebase_core/auth/firestore | 🟢 LOW | Google-maintained, actively updated |
| flutter_riverpod | 🟢 LOW | Popular, well-maintained |
| go_router | 🟢 LOW | Google-maintained |
| dio | 🟢 LOW | Popular HTTP client, actively maintained |
| flutter_secure_storage | 🟢 LOW | Uses platform Keychain/Keystore |
| image_picker | 🟢 LOW | Google-maintained |
| url_launcher | 🟢 LOW | Google-maintained |
| hive_flutter | 🟡 MEDIUM | Local data is not encrypted by default |

### ⚠️ Recommendations
| # | Issue | Recommendation |
|---|-------|----------------|
| 1 | Hive stores preferences in plaintext | Use `HiveAesCipher` for sensitive local data |
| 2 | Run `dart pub outdated` regularly | Keep dependencies updated |
| 3 | Consider `flutter_dotenv` for secrets | Don't commit `.env` files |

---

## 9. Summary of Action Items

### 🔴 Critical (Fix Before Production)
1. Move Strava client credentials to environment variables (`--dart-define`)
2. Implement rate limiting for login attempts (Cloud Function)

### 🟡 Important (Fix Soon)
3. Add XSS sanitization for user-generated text content
4. Implement SSL pinning for Strava API
5. Add privacy policy and consent screens
6. Encrypt Hive local storage with `HiveAesCipher`

### 🟢 Nice to Have
7. Add data export feature for GDPR compliance
8. Implement 2FA for admin accounts
9. Add request timeouts to Dio client
10. Consider Firebase App Check for additional protection

---

## 10. Conclusion

The RCT application implements a **solid security foundation** with:
- Firebase Authentication for session management
- Comprehensive Firestore security rules with role-based access
- Secure token storage for Strava integration
- Input validation at both client and server level
- HTTPS for all network communications

The primary concerns are the **weak 3-digit password** (inherent to the club's requirement) and **hardcoded API credentials**. With the recommended mitigations, the application can be deployed with an acceptable security posture for a running club management platform.

---

*End of Security Audit Report*
