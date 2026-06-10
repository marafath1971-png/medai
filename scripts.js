'use strict';

/* ── Firebase Config & Init ────────────────────────────────────── */
const firebaseConfig = {
  projectId: "medai-3ce9c",
  appId: "1:883005184689:web:c9efd9a616b3b84a96e090",
  storageBucket: "medai-3ce9c.firebasestorage.app",
  apiKey: "AIzaSyBiaxiQJI9B6q24OI4_uoGrfCaX77PhLCQ",
  authDomain: "medai-3ce9c.firebaseapp.com",
  messagingSenderId: "883005184689",
  measurementId: "G-GP030T8T6T",
};

let db = null;
if (typeof firebase !== 'undefined') {
  firebase.initializeApp(firebaseConfig);
  db = firebase.firestore();
}

/* ── Config ────────────────────────────────────────────────────── */
const CFG = {
  API:          'https://trackai-backend.onrender.com/api',
  TOTAL:        100,
  TAKEN:        53,
  LS_KEY:       'medai_v3',
  CHECKOUT_URL: 'https://medproai.paddle.com/checkout/buy/1d5fd178-2432-453f-8b59-f325cd6415e3', // Real Paddle checkout URL
};
const remaining = CFG.TOTAL - CFG.TAKEN;

/* ── Geo-Aware Pricing ─────────────────────────────────────── */
(function initGeoPricing() {
  try {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone || '';
    const lang = (navigator.language || '').toLowerCase();
    const map = [
      { zones: ['Europe/London','Europe/Dublin'], langs: ['en-gb'], flag: '🇬🇧', text: 'Approx. £15/year — less than a coffee a week in the UK.' },
      { zones: ['Australia/Sydney','Australia/Melbourne','Australia/Brisbane','Australia/Perth','Australia/Adelaide'], langs: ['en-au'], flag: '🇦🇺', text: 'Approx. AU$29/year — that’s less than 2 pharmacy visits.' },
      { zones: ['Asia/Dubai','Asia/Muscat'], langs: ['ar-ae'], flag: '🇦🇪', text: 'Approx. AED 70/year — one year of full access for less than a consultation.' },
      { zones: ['America/New_York','America/Chicago','America/Denver','America/Los_Angeles'], langs: ['en-us'], flag: '🇺🇸', text: 'Just $19 for the full year — less than your monthly pharmacy copay.' },
    ];
    for (const entry of map) {
      const matchZone = entry.zones.some(z => tz.startsWith(z.split('/')[0]) && tz === z);
      const matchLang = entry.langs.some(l => lang.startsWith(l));
      if (matchZone || matchLang) {
        const el = document.getElementById('geoPricing');
        if (el) {
          el.textContent = entry.flag + '  ' + entry.text;
          el.removeAttribute('hidden');
        }
        break;
      }
    }
  } catch (e) {}
})();

/* ── 14-Day Countdown Timer ────────────────────────────────── */
(function initCountdown() {
  const CD_KEY = 'medai_founder_deadline';
  let deadline = parseInt(localStorage.getItem(CD_KEY), 10);
  const now = Date.now();
  if (isNaN(deadline) || deadline < now) {
    deadline = now + 14 * 24 * 60 * 60 * 1000; // 14 days from first visit
    localStorage.setItem(CD_KEY, deadline.toString());
  }
  const els = { d: document.getElementById('cdDays'), h: document.getElementById('cdHours'), m: document.getElementById('cdMins'), s: document.getElementById('cdSecs') };
  function tick() {
    const diff = Math.max(0, deadline - Date.now());
    const days  = Math.floor(diff / 86400000);
    const hours = Math.floor((diff % 86400000) / 3600000);
    const mins  = Math.floor((diff % 3600000) / 60000);
    const secs  = Math.floor((diff % 60000) / 1000);
    const pad = n => String(n).padStart(2, '0');
    if (els.d) els.d.textContent = days;
    if (els.h) els.h.textContent = pad(hours);
    if (els.m) els.m.textContent = pad(mins);
    if (els.s) els.s.textContent = pad(secs);
    if (diff <= 0) clearInterval(timer);
  }
  tick();
  const timer = setInterval(tick, 1000);
})();

