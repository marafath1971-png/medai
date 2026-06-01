import re

html_path = "/Users/arafathossain/trackai/medai land/index.html"
with open(html_path, "r") as f:
    html = f.read()

replacement = """        <div class="hp-frame" id="videoDemoFrame">
          <!-- Video Sequence Container -->
          <div class="vid-seq" id="vidSeq">
            <!-- Slide 1: Scanning -->
            <div class="vid-slide vid-slide-active" data-step="0">
              <img src="landing-assets/scanner_v2.png" class="hp-img" alt="Scanning">
              <div class="vid-laser"></div>
            </div>
            <!-- Slide 2: Result & Schedule -->
            <div class="vid-slide" data-step="1">
              <img src="landing-assets/scan_result_v2.png" class="hp-img" alt="Scan Result">
            </div>
            <!-- Slide 3: Dangers & Body Impact -->
            <div class="vid-slide" data-step="2">
              <img src="landing-assets/body_impact_v2.png" class="hp-img" alt="Body Impact">
              <div class="vid-danger-ping"></div>
            </div>
            <!-- Slide 4: Dashboard & Reminders -->
            <div class="vid-slide" data-step="3">
              <img src="landing-assets/dashboard_v2.png" class="hp-img" alt="Dashboard Reminders">
            </div>
          </div>
          
          <!-- Video UI Overlay -->
          <div class="vid-ui">
            <div class="vid-progress-track">
              <div class="vid-bar" id="vidBar"></div>
            </div>
            <div class="vid-caption" id="vidCaption">Scanning medication label...</div>
          </div>
        </div>"""

html = re.sub(r'        <div class="hp-frame">\s*<img id="heroScreen" src="landing-assets/body_impact_v2\.png"\s*alt="MedAI app screen" class="hp-img">\s*</div>', replacement, html)

with open(html_path, "w") as f:
    f.write(html)
print("Updated HTML")
