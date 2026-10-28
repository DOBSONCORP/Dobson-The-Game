#!/usr/bin/env python3
"""Generate the DobsonGame tile/splash logos.

The GitHub Actions build generates these on the runner instead of receiving
them as committed files, because the upload path only carries text files.
Visual Studio builds use the committed PNGs; running this script locally
regenerates equivalent ones.
"""
import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))


def load_font(size):
    candidates = [
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
        r'C:\Windows\Fonts\arialbd.ttf',
        r'C:\Windows\Fonts\arial.ttf',
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                pass
    return ImageFont.load_default()


def twinkie_logo(w, h, text, sub=None):
    img = Image.new('RGB', (w, h), (11, 30, 58))
    d = ImageDraw.Draw(img)
    bw, bh = int(w * 0.62), max(18, int(h * 0.28))
    x0, y0 = (w - bw) // 2, int(h * 0.22)
    d.rounded_rectangle([x0, y0, x0 + bw, y0 + bh], radius=bh // 2,
                        fill=(251, 191, 36), outline=(180, 120, 20), width=3)
    d.line([x0 + bw * 0.25, y0 + 4, x0 + bw * 0.25, y0 + bh - 4],
           fill=(180, 120, 20), width=2)
    d.line([x0 + bw * 0.75, y0 + 4, x0 + bw * 0.75, y0 + bh - 4],
           fill=(180, 120, 20), width=2)
    if text:
        f = load_font(max(14, int(h * 0.20)))
        bb = d.textbbox((0, 0), text, font=f)
        d.text(((w - (bb[2] - bb[0])) // 2, y0 + bh + max(6, int(h * 0.08))),
               text, font=f, fill=(255, 255, 255))
    if sub:
        f2 = load_font(max(11, int(h * 0.12)))
        bb = d.textbbox((0, 0), sub, font=f2)
        d.text(((w - (bb[2] - bb[0])) // 2, h - int(h * 0.20)),
               sub, font=f2, fill=(147, 197, 253))
    return img


def main():
    jobs = [
        ('Logo.png', 150, 150, 'DOBSON', None),
        ('SmallLogo.png', 44, 44, None, None),
        ('WideLogo.png', 310, 150, 'DOBSON', None),
        ('StoreLogo.png', 50, 50, None, None),
        ('SplashScreen.png', 620, 300, 'DOBSON', 'THE GAME'),
    ]
    for name, w, h, text, sub in jobs:
        twinkie_logo(w, h, text, sub).save(os.path.join(HERE, name))
        print(f'{name} {w}x{h}')


if __name__ == '__main__':
    main()
