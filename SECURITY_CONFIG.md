# Secure API Configuration Guide

This guide explains how to configure API keys securely for the Personify app.

## Environment Setup

### Local Development

1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your actual API keys:
   ```bash
   GEMINI_API_KEY=your_actual_gemini_api_key
   SUPABASE_URL=your_actual_supabase_url  
   SUPABASE_ANON_KEY=your_actual_supabase_anon_key
   ```

3. Run the app with environment variables:
   ```bash
   flutter run --dart-define-from-file=.env
   ```

### Production Build

For production builds, use dart-define flags:

```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_key \
                  --dart-define=SUPABASE_URL=your_url \
                  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### CI/CD (GitHub Actions)

Add secrets to your GitHub repository:
1. Go to Settings > Secrets and Variables > Actions
2. Add these secrets:
   - `GEMINI_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

Example GitHub Actions workflow:
```yaml
- name: Build APK
  run: |
    flutter build apk --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }} \
                      --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
                      --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

## Security Notes

- ❌ Never commit `.env` files to Git
- ❌ Never hardcode API keys in source code  
- ✅ Always use environment variables or dart-define
- ✅ Use different keys for development/production
- ✅ Rotate keys regularly
- ✅ Limit API key permissions to minimum required

## Verification

The app will throw an error on startup if required configuration is missing. Check the console for configuration errors.
