"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateItinerary = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const geminiApiKey = (0, params_1.defineSecret)("GEMINI_API_KEY");
const ACTIVE_MODEL = "gemini-2.5-flash";
function buildPrompt(data) {
    const destination = (data.destination || "").trim();
    const durationDays = data.durationDays || 3;
    const nights = durationDays - 1 > 0 ? durationDays - 1 : 1;
    const dates = data.dates || "";
    const companion = data.companion || "Solo";
    const peopleCount = data.peopleCount || 1;
    const hasChildren = !!data.hasChildren;
    const hasElderly = !!data.hasElderly;
    const styles = Array.isArray(data.styles) ? data.styles.join(", ") : "Alam, Kuliner";
    const budget = data.budget || "Menengah";
    const budgetCeiling = data.budgetCeiling || 0;
    const pace = data.pace || "Seimbang";
    const accommodation = data.accommodation || "Hotel";
    const specialNeeds = (data.specialNeeds || "").trim();
    const companionDetails = [companion];
    if (peopleCount > 1)
        companionDetails.push(`${peopleCount} orang`);
    if (hasChildren)
        companionDetails.push("ada anak-anak");
    if (hasElderly)
        companionDetails.push("ada lansia");
    const companionText = companionDetails.join(" (");
    const budgetStr = budgetCeiling > 0
        ? `Rp ${budgetCeiling.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".")}`
        : `Sesuai level ${budget}`;
    return `Anda adalah Tride AI Itinerary Planner, pakar perencana perjalanan wisata profesional terkemuka di Indonesia.
Buatkan rencana perjalanan (itinerary) yang sangat spesifik, terperinci, realistis, dan informatif dalam format JSON murni.

PARAMETER PERJALANAN:
- Destinasi: ${destination}
- Durasi: ${durationDays} Hari (${nights} Malam)
- Rentang Tanggal: ${dates}
- Pendamping: ${companionText}${companionDetails.length > 1 ? ")" : ""}
- Gaya Perjalanan: ${styles}
- Level Budget: ${budget} (Pagu: ${budgetStr})
- Ritme Perjalanan: ${pace}
- Preferensi Akomodasi: ${accommodation}
${specialNeeds ? `- Catatan Khusus / Kebutuhan Tambahan: ${specialNeeds}` : ""}

PETUNJUK OUTPUT WAJIB:
Respond HANYA dengan JSON valid (TANPA kode markdown \`\`\`json, TANPA teks tambahan di luar JSON).

Wajib sertakan nama tempat/destinasi yang nyata dan spesifik di ${destination}, waktu kegiatan, deskripsi kegiatan yang detail, serta tips/rekomendasi biaya/spot foto.

Struktur JSON wajib:
{
  "destination": "${destination}",
  "duration": "${durationDays} Hari ${nights} Malam",
  "styles": "${Array.isArray(data.styles) ? data.styles.join(" & ") : styles}",
  "schedule": [
    {
      "day": "Hari 1",
      "title": "Judul Tema Hari 1 (contoh: Eksplorasi Ikonik Danau & Kawah)",
      "activities": [
        {
          "time": "09:00 - 11:30",
          "location": "Nama Tempat / Destinasi Spesifik di ${destination}",
          "title": "Judul Aktivitas Utama",
          "description": "Penjelasan detail kegiatan yang dilakukan di lokasi ini.",
          "tips": "Tips kunjungan, estimasi budget, atau spot foto."
        }
      ]
    }
  ]
}

Pastikan list "schedule" mencakup tepat ${durationDays} elemen (Hari 1 hingga Hari ${durationDays}). Setiap hari berisi 3-5 kegiatan terperinci dengan nama tempat asli di ${destination}.`;
}
function validateAndFormatItinerary(parsed, destination, durationDays, styles) {
    if (!parsed || typeof parsed !== "object") {
        throw new https_1.HttpsError("invalid-argument", "INVALID_AI_RESPONSE: Format respon AI tidak berupa JSON object.");
    }
    const dest = parsed.destination || destination;
    const durationText = parsed.duration || `${durationDays} Hari ${durationDays - 1 > 0 ? durationDays - 1 : 1} Malam`;
    const stylesText = parsed.styles || (Array.isArray(styles) ? styles.join(" & ") : "Wisata");
    if (!Array.isArray(parsed.schedule) || parsed.schedule.length === 0) {
        throw new https_1.HttpsError("invalid-argument", "INVALID_AI_RESPONSE: Response AI tidak memiliki daftar jadwal ('schedule').");
    }
    const formattedSchedule = [];
    for (let i = 0; i < durationDays; i++) {
        const dayNumber = i + 1;
        if (i < parsed.schedule.length && parsed.schedule[i] && typeof parsed.schedule[i] === "object") {
            const item = parsed.schedule[i];
            const rawActivities = Array.isArray(item.activities) ? item.activities : [];
            const formattedActivities = [];
            for (let aIdx = 0; aIdx < rawActivities.length; aIdx++) {
                const act = rawActivities[aIdx];
                if (act && typeof act === "object") {
                    formattedActivities.push({
                        time: act.time ? String(act.time) : defaultTimeSlot(aIdx),
                        location: act.location ? String(act.location) : dest,
                        title: act.title ? String(act.title) : (act.description ? String(act.description) : `Aktivitas ${aIdx + 1}`),
                        description: act.description ? String(act.description) : (act.title ? String(act.title) : "Eksplorasi spot populer"),
                        tips: act.tips ? String(act.tips) : null,
                    });
                }
                else if (act) {
                    const actStr = String(act);
                    formattedActivities.push({
                        time: defaultTimeSlot(aIdx),
                        location: dest,
                        title: actStr,
                        description: actStr,
                        tips: null,
                    });
                }
            }
            formattedSchedule.push({
                day: item.day ? String(item.day) : `Hari ${dayNumber}`,
                title: item.title ? String(item.title) : `Eksplorasi Hari ${dayNumber}`,
                activities: formattedActivities.length > 0
                    ? formattedActivities
                    : [{
                            time: "10:00 - 15:00",
                            location: `Destinasi Wisata Pilihan di ${dest}`,
                            title: "Eksplorasi Bebas & Rekreasi",
                            description: `Menikmati suasana santai di tempat wisata favorit daerah ${dest}.`,
                            tips: "Sesuaikan dengan preferensi pribadi Anda.",
                        }],
            });
        }
        else {
            formattedSchedule.push({
                day: `Hari ${dayNumber}`,
                title: `Eksplorasi Hari ${dayNumber}`,
                activities: [{
                        time: "10:00 - 15:00",
                        location: `Destinasi Wisata Pilihan di ${dest}`,
                        title: "Eksplorasi Bebas & Rekreasi",
                        description: `Menikmati suasana santai di tempat wisata favorit daerah ${dest}.`,
                        tips: "Sesuaikan dengan preferensi pribadi Anda.",
                    }],
            });
        }
    }
    return {
        destination: dest,
        duration: durationText,
        styles: stylesText,
        schedule: formattedSchedule,
        isAiGenerated: true,
        generated_by: "gemini",
        source: `Google Gemini AI (${ACTIVE_MODEL} via Firebase Cloud Functions)`,
    };
}
function defaultTimeSlot(index) {
    const slots = ["08:30 - 11:00", "11:30 - 14:00", "15:00 - 18:00", "19:00 - 21:00"];
    return index < slots.length ? slots[index] : "Flexi Time";
}
exports.generateItinerary = (0, https_1.onCall)({
    region: "asia-southeast1",
    secrets: [geminiApiKey],
    enforceAppCheck: false,
}, async (request) => {
    // 1. Authenticated User Check
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "UNAUTHENTICATED: Pengguna harus terotentikasi untuk mengakses layanan Gemini AI Planner.");
    }
    const data = request.data || {};
    // 2. Input Validation
    const destination = (data.destination || "").trim();
    if (!destination) {
        throw new https_1.HttpsError("invalid-argument", "INVALID_INPUT: Destinasi tidak boleh kosong.");
    }
    if (destination.length > 100) {
        throw new https_1.HttpsError("invalid-argument", "INVALID_INPUT: Nama destinasi terlalu panjang (maksimum 100 karakter).");
    }
    const durationDays = Number(data.durationDays);
    if (isNaN(durationDays) || durationDays < 1 || durationDays > 30) {
        throw new https_1.HttpsError("invalid-argument", "INVALID_INPUT: Durasi perjalanan harus berupa angka antara 1 sampai 30 hari.");
    }
    const budgetCeiling = Number(data.budgetCeiling || 0);
    if (isNaN(budgetCeiling) || budgetCeiling < 0) {
        throw new https_1.HttpsError("invalid-argument", "INVALID_INPUT: Pagu budget tidak valid.");
    }
    const styles = Array.isArray(data.styles)
        ? data.styles.map((s) => String(s).trim()).filter(Boolean)
        : ["Alam", "Kuliner"];
    if (data.specialNeeds && String(data.specialNeeds).length > 500) {
        throw new https_1.HttpsError("invalid-argument", "INVALID_INPUT: Catatan khusus terlalu panjang (maksimum 500 karakter).");
    }
    // 3. Secret API Key Resolution
    const apiKey = geminiApiKey.value();
    if (!apiKey || apiKey.trim().length === 0) {
        console.error("[generateItinerary] Secret GEMINI_API_KEY belum dikonfigurasi di Google Secret Manager.");
        throw new https_1.HttpsError("internal", "INTERNAL_ERROR: Konfigurasi server Gemini AI belum siap (Secret key missing).");
    }
    // 4. Build Prompt & Call Gemini REST API
    const promptText = buildPrompt({
        ...data,
        destination,
        durationDays,
        budgetCeiling,
        styles,
    });
    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${ACTIVE_MODEL}:generateContent?key=${apiKey.trim()}`;
    const requestBody = {
        contents: [
            {
                parts: [{ text: promptText }],
            },
        ],
        generationConfig: {
            temperature: 0.7,
            responseMimeType: "application/json",
        },
    };
    let responseStatusCode = 0;
    let responseText = "";
    try {
        const response = await fetch(apiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(requestBody),
        });
        responseStatusCode = response.status;
        responseText = await response.text();
    }
    catch (err) {
        console.error("[generateItinerary] Network error connecting to Gemini API:", err);
        throw new https_1.HttpsError("unavailable", "AI_UNAVAILABLE: Koneksi ke layanan Gemini AI terganggu atau mengalami timeout.");
    }
    if (responseStatusCode !== 200) {
        console.error(`[generateItinerary] Gemini API HTTP Error ${responseStatusCode}:`, responseText);
        if (responseStatusCode === 400) {
            throw new https_1.HttpsError("invalid-argument", "INVALID_INPUT: Parameter request Gemini AI tidak valid.");
        }
        else if (responseStatusCode === 401 || responseStatusCode === 403) {
            throw new https_1.HttpsError("permission-denied", "AI_UNAVAILABLE: Otentikasi server Gemini AI ditolak.");
        }
        else if (responseStatusCode === 429) {
            throw new https_1.HttpsError("resource-exhausted", "RATE_LIMITED: Batas kuota penggunaan Gemini AI terlampaui. Silakan coba lagi nanti.");
        }
        else {
            throw new https_1.HttpsError("unavailable", `AI_UNAVAILABLE: Layanan Gemini AI sedang bermasalah (HTTP ${responseStatusCode}).`);
        }
    }
    // 5. Response Parsing & Strict Validation
    try {
        const responseJson = JSON.parse(responseText);
        const candidates = responseJson.candidates;
        if (!Array.isArray(candidates) || candidates.length === 0) {
            throw new Error("Kandidat respon Gemini AI kosong.");
        }
        const firstCandidate = candidates[0];
        const content = firstCandidate.content;
        const parts = content ? content.parts : null;
        if (!Array.isArray(parts) || parts.length === 0) {
            throw new Error("Bagian respon ('parts') Gemini AI kosong.");
        }
        let rawText = parts[0].text || "";
        rawText = rawText
            .replace(/^```json\s*/gm, "")
            .replace(/^```\s*/gm, "")
            .trim();
        const parsedItinerary = JSON.parse(rawText);
        const validatedResult = validateAndFormatItinerary(parsedItinerary, destination, durationDays, styles);
        return {
            status: "success",
            data: validatedResult,
        };
    }
    catch (err) {
        console.error("[generateItinerary] Response parsing/validation error:", err, "Raw Output:", responseText);
        throw new https_1.HttpsError("internal", "INVALID_AI_RESPONSE: Format respon Gemini AI malformed atau tidak sesuai skema itinerary.");
    }
});
//# sourceMappingURL=index.js.map