/* ── Helpers ───────────────────────────────────────────────────── */
const $  = id  => document.getElementById(id);
const $$ = sel => document.querySelectorAll(sel);

/* ── Update all spot counters ──────────────────────────────────── */
function setSpots(n) {
  ['spotsLeft','heroSpots','pricingSpots','pricingSpots2','stickySpots','finalSpots']
    .forEach(id => {
      const el = $(id);
      if (!el) return;
      el.textContent = n;
    });

  // Progress bar fill: taken / total
  const pct = ((CFG.TOTAL - n) / CFG.TOTAL) * 100;
  const fill = $('heroFill');
  if (fill) fill.style.width = `${pct}%`;
}

/* ── Persistent Spots Countdown ──────────────────────────────── */
function initSpots() {
  const SPOTS_KEY = 'medai_spots_left';
  let spots = parseInt(localStorage.getItem(SPOTS_KEY), 10);
  
  if (isNaN(spots) || spots <= 0) {
    // Start with a believable random count of remaining spots
    spots = Math.floor(Math.random() * 8) + 32; // starts between 32 and 39
  }
  
  // Save initial value
  localStorage.setItem(SPOTS_KEY, spots.toString());
  setSpots(spots);

  // Dynamic slow decrement during active session
  // Decrement by 1 spot every 4 minutes (240000 ms) down to a minimum of 7 spots
  setInterval(() => {
    let currentSpots = parseInt(localStorage.getItem(SPOTS_KEY), 10);
    if (currentSpots > 7) {
      currentSpots -= 1;
      localStorage.setItem(SPOTS_KEY, currentSpots.toString());
      setSpots(currentSpots);
    }
  }, 240000);
}
initSpots();

/* ── Announcement bar ──────────────────────────────────────────── */
const annBar  = $('announcementBar');
const mainNav = $('mainNav');
let barH = annBar ? annBar.offsetHeight : 0;

$('closeBar')?.addEventListener('click', () => {
  annBar?.classList.add('hidden');
  barH = 0;
  document.documentElement.style.setProperty('--bar', '0px');
  if (mainNav) mainNav.style.top = '0';
});

/* ── Nav scroll ────────────────────────────────────────────────── */
window.addEventListener('scroll', () => {
  const y = window.scrollY;
  mainNav?.classList.toggle('scrolled', y > 20);

  // Show sticky bar between hero and signup
  const hero   = $('top');
  const signup = $('signup');
  const sticky = $('stickyBar');
  if (sticky && hero && signup) {
    const heroGone   = hero.getBoundingClientRect().bottom < 0;
    const signupFar  = signup.getBoundingClientRect().top > window.innerHeight;
    sticky.classList.toggle('visible', heroGone && signupFar);
    sticky.setAttribute('aria-hidden', String(!(heroGone && signupFar)));
  }
}, { passive: true });

/* ── Mobile hamburger ──────────────────────────────────────────── */
const burger   = $('burger');
const navLinks = $('navLinks');
let menuOpen   = false;

burger?.addEventListener('click', () => {
  menuOpen = !menuOpen;
  burger.classList.toggle('open', menuOpen);
  burger.setAttribute('aria-expanded', menuOpen);

  if (menuOpen) {
    Object.assign(navLinks.style, {
      display:       'flex',
      flexDirection: 'column',
      gap:           '4px',
      position:      'fixed',
      top:           `${barH + 68}px`,
      left:          '0',
      right:         '0',
      padding:       '20px 24px 28px',
      background:    'rgba(2,4,6,.97)',
      borderBottom:  '1px solid rgba(255,255,255,.07)',
      backdropFilter:'blur(24px)',
      zIndex:        '880',
    });
    navLinks.querySelectorAll('a').forEach(a => {
      Object.assign(a.style, {
        padding: '14px 18px', fontSize: '16px',
        background: 'rgba(255,255,255,.04)',
        borderRadius: '12px', display: 'block',
      });
    });
  } else {
    navLinks.style.cssText = '';
    navLinks.querySelectorAll('a').forEach(a => a.style.cssText = '');
  }
});

