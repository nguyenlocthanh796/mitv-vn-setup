# 📺 MiTV Vietnam Toolkit - 1-Click ADB Setup

> **Bộ công cụ 1-lệnh ADB tự động tối ưu hóa, chặn quảng cáo PatchWall và cài đặt trọn bộ ứng dụng truyền hình/giải trí Việt Nam cho Tivi Xiaomi nội địa.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Android TV](https://img.shields.io/badge/Platform-Android%20TV-green.svg)]()
[![Device: Xiaomi / Redmi](https://img.shields.io/badge/Device-Xiaomi%20%7C%20Redmi-orange.svg)]()

---

## 🎯 Tại sao dự án này ra đời?

Tivi Xiaomi / Redmi nội địa Trung Quốc rất phổ biến tại Việt Nam vì giá rẻ, cấu hình cao và màn hình lớn. Tuy nhiên:
- Giao diện **PatchWall** tràn ngập tiếng Trung, không có Google Play, người già và trẻ nhỏ không thể dùng được.
- Các giải pháp chạy lại ROM mod tiềm ẩn nguy cơ **treo logo (brick)**, mất bảo hành và mất tính năng cập nhật OTA.

**MiTV Vietnam Toolkit** giải quyết triệt để vấn đề này chỉ với **1 dòng lệnh qua ADB**:
- ✅ **An toàn tuyệt đối 100%**: Không can thiệp phân vùng hệ thống, không unlock bootloader, không mất bảo hành.
- ✅ **Giao diện Projectivy siêu mượt**: Khóa phím Home vĩnh viễn (Accessibility Override), không bao giờ bị nhảy lại PatchWall.
- ✅ **Tăng tốc phản hồi 200%**: Ép tỉ lệ hoạt ảnh hệ thống về `0.5x`, bấm remote nhạy tức thì.
- ✅ **Trọn bộ app chuẩn Android TV**: Tự động cài VTV Go, TV360, YouTube TV, SmartTube, Spotify, Send Files to TV, TV Bro.

---

## ⚡ Cài đặt nhanh bằng 1 dòng lệnh

### Cách 1: Chạy trực tiếp qua Windows PowerShell (Khuyên dùng)
Mở **PowerShell** trên máy tính (cùng mạng Wi-Fi với TV) và dán dòng lệnh sau:

```powershell
irm https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/setup.ps1 | iex
```

### Cách 2: Tải file chạy ngay (Dành cho người không rành kỹ thuật)
1. Bấm vào nút **Code** -> **Download ZIP** (hoặc tải từ mục Releases).
2. Giải nén thư mục vừa tải.
3. Click đúp vào file `setup.bat`.

### Cách 3: Dành cho macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/setup.sh | bash
```

---

## 🛠️ Hướng dẫn chuẩn bị Tivi trước khi chạy

Để máy tính kết nối được với Tivi, bạn cần bật **ADB Debugging (Gỡ lỗi USB)** trên Tivi:

### 1. Bật Tùy chọn nhà phát triển (Developer Options)
- **Tiếng Trung**: Cài đặt (`设置`) ➔ Cài đặt thiết bị (`关于` hoặc `图像与声音`) ➔ Kiểu máy (`型号`) ➔ Bấm nút **OK** trên điều khiển **5 đến 7 lần liên tục** cho đến khi hiện thông báo đã là nhà phát triển.
- **Tiếng Anh**: `Settings` ➔ `Device Preferences` ➔ `About` ➔ Bấm phím **OK** 5 lần vào dòng `Build`.

### 2. Bật Gỡ lỗi ADB (ADB Debugging)
- **Tiếng Trung**: Vào `账号与安全` (Tài khoản & Bảo mật) ➔ `ADB调试` (ADB Debugging) ➔ Chọn **开启 (Cho phép)**.
- **Tiếng Anh**: Vào `Developer Options` ➔ Bật `USB Debugging` (hoặc `ADB Debugging`).

### 3. Lấy địa chỉ IP của Tivi
- Vào `Cài đặt mạng` (Wi-Fi) trên Tivi ➔ Chọn mạng đang kết nối ➔ Xem địa chỉ IP (Ví dụ: `192.168.1.50`).

---

## 📦 Danh mục ứng dụng được cài đặt tự động

| Ứng dụng | Mục đích sử dụng | Nguồn |
| :--- | :--- | :--- |
| **Projectivy Launcher** | Giao diện Android TV sạch, nhẹ, chặn PatchWall | [GitHub spocky](https://github.com/spocky/miproja1) |
| **SmartTube** | Xem YouTube không quảng cáo, chặn tài trợ | [GitHub yuliskov](https://github.com/yuliskov/SmartTube) |
| **VTV Go TV** | Xem truyền hình thời sự quốc gia VTV1–VTV9 | VTV Digital Center |
| **TV360 Smart TV** | Kênh truyền hình trong nước & bóng đá Viettel | Viettel Telecom |
| **YouTube TV** | Ứng dụng YouTube chuẩn Google cho TV | Google LLC |
| **Spotify TV** | Nghe nhạc bản quyền, đồng bộ điện thoại | Spotify AB |
| **Send Files to TV** | Bắn file, ảnh, APK từ điện thoại sang TV | Yablio |
| **TV Bro** | Trình duyệt web remote, chặn quảng cáo | [GitHub truefedex](https://github.com/truefedex/tv-bro) |

---

## ❓ Câu hỏi thường gặp (FAQ)

<details>
<summary><b>1. Bấm phím Home có bị văng về giao diện tiếng Trung không?</b></summary>
Không. Script tự động cấp quyền <code>Accessibility Service</code> cho Projectivy Launcher. Bất cứ khi nào phím Home được nhấn, hệ thống sẽ ưu tiên giữ nguyên giao diện Projectivy Launcher.
</details>

<details>
<summary><b>2. Tivi có bị mất bảo hành hay treo logo không?</b></summary>
Hoàn toàn không. Công cụ chỉ sử dụng các lệnh cấp quyền và cài đặt APK chính thống qua ADB của Google, không sửa đổi Kernel hay Bootloader.
</details>

<details>
<summary><b>3. Muốn khôi phục lại như cũ thì làm sao?</b></summary>
Bạn chỉ cần vào <code>Cài đặt</code> của TV và chọn <code>Khôi phục cài đặt gốc (Factory Reset)</code> là tivi sẽ trở về nguyên trạng ban đầu.
</details>

---

## 🤝 Đóng góp & Bản quyền

Dự án phát triển hoàn toàn vì mục đích phi thương mại hỗ trợ cộng đồng người dùng Xiaomi tại Việt Nam.

Phát hành theo giấy phép [MIT License](LICENSE).
