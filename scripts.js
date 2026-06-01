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
  CHECKOUT_URL: 'https://medproai.lemonsqueezy.com/checkout/buy/1d5fd178-2432-453f-8b59-f325cd6415e3', // Real Lemon Squeezy checkout URL
};
const remaining = CFG.TOTAL - CFG.TAKEN;

/* ── Helpers ───────────────────────────────────────────────────── */
const $  = id  => document.getElementById(id);
const $$ = sel => document.querySelectorAll(sel);

/* ── Update all spot counters ──────────────────────────────────── */
function setSpots(n = remaining) {
  ['spotsLeft','heroSpots','pricingSpots','pricingSpots2','stickySpots','finalSpots']
    .forEach(id => {
      const el = $(id);
      if (!el) return;
      el.textContent = n;
    });

  // Progress bar(s): % filled = taken / total
  const pct = ((CFG.TOTAL - n) / CFG.TOTAL) * 100;
  const fill = $('heroFill');
  if (fill) fill.style.width = `${pct}%`;
}
setSpots();

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
let autoCycle = null;

function setHeroScreen(idx, manual = false) {
  if (!heroImg) return;
  heroImg.style.transition = 'opacity .3s, transform .3s';
  heroImg.style.opacity    = '0.3';
  heroImg.style.transform  = 'scale(0.97)';
  setTimeout(() => {
    heroImg.src             = SCREENS[idx];
    heroImg.style.opacity   = '1';
    heroImg.style.transform = 'scale(1)';
  }, 320);
  $$('.stab').forEach((b, i) => b.classList.toggle('stab-active', i === idx));
  if (manual) {
    clearInterval(autoCycle);
    autoCycle = setInterval(nextHeroScreen, 4000);
  }
}

function nextHeroScreen() {
  heroIdx = (heroIdx + 1) % SCREENS.length;
  setHeroScreen(heroIdx);
}

$$('.stab').forEach((btn, i) => {
  btn.addEventListener('click', () => {
    heroIdx = i;
    setHeroScreen(i, true);
  });
});

autoCycle = setInterval(nextHeroScreen, 4000);

// Preload
SCREENS.slice(1).forEach(src => { const i = new Image(); i.src = src; });

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
    hint: 'Reserve your spot. Secure Lemon Squeezy checkout opens after you submit.',
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
  const plan  = planInput?.value || 'founder-year';

  // Validate
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

  const nameVal = $('fn')?.value.trim();
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

  // Redirect to Lemon Squeezy if founder & URL configured
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

      // Activate premium secure transition overlay
      const overlay = $('secureOverlay');
      const progress = $('secProgressFill');
      const s1 = $('step1');
      const s2 = $('step2');
      const s3 = $('step3');
      const s4 = $('step4');

      if (overlay && progress) {
        overlay.classList.add('active');
        overlay.setAttribute('aria-hidden', 'false');

        // Stage 1: Validate spot (0% to 25%)
        setTimeout(() => {
          progress.style.width = '25%';
          s1.classList.add('completed');
          s2.classList.add('active');
        }, 800);

        // Stage 2: Encrypt metadata (25% to 55%)
        setTimeout(() => {
          progress.style.width = '55%';
          s2.classList.add('completed');
          s3.classList.add('active');
        }, 1600);

        // Stage 3: Generate Lemon Squeezy link (55% to 85%)
        setTimeout(() => {
          progress.style.width = '85%';
          s3.classList.add('completed');
          s4.classList.add('active');
        }, 2400);

        // Stage 4: Launch checkout (85% to 100%)
        setTimeout(() => {
          progress.style.width = '100%';
          s4.classList.add('completed');
        }, 3100);

        // Final handoff to Lemon Squeezy
        setTimeout(() => {
          window.location.href = url;
        }, 3500);
      } else {
        // Simple fallback redirect
        setTimeout(() => window.location.href = url, 1800);
      }
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
  setSpots(Math.max(remaining - 1, 0));
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

/* ── Social Proof Cycling Script ─────────────────────────────── */
const PT_DATA = [
  { n: "David L. from Seattle", a: "just claimed Founder Access ⚡", av: "D", c: "#00e88f" },
  { n: "Clara M. from London", a: "just joined the free Priority List 🏅", av: "C", c: "#3b82f6" },
  { n: "James T. from Austin", a: "just claimed Founder Access ⚡", av: "J", c: "#a855f7" },
  { n: "Priya R. from Chicago", a: "just joined the free Priority List 🏅", av: "P", c: "#ec4899" },
  { n: "Chloe W. from New York", a: "just claimed Founder Access ⚡", av: "C", c: "#00e88f" },
  { n: "Ryan B. from San Francisco", a: "just claimed Founder Access ⚡", av: "R", c: "#3b82f6" }
];
let ptIdx = 0;

function showProofToast() {
  const toast = $('proofToast');
  if (!toast) return;

  const item = PT_DATA[ptIdx];
  const nameEl = $('ptName');
  const actionEl = $('ptAction');
  const avatarEl = $('ptAvatar');

  if (nameEl) nameEl.textContent = item.n;
  if (actionEl) actionEl.textContent = item.a;
  if (avatarEl) {
    avatarEl.textContent = item.av;
    avatarEl.style.background = item.c;
    // Set text color contrast based on background color
    avatarEl.style.color = item.c === '#00e88f' ? '#000' : '#fff';
  }

  // Slide up
  toast.classList.add('active');

  // Slide down after 5.5 seconds
  setTimeout(() => {
    toast.classList.remove('active');
  }, 5500);

  // Next item
  ptIdx = (ptIdx + 1) % PT_DATA.length;
}

// Start cycling social proof toasts
setTimeout(() => {
  showProofToast();
  setInterval(showProofToast, 13000);
}, 4500);



/* ── Video Demo Sequence Logic ── */
const vidDemo = () => {
  const seq = document.getElementById('vidSeq');
  if (!seq) return;
  const slides = seq.querySelectorAll('.vid-slide');
  const bar = document.getElementById('vidBar');
  const caption = document.getElementById('vidCaption');
  
  const steps = [
    { text: 'Scanning medication label...', duration: 3500 },
    { text: 'Extraction & dose check complete', duration: 3000 },
    { text: 'Analyzing body impact & danger marks...', duration: 3500 },
    { text: 'Setting daily smart reminders', duration: 3000 }
  ];
  
  let currentStep = 0;
  
  const runSequence = () => {
    // Hide all
    slides.forEach(s => s.classList.remove('vid-slide-active'));
    
    // Show current
    if (slides[currentStep]) {
      slides[currentStep].classList.add('vid-slide-active');
    }
    
    // Update UI
    caption.style.opacity = 0;
    setTimeout(() => {
      caption.textContent = steps[currentStep].text;
      caption.style.opacity = 1;
    }, 300);
    
    // Animate bar
    bar.style.transition = 'none';
    bar.style.width = '0%';
    setTimeout(() => {
      bar.style.transition = `width ${steps[currentStep].duration}ms linear`;
      bar.style.width = '100%';
    }, 50);
    
    // Next step
    setTimeout(() => {
      currentStep = (currentStep + 1) % steps.length;
      runSequence();
    }, steps[currentStep].duration);
  };
  
  runSequence();
};
vidDemo();