navLinks?.querySelectorAll('a').forEach(a => {
  a.addEventListener('click', () => {
    if (!menuOpen) return;
    menuOpen = false;
    burger?.classList.remove('open');
    navLinks.style.cssText = '';
    navLinks.querySelectorAll('a').forEach(l => l.style.cssText = '');
  });
});

/* ── Smooth scroll ─────────────────────────────────────────────── */
document.addEventListener('click', e => {
  const a = e.target.closest('a[href^="#"]');
  if (!a) return;
  const id = a.getAttribute('href').slice(1);
  const target = document.getElementById(id);
  if (!target) return;
  e.preventDefault();
  const offset = (mainNav?.offsetHeight || 68) + barH + 16;
  const top = target.getBoundingClientRect().top + window.scrollY - offset;
  window.scrollTo({ top, behavior: 'smooth' });
});

/* ── Hero spotlight ────────────────────────────────────────────── */
const spotlight = $('spotlight');
const heroSec   = $('top');
if (spotlight && heroSec) {
  heroSec.addEventListener('mousemove', e => {
    const r = heroSec.getBoundingClientRect();
    spotlight.style.left    = `${e.clientX - r.left}px`;
    spotlight.style.top     = `${e.clientY - r.top}px`;
    spotlight.style.opacity = '1';
  });
  heroSec.addEventListener('mouseleave', () => spotlight.style.opacity = '0');
}

/* ── Hero screen cycling ───────────────────────────────────────── */
const SCREENS = [
  'landing-assets/body_impact_v2.png',
  'landing-assets/scan_result_v2.png',
  'landing-assets/scanner_v2.png',
  'landing-assets/dashboard_v2.png',
];
let heroIdx   = 0;
const heroImg = $('heroScreen');
const heroVideo = $('heroVideo');
let autoCycle = null;

function setHeroScreen(idx, manual = false) {
  if (!heroImg || !heroVideo) return;
  
  if (idx === 0) {
    // Show video, hide image
    heroImg.style.opacity = '0';
    setTimeout(() => {
      heroImg.style.display = 'none';
      heroVideo.style.display = 'block';
      heroVideo.style.opacity = '1';
      heroVideo.play().catch(e => console.log('Autoplay blocked:', e));
    }, 150);
  } else {
    // Show image, hide video
    heroVideo.style.opacity = '0';
    setTimeout(() => {
      heroVideo.style.display = 'none';
      heroVideo.pause();
      
      heroImg.style.display = 'block';
      heroImg.style.transition = 'opacity .3s, transform .3s';
      heroImg.style.opacity    = '0.3';
      heroImg.style.transform  = 'scale(0.97)';
      
      setTimeout(() => {
        heroImg.src             = SCREENS[idx - 1];
        heroImg.style.opacity   = '1';
        heroImg.style.transform = 'scale(1)';
      }, 50);
    }, 150);
  }

  $$('.stab').forEach((b, i) => b.classList.toggle('stab-active', i === idx));
  
  if (manual) {
    clearInterval(autoCycle);
    if (idx === 0) {
      autoCycle = null; // Stay on the video indefinitely if clicked
    } else {
      autoCycle = setInterval(nextHeroScreen, 4000);
    }
  }
}

function nextHeroScreen() {
  // Cycle static screens: 1, 2, 3, 4
  heroIdx = (heroIdx === 0) ? 1 : ((heroIdx - 1 + 1) % SCREENS.length) + 1;
  setHeroScreen(heroIdx);
}

$$('.stab').forEach((btn, i) => {
  btn.addEventListener('click', () => {
    heroIdx = i;
    setHeroScreen(i, true);
  });
});

// Since default screen is video (idx 0), we do not start auto-cycling immediately.
// If the user clicks on any image tabs, auto-cycling will commence.

// Preload
SCREENS.forEach(src => { const i = new Image(); i.src = src; });

