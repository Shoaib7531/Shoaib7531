/**
 * Satark.AI - Layer 5 Persuasion Radar & Intent Scoring Module
 */

const LOCALIZATIONS = {
  hi: {
    heading: "रुको! यह 'डिजिटल अरेस्ट' है।",
    p1: "• पुलिस/CBI कभी UPI से पैसे नहीं मांगती।",
    p2: "• बैंक में नाम: {NAME} (बेमेल)।",
    p3: "• तुरंत कॉल काटें।",
    btnCall: "❌ कॉल काटें और ब्लॉक करें",
    btnDismiss: "Dismiss"
  },
  hinglish: {
    heading: "Ruko! Yeh 'Digital Arrest' Scam Hai.",
    p1: "• Police/CBI kabhi UPI par paise nahi maangti.",
    p2: "• Bank registered name is {NAME} (Mismatch).",
    p3: "• Call disconnect karo.",
    btnCall: "❌ Call Kaato aur Block Karo",
    btnDismiss: "Dismiss"
  },
  ta: {
    heading: "நில்லுங்கள்! இது 'டிஜிட்டல் கைது' மோசடி.",
    p1: "• சிபிஐ/காவல்துறை ஒருபோதும் UPI மூலம் பணம் கேட்பதில்லை.",
    p2: "• வங்கி பெயர்: {NAME} (பொருந்தவில்லை).",
    p3: "• அழைப்பைத் துண்டிக்கவும்.",
    btnCall: "❌ அழைப்பைத் துண்டிக்கவும்",
    btnDismiss: "Dismiss"
  },
  te: {
    heading: "ఆగండి! ఇది 'డిజిటల్ అరెస్ట్' మోసం.",
    p1: "• పోలీసులు లేదా సిబిఐ ఎప్పుడూ UPI ద్వారా డబ్బు అడగరు.",
    p2: "• బ్యాంక్ పేరు: {NAME} (సరిపోలడం లేదు).",
    p3: "• కాల్ వెంటనే కట్ చేయండి.",
    btnCall: "❌ కాల్ కట్ చేసి బ్లాక్ చేయండి",
    btnDismiss: "Dismiss"
  },
  en: {
    heading: "STOP! Fake Law Enforcement Threat.",
    p1: "• Police, CBI, or Customs NEVER demand money via UPI.",
    p2: "• Bank registered name is {NAME} (Mismatch).",
    p3: "• Disconnect call immediately.",
    btnCall: "❌ End Call & Block",
    btnDismiss: "Dismiss"
  }
};

function calculatePersuasionMetrics(scenario) {
  return {
    authority: scenario.auth || 0,
    urgency: scenario.urg || 0,
    inversion: scenario.inv || 0,
    mismatch: scenario.beneS || 0,
    activeCallBoost: scenario.callB || 0,
    aggregateRisk: scenario.risk || 0,
    isThreat: (scenario.risk || 0) >= 45
  };
}

// Export for browser or Node environment
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { LOCALIZATIONS, calculatePersuasionMetrics };
}
