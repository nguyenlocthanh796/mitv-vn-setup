# 📺 MiTV Vietnam Toolkit - 1-Click ADB Setup

> **Bộ công cụ 1-lệnh ADB tự động tối ưu hóa, chặn quảng cáo PatchWall và cài đặt trọn bộ 16 ứng dụng truyền hình/giải trí Việt Nam cho Tivi Xiaomi nội địa.**

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
- ✅ **Trọn bộ 16 app chuẩn Android TV**: Tự động cài trọn bộ xem phim, truyền hình, bóng đá, âm nhạc và tiện ích.
- ✅ **Hỗ trợ cả Online & Offline**: Chạy online qua 1 dòng lệnh hoặc tải trọn gói Offline (520MB) cắm USB không cần mạng.

---

## ⚡ 2 Cách cài đặt tiện lợi

### Cách 1: Chạy Online 1 dòng lệnh (Khuyên dùng)
Mở **PowerShell** trên máy tính (cùng mạng Wi-Fi với TV) và dán dòng lệnh sau:

```powershell
irm https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/setup.ps1 | iex
```

*Dành cho macOS / Linux:*
```bash
curl -fsSL https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/setup.sh | bash
```

---

### Cách 2: Tải trọn gói Offline (Dành cho thợ / Cài cắm USB không cần mạng)
1. Vào mục **[Releases](https://github.com/nguyenlocthanh796/mitv-vn-setup/releases)** tải file `MiTV-Vietnam-Full-Offline-v1.0.0.zip` (520MB).
2. Giải nén vào máy tính hoặc USB.
3. Click đúp vào file `setup.bat` ➔ Nhập IP Tivi ➔ Tự động cài đặt offline toàn bộ trong 1 phút!

---

## 📱 Dành cho người dùng chỉ có Điện thoại (Không có máy tính)

1. Cài app **Bugjaeger Mobile ADB** từ Google Play Store trên điện thoại Android.
2. Kết nối điện thoại vào cùng mạng Wi-Fi với Tivi.
3. Mở Bugjaeger, bấm nút kết nối góc trên và nhập địa chỉ IP của Tivi (VD: `192.168.1.50:5555`).
4. Chuyển sang tab **Commands** (biểu tượng dấu nhắc lệnh), dán lệnh sau và bấm **Run**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/setup.sh | bash
   ```

---

## 🛠️ Hướng dẫn chuẩn bị Tivi trước khi chạy

Bật **ADB Debugging (Gỡ lỗi USB)** trên Tivi:

### 1. Bật Tùy chọn nhà phát triển (Developer Options)
- **Tiếng Trung**: Cài đặt (`设置`) ➔ Cài đặt thiết bị (`关于` hoặc `图像与声音`) ➔ Kiểu máy (`型号`) ➔ Bấm nút **OK** trên điều khiển **5 đến 7 lần liên tục** cho đến khi hiện thông báo đã là nhà phát triển.
- **Tiếng Anh**: `Settings` ➔ `Device Preferences` ➔ `About` ➔ Bấm phím **OK** 5 lần vào dòng `Build`.

### 2. Bật Gỡ lỗi ADB (ADB Debugging)
- **Tiếng Trung**: Vào `账号与安全` (Tài khoản & Bảo mật) ➔ `ADB调试` (ADB Debugging) ➔ Chọn **开启 (Cho phép)**.
- **Tiếng Anh**: Vào `Developer Options` ➔ Bật `USB Debugging` (hoặc `ADB Debugging`).

### 3. Lấy địa chỉ IP của Tivi
- Vào `Cài đặt mạng` (Wi-Fi) trên Tivi ➔ Chọn mạng đang kết nối ➔ Xem địa chỉ IP (Ví dụ: `192.168.1.50`).

---

## 📦 Danh mục 16 ứng dụng được đóng gói

| Nhóm | Ứng dụng | Mô tả chức năng |
| :--- | :--- | :--- |
| **Giao diện** | **Projectivy Launcher** | Giao diện chuẩn Android TV, chặn vĩnh viễn PatchWall |
| **Truyền hình** | **VTV Go TV** | Xem thời sự & truyền hình quốc gia trực tiếp VTV1–VTV9 |
| | **TV360 Smart TV** | Truyền hình Viettel, phim & trực tiếp bóng đá trong nước |
| | **FPT Play TV** | Kênh truyền hình bản quyền, giải Cúp C1, V-League |
| | **VieON TV** | Show truyền hình thực tế & kho phim Việt/Hoa/Hàn |
| | **OTT Navigator** | Trình phát danh sách kênh IPTV mượt mà chuyên nghiệp |
| **Video & Phim** | **YouTube TV (Gốc)** | Bản YouTube TV chính thức của Google cho Android TV |
| | **SmartTube** | YouTube Android TV không quảng cáo, chặn tài trợ SponsorBlock |
| | **Cloudstream** | Kho phim điện ảnh, anime, series quốc tế miễn phí |
| | **Stremio TV** | Xem phim & series chất lượng 4K qua torrent/addons |
| | **VLC for Android** | Trình phát đa phương tiện từ USB/ổ cứng ngoài |
| **Thể thao** | **SportzX Live** | Kênh trực tiếp thể thao, bóng đá quốc tế |
| **Âm nhạc** | **Spotify TV** | Kho nhạc bản quyền, điều khiển qua điện thoại |
| **Tiện ích** | **Send Files to TV** | Bắn file, ảnh, APK từ điện thoại sang TV qua Wi-Fi |
| | **TV Bro** | Trình duyệt web remote có sẵn chặn quảng cáo |
| | **RS File Manager** | Quản lý bộ nhớ, giải nén zip trực tiếp trên TV |
| | **Speedtest TV** | Đo tốc độ mạng Wi-Fi / LAN của tivi |

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