/* ── App Showcase interactive tabs ─────────────────────────────── */
const SHOWCASE = [
  {
    img:    'landing-assets/scanner_v2.png',
    label:  'AI Medicine Scanner',
    top:    'Point & scan any label',
    bot:    'Results in 3 seconds',
    glow:   '#00e88f',
  },
  {
    img:    'landing-assets/body_impact_v2.png',
    label:  'Body Impact Review',
    top:    'Plain-English body effects',
    bot:    'Mix-risk checks included',
    glow:   '#3b82f6',
  },
  {
    img:    'landing-assets/dashboard_v2.png',
    label:  'Dashboard & Health Score',
    top:    'Daily health score: 87',
    bot:    '14-day streak 🔥',
    glow:   '#a855f7',
  },
  {
    img:    'landing-assets/scan_result_v2.png',
    label:  'Scan Result & Schedule',
    top:    'Instant interaction check',
    bot:    'Auto-built smart schedule',
    glow:   '#00e88f',
  },
];

const showcaseImg  = $('showcaseImg');
const spLabel      = $('spLabel');
const scTop        = $('scTop');
const scBot        = $('scBot');
const spGlow       = $('spGlowBg');
let showcaseIdx    = 0;
let showcaseCycle  = null;

function setShowcase(idx, manual = false) {
  const d = SHOWCASE[idx];
  if (!d) return;
  showcaseIdx = idx;

  // Update active tab & re-trigger progress bar animation
  $$('.show-tab').forEach((t, i) => {
    const wasActive = t.classList.contains('show-tab-active');
    t.classList.toggle('show-tab-active', i === idx);
    // Force CSS animation restart on newly-active tab
    if (i === idx && !wasActive) {
      // Remove and re-add class to trigger ::after animation restart
      t.classList.remove('show-tab-active');
      void t.offsetWidth; // force reflow
      t.classList.add('show-tab-active');
    }
  });

  // Swap image with modern View Transition API
  if (showcaseImg) {
    if (document.startViewTransition) {
      document.startViewTransition(() => {
        showcaseImg.src = d.img;
      });
    } else {
      showcaseImg.classList.add('switching');
      setTimeout(() => {
        showcaseImg.src = d.img;
        showcaseImg.classList.remove('switching');
      }, 420);
    }
  }

  // Update labels & callouts
  if (spLabel) spLabel.textContent = d.label;
  if (scTop) scTop.querySelector('.sc-text').textContent = d.top;
  if (scBot) scBot.querySelector('.sc-text').textContent = d.bot;

  // Update glow colour
  if (spGlow) spGlow.style.background = d.glow;

  // Clear auto-cycle on manual user interaction
  if (manual && showcaseCycle) {
    clearInterval(showcaseCycle);
  }
}

$$('.show-tab').forEach((btn, i) => {
  btn.addEventListener('click', () => setShowcase(i, true));
});

// Auto-cycle app showcase tabs every 5 seconds
showcaseCycle = setInterval(() => {
  showcaseIdx = (showcaseIdx + 1) % SHOWCASE.length;
  setShowcase(showcaseIdx);
}, 5000);

// Preload showcase images
SHOWCASE.forEach(({ img }) => { const im = new Image(); im.src = img; });

/* ── Scroll-reveal & counter ───────────────────────────────────── */
function countUp(el) {
  const target = parseInt(el.dataset.to, 10);
  if (isNaN(target)) return;
  const dur   = 1600;
  const start = performance.now();
  (function tick(now) {
    const p = Math.min((now - start) / dur, 1);
    const e = 1 - Math.pow(1 - p, 3);   // ease-out-cubic
    el.textContent = Math.round(target * e).toLocaleString();
    if (p < 1) requestAnimationFrame(tick);
  })(start);
}

const revealObs = new IntersectionObserver(entries => {
  entries.forEach((entry, i) => {
    if (!entry.isIntersecting) return;
    const el = entry.target;
    setTimeout(() => {
      el.classList.add('visible');
      el.querySelectorAll('.count').forEach(c => countUp(c));
      
      // Dynamic visualizer progress fills inside Refill Bento card
      el.querySelectorAll('.rv-fill').forEach(bar => {
        bar.style.width = `${bar.dataset.w}%`;
      });
    }, i * 80);
    revealObs.unobserve(el);
  });
}, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

$$('.reveal').forEach(el => revealObs.observe(el));

/* Also trigger score arc animation on bento-score reveal */
const scoreArc = document.querySelector('.score-arc');
if (scoreArc) {
  const scoreObs = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      scoreArc.style.transition = 'stroke-dashoffset 1.8s cubic-bezier(0.16,1,0.3,1)';
      scoreArc.style.strokeDashoffset = '42';
      scoreObs.unobserve(e.target);
    });
  }, { threshold: 0.4 });
  scoreArc.style.strokeDashoffset = '201'; // start empty
  scoreObs.observe(scoreArc.closest('.bc-score') || scoreArc);
}

