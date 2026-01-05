/*
========================================================
 SISTEM GAJI POKOK POLISI - POLICE BASE SALARY SYSTEM 
========================================================

Dibuat oleh: Raihan Purnawadi

Penjelasan Singkat (Bahasa Indonesia):
--------------------------------------
- Sistem ini mengatur pemberian gaji pokok kepada anggota polisi berdasarkan pangkat mereka (1-5).
- Gaji diberikan dalam nominal dollar kecil, dengan interval waktu 1 jam setiap anggota polisi berada dalam status "On Duty".
- Gaji TIDAK dapat diambil berkali-kali dalam waktu kurang dari 1 jam (anti-spam).
- Sistem akan mereset waktu klaim gaji terakhir setiap kali player "Off Duty".
- Informasi lengkap seperti nama user, nama roleplay, pangkat, masa dinas, dan status duty akan ditampilkan pada dialog MSG saat proses ambil gaji.
- Fungsi utama: Polisi_BeriGapok(playerid).

Detail Explanation (English):
-----------------------------
- Created by: Raihan Purnawadi
- This system manages base salary payment for police officers based on their ranks (1-5).
- Salary amount is small (dollars), given every hour when an officer is "On Duty" (1 hour interval).
- The payment can't be claimed again until a full hour has passed (anti abuse).
- Timer for salary claim is reset each time player goes Off Duty.
- Complete info such as username, RP name, police id, rank, service days, and duty status is shown in a dialog MSG at paytime.
- Main function: Polisi_BeriGapok(playerid).

----------------------------------------------
 KONSTANTA & VARIABEL [CONSTANTS & VARIABLES]
----------------------------------------------
*/
// Nominal gaji pokok per pangkat (Base salary per rank)
#define POLISI_GAJI_PANGKAT_1      200
#define POLISI_GAJI_PANGKAT_2      300
#define POLISI_GAJI_PANGKAT_3      400
#define POLISI_GAJI_PANGKAT_4      500
#define POLISI_GAJI_PANGKAT_5      650

// Dialog ID untuk info gaji pokok (Dialog ID for salary info)
#define DIALOG_POLISI_GAPOK        9610

// Interval pemberian gaji pokok dalam detik (Interval in seconds, 1 hour = 3600)
static const GajiPokok_Interval = MASADINAS_TIMER_INTERVAL / 1000;
new Polisi_LastGapokTime[MAX_PLAYERS]; // Waktu terakhir klaim gaji untuk setiap player (Last claim time per player)

//--------------------------------------------------------------
// 1. FUNGSI RESET TIMER SAAT OFF DUTY
//--------------------------------------------------------------
/*
    Fungsi: Polisi_ResetGapokTimer
    Kegunaan: Mengatur ulang (reset) waktu terakhir klaim gaji ke nol
    Kapan dipakai: Ketika player menjadi Off Duty, agar gaji hanya bisa diambil setelah On Duty kembali selama minimal 1 jam.

    Function: Polisi_ResetGapokTimer
    Purpose: Resets last salary claim time to zero
    Usage: When player goes Off Duty, so salary can only be reclaimed after next On Duty session (at least 1 hour)
*/
stock Polisi_ResetGapokTimer(playerid)
{
    Polisi_LastGapokTime[playerid] = 0;
}

//--------------------------------------------------------------
// 2. FUNGSI MENDAPATKAN NOMINAL GAJI BERDASARKAN PANGKAT
//--------------------------------------------------------------
/*
    Fungsi: GetPolisiGapok
    Kegunaan: Mengembalikan nilai nominal gaji pokok sesuai pangkat polisi (1-5)
    Jika pangkat di luar range, return 0.

    Function: GetPolisiGapok
    Purpose: Returns the amount of base salary for the given police rank (1-5)
    Returns 0 if rank is out of range.
*/
stock GetPolisiGapok(pangkat)
{
    switch (pangkat)
    {
        case 1: return POLISI_GAJI_PANGKAT_1;
        case 2: return POLISI_GAJI_PANGKAT_2;
        case 3: return POLISI_GAJI_PANGKAT_3;
        case 4: return POLISI_GAJI_PANGKAT_4;
        case 5: return POLISI_GAJI_PANGKAT_5;
        default: return 0;
    }
    return 0; // Pawn warning fix (not used, safety/fallback)
}

