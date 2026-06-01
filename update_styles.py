import re

css_path = "/Users/arafathossain/trackai/medai land/styles.css"
with open(css_path, "r") as f:
    css = f.read()

hp_replacement = """
.hp-frame{
  position:relative;z-index:10;
  width:310px;
  height:672px;
  border-radius:48px;
  overflow:hidden;
  background: #000;
  border: 10px solid #1a1a1c;
  box-shadow: inset 0 0 0 1px rgba(255,255,255,0.1);
  filter:
    drop-shadow(0 32px 56px rgba(0,0,0,.7))
    drop-shadow(0 8px 20px rgba(0,0,0,.4));
  animation:float-phone 6s ease-in-out infinite;
}
.hp-frame::after {
  content: '';
  position: absolute;
  top: 14px;
  left: 50%;
  transform: translateX(-50%);
  width: 90px;
  height: 28px;
  background: #000;
  border-radius: 14px;
  box-shadow: inset 0 0 2px rgba(255,255,255,0.1);
  z-index: 20;
}
.hp-img{
  width:100%;height:100%;display:block;
  object-fit:cover;
  transform:scale(1.1);
  border-radius:36px;
  transition:opacity .35s var(--ease),transform .35s var(--ease);
}
"""
css = re.sub(r'\.hp-frame\{.*?\n\}\n\.hp-img\{.*?\n\}', hp_replacement.strip(), css, flags=re.DOTALL)

sp_replacement = """
.sp-phone{
  position:relative;z-index:2;
  width:310px;height:672px;
  border-radius:48px;
  overflow:hidden;
  background: #000;
  border: 10px solid #1a1a1c;
  box-shadow: inset 0 0 0 1px rgba(255,255,255,0.1);
  filter:
    drop-shadow(0 32px 48px rgba(0,0,0,.65))
    drop-shadow(0 8px 16px rgba(0,0,0,.35));
  animation:float-phone 6s ease-in-out infinite;
}
.sp-phone::after {
  content: '';
  position: absolute;
  top: 14px;
  left: 50%;
  transform: translateX(-50%);
  width: 90px;
  height: 28px;
  background: #000;
  border-radius: 14px;
  box-shadow: inset 0 0 2px rgba(255,255,255,0.1);
  z-index: 20;
}
.sp-phone::before{display:none}
.sp-screen{
  width:100%;height:100%;display:block;
  object-fit:cover;
  transform:scale(1.1);
  border-radius:36px;
  view-transition-name:app-screen;
  transition:opacity .4s var(--ease),transform .4s var(--ease);
}
"""
css = re.sub(r'\.sp-phone\{.*?\n\}\n\.sp-phone::before,\.sp-phone::after\{display:none\}\n\.sp-screen\{.*?\n\}', sp_replacement.strip(), css, flags=re.DOTALL)

css = css.replace('.hp-frame{width:260px;height:520px}', '.hp-frame{width:260px;height:564px;border-radius:40px;border-width:8px}\n  .hp-img{border-radius:32px}\n  .hp-frame::after{top:12px;width:80px;height:24px;border-radius:12px}')
css = css.replace('.sp-phone{width:260px;height:520px}', '.sp-phone{width:260px;height:564px;border-radius:40px;border-width:8px}\n  .sp-screen{border-radius:32px}\n  .sp-phone::after{top:12px;width:80px;height:24px;border-radius:12px}')

css = css.replace('.hp-frame{width:230px;height:460px}', '.hp-frame{width:230px;height:498px;border-radius:36px;border-width:6px}\n  .hp-img{border-radius:28px}\n  .hp-frame::after{top:10px;width:70px;height:22px;border-radius:11px}')
css = css.replace('.sp-phone{width:230px;height:460px}', '.sp-phone{width:230px;height:498px;border-radius:36px;border-width:6px}\n  .sp-screen{border-radius:28px}\n  .sp-phone::after{top:10px;width:70px;height:22px;border-radius:11px}')

with open(css_path, "w") as f:
    f.write(css)

print("Updated CSS")