/* ── FAQ accordion ─────────────────────────────────────────────── */
$$('.fi').forEach(item => {
  const btn = item.querySelector('.fq');
  if (!btn) return;
  btn.addEventListener('click', () => {
    const isOpen = item.classList.contains('open');
    $$('.fi.open').forEach(o => {
      o.classList.remove('open');
      o.querySelector('.fq')?.setAttribute('aria-expanded', 'false');
    });
    if (!isOpen) {
      item.classList.add('open');
      btn.setAttribute('aria-expanded', 'true');
    }
  });
});

/* ── Plan picker ───────────────────────────────────────────────── */
const planInput = $('planInput');
const planHint  = $('planHint');
const submitTxt = $('submitText');
const submitBtn = $('submitBtn');

const PLANS = {
  'waitlist': {
    hint: 'Join the free priority list — no payment required.',
    btn:  'Join free priority list →',
  },
  'founder-year': {
    hint: 'Reserve your spot. Secure Paddle checkout opens after you submit.',
    btn:  'Unlock founder access — $19/yr ⚡',
  },
};

function setPlan(plan) {
  $$('.ptab').forEach(b => b.classList.toggle('ptab-on', b.dataset.plan === plan));
  $$('.plan-tabs .ptab').forEach(b => b.classList.toggle('ptab-on', b.dataset.plan === plan));
  if (planInput) planInput.value   = plan;
  if (planHint  && PLANS[plan]) planHint.textContent  = PLANS[plan].hint;
  if (submitTxt && PLANS[plan]) submitTxt.textContent = PLANS[plan].btn;
  if (submitBtn) {
    if (plan === 'founder-year') {
      submitBtn.classList.add('glow-btn','pulse-ring');
    } else {
      submitBtn.classList.remove('glow-btn','pulse-ring');
      submitBtn.style.background = '#fff';
    }
  }
}

$$('.ptab').forEach(btn => {
  btn.addEventListener('click', () => setPlan(btn.dataset.plan));
});

// Any CTA that passes data-plan scrolls to form & sets plan
document.addEventListener('click', e => {
  const el = e.target.closest('[data-plan]');
  if (!el || el.classList.contains('ptab')) return;
  const p = el.dataset.plan;
  if (p && PLANS[p]) setTimeout(() => setPlan(p), 120);
});

/* ── Form submission ───────────────────────────────────────────── */
const form    = $('waitlistForm');
const formMsg = $('formMsg');

function showMsg(type, txt) {
  if (!formMsg) return;
  formMsg.className = `form-msg ${type}`;
  formMsg.textContent = txt;
}