//--------------------------------------------------------------
// 3. FUNGSI UTAMA PEMBERIAN GAJI POKOK POLISI
//--------------------------------------------------------------
/*
    Fungsi: Polisi_BeriGapok
    - Memberikan gaji pokok kepada player berdasarkan status on duty dan interval waktu.
    - Menampilkan dialog dengan info gaji pokok. Jika belum memenuhi syarat, akan muncul pesan kenapa gaji tidak diterima.
    - Dapat dipanggil dari payday polisi, timer (lihat MasaDinas.pwn), maupun perintah khusus.
    - Akan menolak jika:
        a) Bukan polisi (pangkat < 1)
        b) Player Off Duty
        c) Belum 1 jam sejak terakhir klaim gaji

    Function: Polisi_BeriGapok
    - Gives police salary based on duty status and interval limit.
    - Displays dialog with full salary info. If conditions not met, an info message will be shown.
    - Can be called by police payday, periodic timer (see MasaDinas.pwn), or manual command.
    - Will reject if:
        a) Not a police (rank < 1)
        b) Player Off Duty
        c) Less than 1 hour since last claim
*/
stock Polisi_BeriGapok(playerid)
{
    // [A] Validasi: hanya untuk polisi aktif (Validation: only for police with rank)
    if (PolisiInfo[playerid][Pol_Pangkat] < 1)
        return 0;

    // [B] Siapkan variabel pangkat dan gaji (Prepare rank and salary)
    new pangkat = PolisiInfo[playerid][Pol_Pangkat];
    if (pangkat < 1 || pangkat > 5)
        pangkat = 1; // fallback jika data error
    new gaji = GetPolisiGapok(pangkat);

    // [C] Ambil string masa dinas (Get service duration string)
    new masaDinasStr[64];
    Format_MasaDinasEx(PolisiInfo[playerid][Pol_MasaDinas], masaDinasStr, sizeof(masaDinasStr));

    // [D] Siapkan dialog buffer (Prepare dialog buffer)
    new dialogmsg[480];

    // -------------------------------------------------------------
    // [E] Jika status OFF DUTY: tampilkan dialog "tidak dapat gaji"
    // -------------------------------------------------------------
    if (PolisiInfo[playerid][Pol_Duty] == 0)
    {
        format(dialogmsg, sizeof(dialogmsg),
            "{CBF886}[Polisi] Gaji Pokok Tidak Diterima\n\n"\
            "{FFFFFF}Nama User: {C9E265}%s\n"\
            "{FFFFFF}Nama RP: {C9E265}%s\n"\
            "{FFFFFF}UserID: {6BCDFD}%d\n"\
            "{FFFFFF}ID Polisi: {6BCDFD}%d\n"\
            "{FFFFFF}Pangkat: {FFD643}%d\n"\
            "{FFFFFF}Masa Dinas: {A2ECE1}%s\n"\
            "{FFFFFF}Duty: {BF8BFF}Off Duty\n"\
            "\n"\
            "{FFFFFF}Gaji Pokok: {FFB62B}$0\n\n"\
            "{C73E3E}> Anda tidak bisa menerima gaji pokok karena sedang Off Duty.\n"\
            "{AFAFAF}*) Silakan On Duty untuk dapat mengambil gaji pokok.",
            PolisiInfo[playerid][Pol_UserName],
            PolisiInfo[playerid][Pol_Name],
            PolisiInfo[playerid][Pol_UserID],
            PolisiInfo[playerid][Pol_ID],
            pangkat,
            masaDinasStr
        );
        ShowPlayerDialog(playerid, DIALOG_POLISI_GAPOK, DIALOG_STYLE_MSGBOX, "{2EB6FF}Penerimaan Gaji Pokok Polisi", dialogmsg, "Tutup", "");
        PlayerPlaySound(playerid, 1053, 0.0, 0.0, 0.0);
        return 0;
    }

    // ---------------------------------------------------------------------------
    // [F] Cek interval waktu ambil gaji (anti-spam), wajib tunggu 1 jam on duty
    // ---------------------------------------------------------------------------
    new now = gettime();
    if (Polisi_LastGapokTime[playerid] > 0 && (now - Polisi_LastGapokTime[playerid]) < GajiPokok_Interval)
    {
        new menitTunggu = floatround(float(GajiPokok_Interval - (now - Polisi_LastGapokTime[playerid])) / 60.0, floatround_ceil);

        format(dialogmsg, sizeof(dialogmsg),
            "{CBF886}[Polisi] Gaji Pokok Tidak Diterima\n\n"\
            "{FFFFFF}Nama User: {C9E265}%s\n"\
            "{FFFFFF}Nama RP: {C9E265}%s\n"\
            "{FFFFFF}UserID: {6BCDFD}%d\n"\
            "{FFFFFF}ID Polisi: {6BCDFD}%d\n"\
            "{FFFFFF}Pangkat: {FFD643}%d\n"\
            "{FFFFFF}Masa Dinas: {A2ECE1}%s\n"\
            "{FFFFFF}Duty: {BF8BFF}On Duty\n"\
            "\n"\
            "{FFFFFF}Gaji Pokok: {FFB62B}$0\n\n"\
            "{FFD700}Belum bisa menerima gaji pokok: tunggu %d menit lagi.",
            PolisiInfo[playerid][Pol_UserName],
            PolisiInfo[playerid][Pol_Name],
            PolisiInfo[playerid][Pol_UserID],
            PolisiInfo[playerid][Pol_ID],
            pangkat,
            masaDinasStr,
            menitTunggu
        );
        ShowPlayerDialog(playerid, DIALOG_POLISI_GAPOK, DIALOG_STYLE_MSGBOX, "{2EB6FF}Penerimaan Gaji Pokok Polisi", dialogmsg, "Tutup", "");
        PlayerPlaySound(playerid, 1053, 0.0, 0.0, 0.0);
        return 0;
    }

    // -------------------------------------------------------------
    // [G] Berikan gaji (Give Salary) dan update waktu klaim terakhir
    // -------------------------------------------------------------
    Polisi_LastGapokTime[playerid] = now;
    GivePlayerMoney(playerid, gaji);

    format(dialogmsg, sizeof(dialogmsg),
        "{CBF886}[Polisi] Gaji Pokok Diterima\n\n"\
        "{FFFFFF}Nama User: {C9E265}%s\n"\
        "{FFFFFF}Nama RP: {C9E265}%s\n"\
        "{FFFFFF}UserID: {6BCDFD}%d\n"\
        "{FFFFFF}ID Polisi: {6BCDFD}%d\n"\
        "{FFFFFF}Pangkat: {FFD643}%d\n"\
        "{FFFFFF}Masa Dinas: {A2ECE1}%s\n"\
        "{FFFFFF}Duty: {BF8BFF}On Duty\n"\
        "\n"\
        "{FFFFFF}Gaji Pokok: {FFB62B}$%d\n\n"\
        "{AFAFAF}*) Gaji pokok hanya dapat diambil 1x setiap %d jam On Duty.",
        PolisiInfo[playerid][Pol_UserName],
        PolisiInfo[playerid][Pol_Name],
        PolisiInfo[playerid][Pol_UserID],
        PolisiInfo[playerid][Pol_ID],
        pangkat,
        masaDinasStr,
        gaji,
        (GajiPokok_Interval / 3600)
    );
    ShowPlayerDialog(playerid, DIALOG_POLISI_GAPOK, DIALOG_STYLE_MSGBOX, "{2EB6FF}Penerimaan Gaji Pokok Polisi", dialogmsg, "Tutup", "");
    PlayerPlaySound(playerid, 5205, 0.0, 0.0, 0.0);

    return 1;
}

/*
-------------------------------------------------------------
   END OF FILE - Gaji Pokok Polisi (Police Base Salary)
   Dibuat oleh: Raihan Purnawadi
   Maintained for: https://github.com/RaihanPrnwd
   Versi dokumentasi: Indonesia & English
-------------------------------------------------------------
*/
