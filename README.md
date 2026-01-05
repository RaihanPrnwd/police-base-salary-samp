---------------------------------
# Sistem Gaji Pokok Polisi untuk SA-MP
*A Pawn script for Police Base Salary System on SAMP roleplay servers*

## 🇮🇩 Bahasa Indonesia

Sistem ini mengatur pemberian gaji pokok kepada anggota polisi berdasarkan pangkat (1-5).
- Gaji diberikan setiap 1 jam saat On Duty (anti-abuse interval).
- Informasi lengkap ditampilkan dalam dialog saat klaim gaji.
- Timer reset otomatis setiap Off Duty.

### Fitur
- Gaji otomatis per jam sesuai pangkat.
- Anti-spam: Tidak bisa klaim gaji berkali-kali sebelum 1 jam.
- Informasi detail: nama user, RP, pangkat, masa dinas, status duty.
- Bisa dipasang di timer otomatis/payday atau command.

### Cara Pasang
1. Copy Gapok.pwn ke folder script/server Anda.
2. #include script ini di gamemode.
3. Panggil `Polisi_BeriGapok(playerid)` dari timer/dialog/command.
4. Konfigurasi sesuai kebutuhan server Anda.

## 🇬🇧 English

This script handles police salary payments based on rank (1-5).
- Salary is paid every hour while On Duty (anti-abuse interval).
- Full info shown in dialog when claiming.
- Timer resets automatically when going Off Duty.

### Features
- Automatic hourly payment by rank.
- Anti-abuse: cannot claim more than once per interval.
- Shows user/rp name, rank, service days, duty status.
- Easy to use in periodic timer/payday or manual command.

### How to Use
1. Copy Gapok.pwn to your script/server folder.
2. #include this script in your gamemode.
3. Call `Polisi_BeriGapok(playerid)` from timers/dialog/command.
4. Customize as needed for your server.

## Author
Raihan Purnawadi  
https://github.com/RaihanPrnwd

---------------------------------

.gitignore template for Pawn:
```
*.amx
compiler/
*.o
*.out
*.exe
```

Use these settings and bilingual README when creating your Github repository for Gapok.pwn.