form?.addEventListener('submit', async e => {
  e.preventDefault();

  const email = $('fe')?.value.trim() || '';
  const name  = $('fn')?.value.trim() || '';
  const plan  = planInput?.value || 'founder-year';

  // Validate
  if (!name && plan === 'founder-year') {
    showMsg('err', 'Please enter your first name.');
    $('fn')?.focus();
    return;
  }
  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    showMsg('err', 'Please enter a valid email address.');
    $('fe')?.focus();
    return;
  }

  // Loading state
  if (submitBtn)  submitBtn.disabled = true;
  if (submitTxt)  submitTxt.textContent = 'Saving your spot…';
  formMsg.className = 'form-msg';

  const params = new URLSearchParams(window.location.search);
  const payload = {
    email,
    plan,
    createdAt: db ? firebase.firestore.FieldValue.serverTimestamp() : new Date()
  };

  const nameVal = $('fn')?.value.trim() || $('fn2')?.value.trim();
  if (nameVal) payload.name = nameVal;

  const roleVal = $('fr')?.value;
  if (roleVal) payload.role = roleVal;

  const deviceVal = $('fd')?.value;
  if (deviceVal) payload.device = deviceVal;

  const marketingConsentVal = $('fc')?.checked;
  if (typeof marketingConsentVal === 'boolean') payload.marketingConsent = marketingConsentVal;

  const referralSourceVal = $('fs')?.value.trim();
  if (referralSourceVal) payload.referralSource = referralSourceVal;

  const refCodeVal = params.get('ref') || '';
  if (refCodeVal) payload.referredByCode = refCodeVal;

  const utm_source = params.get('utm_source');
  const utm_medium = params.get('utm_medium');
  const utm_campaign = params.get('utm_campaign');
  if (utm_source || utm_medium || utm_campaign) {
    payload.metadata = {};
    if (utm_source) payload.metadata.utm_source = utm_source;
    if (utm_medium) payload.metadata.utm_medium = utm_medium;
    if (utm_campaign) payload.metadata.utm_campaign = utm_campaign;
    payload.metadata.page_version = 'premium-showcase-2026';
  }

  let data = {};
  try {
    if (db) {
      await db.collection('waitlist').add(payload);
      data = { referralCode: Math.random().toString(36).substring(2, 9).toUpperCase() };
    } else {
      const res = await fetch(`${CFG.API}/waitlist`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(payload),
      });
      try { data = await res.json(); } catch {}
      if (!res.ok) {
        const m = data?.message;
        throw new Error(Array.isArray(m) ? m.join(', ') : (m || `Error ${res.status}`));
      }
    }
  } catch (err) {
    showMsg('err', err.message || 'Something went wrong. Please try again.');
    if (submitBtn) submitBtn.disabled = false;
    if (submitTxt) submitTxt.textContent = PLANS[plan]?.btn || 'Submit';
    return;
  }

  // ── SUCCESS ──
  try {
    localStorage.setItem(CFG.LS_KEY, JSON.stringify({ email, plan, ts: Date.now() }));
  } catch {}

  form.hidden = true;
  $$('.plan-tabs').forEach(t => t.hidden = true);
  $('planHint').hidden = true;

  const ss = $('successState');
  if (ss) ss.hidden = false;

  // Set success message
  const sm = $('successText');
  if (sm) {
    sm.textContent = plan === 'founder-year'
      ? `🎉 Founder spot reserved! We'll send checkout details to ${email} shortly.`
      : `You're on the priority list! Updates will land in ${email}.`;
  }

  // Show social share buttons
  const sb = $('shareButtons');
  if (sb) sb.removeAttribute('hidden');
  const shareText = `I just grabbed early access to MedAI — the AI app that scans medicine labels in 3 seconds. Founding price is only $19/year. Get yours: ${location.origin}${location.pathname}`;
  $('shareX')?.addEventListener('click', () => window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}`, '_blank', 'noopener'));
  $('shareWa')?.addEventListener('click', () => window.open(`https://wa.me/?text=${encodeURIComponent(shareText)}`, '_blank', 'noopener'));
  $('shareLi')?.addEventListener('click', () => window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(location.origin + location.pathname)}`, '_blank', 'noopener'));

  // Redirect to Paddle if founder & URL configured
  if (plan === 'founder-year') {
    let url = data?.checkoutUrl || CFG.CHECKOUT_URL;
    if (url) {
      try {
        const u = new URL(url);
        if (!u.searchParams.has('prefilled_email')) {
          u.searchParams.set('prefilled_email', email);
        }
        if (!u.searchParams.has('email')) {
          u.searchParams.set('email', email);
        }
        url = u.toString();
      } catch (e) {}

      // Redirect immediately to minimize payment flow friction
      window.location.href = url;
      return;
    }
  }

  // Referral link
  const refCode = data?.referralCode || data?.data?.referralCode;
  const refLink = $('refLink');
  if (refLink && refCode) {
    refLink.value = `${location.origin}${location.pathname}?ref=${refCode}`;
  } else {
    const rw = $('refWrap');
    if (rw) rw.hidden = true;
  }

  // Update counters
  const SPOTS_KEY = 'medai_spots_left';
  let currentSpots = parseInt(localStorage.getItem(SPOTS_KEY), 10);
  if (!isNaN(currentSpots) && currentSpots > 8) {
    currentSpots -= 1;
    localStorage.setItem(SPOTS_KEY, currentSpots.toString());
    setSpots(currentSpots);
  }
});

/* ── Copy referral link ────────────────────────────────────────── */
$('copyRef')?.addEventListener('click', async () => {
  const inp = $('refLink');
  if (!inp?.value) return;
  try {
    await navigator.clipboard.writeText(inp.value);
    const btn = $('copyRef');
    const orig = btn.textContent;
    btn.textContent = 'Copied ✓';
    btn.style.color = 'var(--g)';
    btn.style.borderColor = 'var(--g)';
    setTimeout(() => {
      btn.textContent = orig;
      btn.style.color = '';
      btn.style.borderColor = '';
    }, 2200);
  } catch {
    inp.select();
    document.execCommand('copy');
  }
});

/* ── Returning visitor ─────────────────────────────────────────── */
try {
  const saved = JSON.parse(localStorage.getItem(CFG.LS_KEY) || 'null');
  if (saved?.email && (Date.now() - saved.ts) < 30 * 24 * 3600 * 1000) {
    const msg = $('formMsg');
    if (msg) showMsg('ok', `Welcome back! You signed up with ${saved.email}.`);
  }
} catch {}

/* ── Premium 3D Tilt Effect ────────────────────────────────────── */
$$('.bc, .hp-frame, .sp-phone, .tc').forEach(el => {
  el.addEventListener('mousemove', e => {
    const r = el.getBoundingClientRect();
    const x = (e.clientX - r.left - r.width / 2) / (r.width / 2);
    const y = (e.clientY - r.top - r.height / 2) / (r.height / 2);
    
    // Max rotation 4deg for a subtle premium feel
    const rotateX = -y * 4;
    const rotateY = x * 4;
    
    // Inject spotlight coordinates
    el.style.setProperty('--x', `${e.clientX - r.left}px`);
    el.style.setProperty('--y', `${e.clientY - r.top}px`);
    
    el.style.transform = `perspective(1000px) scale(1.02) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
    el.style.transition = 'none';
  });
  
  el.addEventListener('mouseleave', () => {
    el.style.transform = '';
    el.style.transition = 'transform 0.6s cubic-bezier(0.16, 1, 0.3, 1)';
  });
});
/* ── Exit Intent Popup ─────────────────────────────────────── */
(function initExitIntent() {
  const EP_KEY = 'medai_exit_shown';
  const popup  = $('exitPopup');
  if (!popup) return;

  // Show only once per session
  if (sessionStorage.getItem(EP_KEY)) return;

  let triggered = false;
  function showPopup() {
    if (triggered) return;
    triggered = true;
    sessionStorage.setItem(EP_KEY, '1');
    popup.classList.add('open');
    popup.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  }
  function closePopup() {
    popup.classList.remove('open');
    popup.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  }

  // Desktop: detect mouse leaving top of viewport
  document.addEventListener('mouseleave', e => {
    if (e.clientY < 20) showPopup();
  });

  // Mobile: 30-second delay trigger if user hasn't converted
  setTimeout(() => {
    const saved = localStorage.getItem(CFG.LS_KEY);
    if (!saved) showPopup();
  }, 30000);

  $('epClose')?.addEventListener('click', closePopup);
  $('epOverlay')?.addEventListener('click', closePopup);
  document.addEventListener('keydown', e => { if (e.key === 'Escape') closePopup(); });

  // Exit popup form submission
  $('epSubmit')?.addEventListener('click', async () => {
    const email = $('epEmail')?.value.trim();
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      $('epEmail')?.focus();
      return;
    }
    const btn = $('epSubmit');
    if (btn) { btn.textContent = 'Saving…'; btn.disabled = true; }
    try {
      if (db) {
        await db.collection('waitlist').add({ email, plan: 'waitlist', source: 'exit-intent', createdAt: firebase.firestore.FieldValue.serverTimestamp() });
      } else {
        await fetch(`${CFG.API}/waitlist`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email, plan: 'waitlist', source: 'exit-intent' }) });
      }
    } catch {}
    const card = document.querySelector('.ep-card');
    if (card) card.innerHTML = '<div class="ep-emoji">🙌</div><h3>You\'re in!</h3><p>We\'ll notify you on launch day. Keep an eye on your inbox.</p>';
    setTimeout(closePopup, 2500);
  });
})();


