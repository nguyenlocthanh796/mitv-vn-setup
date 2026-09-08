import os
from PIL import Image, ImageDraw, ImageFont

img_dir = r"C:\Users\locthanhit\.gemini\antigravity\scratch\mitv-vn-setup\docs\images"

def draw_badge(draw, x, y, text, font, bg_color=(0, 229, 255), text_color=(0, 0, 0), padding=12):
    bbox = draw.textbbox((x, y), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    rect = [x, y, x + w + padding * 2, y + h + padding * 2]
    draw.rounded_rectangle(rect, radius=8, fill=bg_color)
    draw.text((x + padding, y + padding - 2), text, fill=text_color, font=font)
    return rect

def draw_pointer(draw, start_pt, end_pt, color=(0, 229, 255), width=5):
    draw.line([start_pt, end_pt], fill=color, width=width)
    # Draw arrow head or dot
    r = 8
    draw.ellipse([end_pt[0]-r, end_pt[1]-r, end_pt[0]+r, end_pt[1]+r], fill=color)

# Try loading standard Windows TrueType fonts
font_title = None
font_desc = None
for fpath in ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf", "C:/Windows/Fonts/tahoma.ttf"]:
    if os.path.exists(fpath):
        font_title = ImageFont.truetype(fpath, 32)
        font_desc = ImageFont.truetype(fpath, 22)
        font_badge = ImageFont.truetype(fpath, 20)
        break

if not font_title:
    font_title = ImageFont.load_default()
    font_desc = font_title
    font_badge = font_title

# -------------------------------------------------------------
# 1. Annotate Step 1: Enable Developer Options
# -------------------------------------------------------------
p1 = os.path.join(img_dir, "raw_1_about.png")
if os.path.exists(p1):
    im1 = Image.open(p1).convert("RGBA")
    overlay1 = Image.new("RGBA", im1.size, (0, 0, 0, 0))
    d1 = ImageDraw.Draw(overlay1)

    # Coordinates for Build row in 1920x1080
    # In raw_1_about.png, the right sidebar width is roughly 1200 to 1920
    # The Build row is around y: 900 to 1020
    box_build = [1200, 890, 1900, 1030]
    d1.rounded_rectangle(box_build, radius=12, outline=(0, 229, 255, 255), width=6)
    
    # Model row box
    box_model = [1200, 360, 1900, 480]
    d1.rounded_rectangle(box_model, radius=12, outline=(255, 171, 0, 255), width=4)

    # Callout banner at left
    callout_rect = [100, 780, 1050, 960]
    d1.rounded_rectangle(callout_rect, radius=16, fill=(18, 24, 38, 230), outline=(0, 229, 255, 255), width=3)
    d1.text((130, 805), "BƯỚC 1: BẬT TÙY CHỌN NHÀ PHÁT TRIỂN", fill=(0, 229, 255, 255), font=font_title)
    d1.text((130, 860), "• Dùng remote di chuyển xuống mục Build (hoặc Model)", fill=(255, 255, 255, 255), font=font_desc)
    d1.text((130, 900), "• Nhấn phím OK liên tục 5 đến 7 lần để kích hoạt Developer Mode", fill=(255, 235, 59, 255), font=font_desc)

    # Pointer line from callout to Build box
    d1.line([(1050, 870), (1190, 940)], fill=(0, 229, 255, 255), width=6)
    d1.ellipse([(1185, 935), (1205, 955)], fill=(0, 229, 255, 255))

    out1 = Image.alpha_composite(im1, overlay1).convert("RGB")
    out1_path = os.path.join(img_dir, "step1_enable_developer_options.png")
    out1.save(out1_path, quality=95)
    print("Saved:", out1_path)

# -------------------------------------------------------------
# 2. Annotate Step 2: Enable USB Debugging
# -------------------------------------------------------------
p2 = os.path.join(img_dir, "raw_2_usb_debugging.png")
if os.path.exists(p2):
    im2 = Image.open(p2).convert("RGBA")
    overlay2 = Image.new("RGBA", im2.size, (0, 0, 0, 0))
    d2 = ImageDraw.Draw(overlay2)

    # USB debugging row is around y: 550 to 680, x: 1200 to 1900
    box_usb = [1200, 560, 1900, 680]
    d2.rounded_rectangle(box_usb, radius=12, outline=(61, 220, 132, 255), width=6)

    # Callout banner
    callout_rect2 = [100, 480, 1050, 660]
    d2.rounded_rectangle(callout_rect2, radius=16, fill=(18, 24, 38, 230), outline=(61, 220, 132, 255), width=3)
    d2.text((130, 505), "BƯỚC 2: BẬT GỠ LỖI USB (ADB DEBUGGING)", fill=(61, 220, 132, 255), font=font_title)
    d2.text((130, 560), "• Vào Developer options -> Tìm mục USB debugging", fill=(255, 255, 255, 255), font=font_desc)
    d2.text((130, 600), "• Gạt công tắc sang trạng thái BẬT (ON) màu xanh", fill=(255, 235, 59, 255), font=font_desc)

    # Pointer line
    d2.line([(1050, 570), (1190, 620)], fill=(61, 220, 132, 255), width=6)
    d2.ellipse([(1185, 615), (1205, 635)], fill=(61, 220, 132, 255))

    out2 = Image.alpha_composite(im2, overlay2).convert("RGB")
    out2_path = os.path.join(img_dir, "step2_enable_usb_debugging.png")
    out2.save(out2_path, quality=95)
    print("Saved:", out2_path)

# -------------------------------------------------------------
# 3. Annotate Step 3: Projectivy Launcher Screen & Apps
# -------------------------------------------------------------
p3 = os.path.join(img_dir, "raw_3_home.png")
if os.path.exists(p3):
    im3 = Image.open(p3).convert("RGBA")
    overlay3 = Image.new("RGBA", im3.size, (0, 0, 0, 0))
    d3 = ImageDraw.Draw(overlay3)

    # Highlight apps rows
    box_apps = [60, 510, 1860, 890]
    d3.rounded_rectangle(box_apps, radius=20, outline=(0, 229, 255, 255), width=5)

    # Highlight settings button top-right (x: 1380 to 1880, y: 50 to 140)
    box_settings = [1370, 55, 1880, 145]
    d3.rounded_rectangle(box_settings, radius=12, outline=(255, 171, 0, 255), width=4)

    # Top banner callout
    top_rect = [60, 50, 1080, 210]
    d3.rounded_rectangle(top_rect, radius=16, fill=(18, 24, 38, 230), outline=(0, 229, 255, 255), width=3)
    d3.text((90, 75), "KẾT QUẢ: GIAO DIỆN PROJECTIVY LAUNCHER", fill=(0, 229, 255, 255), font=font_title)
    d3.text((90, 125), "• Khóa phím Home vĩnh viễn, loại bỏ 100% PatchWall tiếng Trung", fill=(255, 255, 255, 255), font=font_desc)
    d3.text((90, 160), "• Tự động cài trọn gói 16 ứng dụng xem truyền hình, YouTube, phim ảnh", fill=(61, 220, 132, 255), font=font_desc)

    # Settings pointer
    d3.text((1370, 160), "Cài đặt hệ thống & Projectivy", fill=(255, 171, 0, 255), font=font_desc)

    out3 = Image.alpha_composite(im3, overlay3).convert("RGB")
    out3_path = os.path.join(img_dir, "step3_projectivy_home_screen.png")
    out3.save(out3_path, quality=95)
    print("Saved:", out3_path)
