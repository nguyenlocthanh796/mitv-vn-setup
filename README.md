# 📺 MiTV Vietnam Toolkit - Cài Tiếng Việt, Xóa PatchWall, Tối Ưu Tivi Xiaomi / Redmi Nội Địa (1-Lệnh ADB)

> **Giải pháp kỹ thuật tự động hoá 100%: Xóa sạch quảng cáo tiếng Trung, cài đặt Projectivy Launcher làm mặc định, khóa phím Home qua Accessibility Service, tăng tốc hoạt ảnh 200% và cài trọn bộ 16 ứng dụng Android TV Việt Nam.**

[![CI Quality Gate](https://github.com/nguyenlocthanh796/mitv-vn-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/nguyenlocthanh796/mitv-vn-setup/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/nguyenlocthanh796/mitv-vn-setup?color=brightgreen)](https://github.com/nguyenlocthanh796/mitv-vn-setup/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Android TV](https://img.shields.io/badge/Platform-Android%20TV-green.svg)]()
[![Device: Xiaomi / Redmi](https://img.shields.io/badge/Device-Xiaomi%20%7C%20Redmi-orange.svg)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/nguyenlocthanh796/mitv-vn-setup/pulls)

*Keywords: cài tiếng việt tivi xiaomi, xóa giao diện patchwall, xóa quảng cáo tivi xiaomi, cài youtube không quảng cáo tivi xiaomi, tối ưu tivi xiaomi nội địa, projectivy launcher xiaomi tv, xiaomi tv debloat, vtv go cho tivi xiaomi.*

---

## 📑 Mục lục
- [🎯 Tại sao cần công cụ này?](#-tại-sao-cần-công-cụ-này)
- [⚡ 2 Cách cài đặt nhanh](#-2-cách-cài-đặt-nhanh)
  - [Cách 1: Chạy Online 1 dòng lệnh (Khuyên dùng)](#cách-1-chạy-online-1-dòng-lệnh-khuyên-dùng)
  - [Cách 2: Tải trọn gói Offline (Dành cho thợ / Cài cắm USB không cần mạng)](#cách-2-tải-trọn-gói-offline-dành-cho-thợ--cài-cắm-usb-không-cần-mạng)
- [📱 Cài đặt bằng Điện thoại (Android & iOS)](#-cài-đặt-bằng-điện-thoại-android--ios)
- [🛠️ Hướng dẫn chuẩn bị Tivi trước khi chạy](#️-hướng-dẫn-chuẩn-bị-tivi-trước-khi-chạy)
- [📦 Danh mục 16 ứng dụng được đóng gói](#-danh-mục-16-ứng-dụng-được-đóng-gói)
- [📺 Các dòng Tivi hỗ trợ (Compatibility)](#-các-dòng-tivi-xiaomi--redmi-được-hỗ-trợ-compatibility)
- [📚 Tài liệu kỹ thuật & Tiêu chuẩn phát triển](#-tài-liệu-kỹ-thuật--tiêu-chuẩn-phát-triển)
- [❓ Câu hỏi thường gặp (FAQ)](#-câu-hỏi-thường-gặp-faq)

---

## 🎯 Tại sao cần công cụ này?

Tivi Xiaomi / Redmi nội địa Trung Quốc rất phổ biến tại Việt Nam vì giá rẻ, cấu hình cao và màn hình lớn. Tuy nhiên:
- Giao diện **PatchWall** tràn ngập tiếng Trung, không có Google Play, người già và trẻ nhỏ không thể dùng được.
- Các giải pháp chạy lại ROM mod tiềm ẩn nguy cơ **treo logo (brick)**, mất bảo hành và mất tính năng cập nhật OTA.

**MiTV Vietnam Toolkit** giải quyết triệt để vấn đề này chỉ với **1 dòng lệnh qua ADB**:
- ✅ **An toàn tuyệt đối 100%**: Không can thiệp phân vùng hệ thống, không unlock bootloader, không mất bảo hành ([Xem Security Policy](SECURITY.md)).
- ✅ **Giao diện Projectivy siêu mượt**: Khóa phím Home vĩnh viễn (Accessibility Override), không bao giờ bị nhảy lại PatchWall.
- ✅ **Tăng tốc phản hồi 200%**: Ép tỉ lệ hoạt ảnh hệ thống về `0.5x`, bấm remote nhạy tức thì.
- ✅ **Trọn bộ 16 app chuẩn Android TV**: Tự động cài trọn bộ xem phim, truyền hình, bóng đá, âm nhạc và tiện ích.
- ✅ **Hỗ trợ cả Online & Offline**: Chạy online qua 1 dòng lệnh hoặc tải trọn gói Offline (520MB) cắm USB không cần mạng.

---

## ⚡ 2 Cách cài đặt nhanh

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

## 📱 Cài đặt bằng Điện thoại (Android & iOS)

Nếu bạn không có máy tính, bạn hoàn toàn có thể dùng **Điện thoại Android** (Termux / Bugjaeger) hoặc **iPhone/iPad** (iSH Shell) để chạy lệnh cài đặt trực tiếp qua Wi-Fi.

👉 **[Xem tài liệu hướng dẫn chi tiết từng bước cho Android & iPhone tại đây (docs/GUIDE-MOBILE.md)](docs/GUIDE-MOBILE.md)**

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

## 📺 Các dòng Tivi Xiaomi & Redmi được hỗ trợ (Compatibility)

Công cụ hỗ trợ **100% các dòng Tivi Xiaomi, Redmi và Mi Box nội địa Trung Quốc** chạy Android 7.0 đến Android 13+:

| Dòng sản phẩm | Các Model hỗ trợ chi tiết |
| :--- | :--- |
| **Xiaomi TV EA Series** | EA32, EA40, EA43, EA50, EA55, EA65, EA70, EA75 (Đời 2022, 2023, 2024, 2025) |
| **Xiaomi TV A / A Pro Series** | A32, A43, A50, A55, A65, A70, A75, A85 (Bản nội địa & quốc tế) |
| **Redmi TV Series** | Redmi X50, X55, X65, X75, X85, XT Series |
| **Redmi MAX Màn hình lớn** | Redmi MAX 85 inch, MAX 86 inch, MAX 98 inch, MAX 100 inch |
| **Xiaomi TV S / Master Series** | S55, S65, S75, S85 (144Hz), Mi TV Master OLED |
| **Mi TV Series cũ & Box** | Mi TV 4A, 4C, 4S, 4X, Mi TV 5 / 5 Pro, Mi Box 3, Mi Box 4, Mi Box 4S Pro |

---

## 📚 Tài liệu kỹ thuật & Tiêu chuẩn phát triển

Dự án được xây dựng theo chuẩn mã nguồn mở chuyên nghiệp:
* 🏛️ **[Kiến trúc hệ thống & Cơ chế can thiệp ADB (Architecture)](docs/ARCHITECTURE.md)**: Chi tiết luồng hoạt động, state machine và cơ chế Accessibility Service.
* 🛠️ **[Cẩm nang xử lý sự cố (Troubleshooting Guide)](docs/TROUBLESHOOTING.md)**: Bảng mã lỗi ADB, hiện tượng mất kết nối Wi-Fi và cách xử lý.
* 📱 **[Hướng dẫn cài bằng Điện thoại (Mobile Guide)](docs/GUIDE-MOBILE.md)**: Hướng dẫn chi tiết cho Android (Termux/Bugjaeger) và iPhone (iSH).
* 🔒 **[Chính sách an toàn & Bảo mật (Security Policy)](SECURITY.md)**: Cam kết không can thiệp kernel, không thu thập dữ liệu người dùng.
* 🤝 **[Quy chuẩn đóng góp mã nguồn (Contributing Guide)](CONTRIBUTING.md)**: Hướng dẫn thêm ứng dụng vào `apps.json` và quy chuẩn code.
* 📝 **[Nhật ký phiên bản (Changelog)](CHANGELOG.md)**: Lịch sử phát triển và nâng cấp tính năng theo SemVer.

---

## ❓ Câu hỏi thường gặp (FAQ)

<details>
<summary><b>1. Bấm phím Home có bị văng về giao diện tiếng Trung PatchWall không?</b></summary>
<b>Hoàn toàn không.</b> Script tự động kích hoạt <code>Projectivy Accessibility Service</code>. Khi bạn bấm phím Home trên điều khiển, hệ thống sẽ ưu tiên giữ nguyên giao diện Projectivy Launcher, chặn hoàn toàn việc chuyển về PatchWall.
</details>

<details>
<summary><b>2. Tivi không có Google Play (CH Play) thì cài và cập nhật app thế nào?</b></summary>
Script đã tích hợp sẵn cơ chế cài đặt APK chính thống qua ADB. Ngoài ra, tivi đã được cài sẵn app <b>Send Files to TV</b> và trình duyệt <b>TV Bro</b> để bạn tự tải và cài thêm file APK bất kỳ trực tiếp từ điện thoại hoặc internet về sau.
</details>

<details>
<summary><b>3. Tivi có bị mất bảo hành hay treo logo (brick) không?</b></summary>
<b>An toàn 100%.</b> Công cụ chỉ gửi các lệnh cài ứng dụng và tinh chỉnh hoạt ảnh qua giao thức ADB chính thống của Google. Không can thiệp phân vùng hệ thống, không chỉnh sửa Kernel, không Unlock Bootloader, tivi vẫn nhận cập nhật OTA từ Xiaomi bình thường.
</details>

<details>
<summary><b>4. Tìm kiếm giọng nói tiếng Việt trên remote có hoạt động không?</b></summary>
Có. Các ứng dụng như <b>SmartTube</b> và <b>YouTube TV</b> đều tích hợp sẵn bộ nhận diện giọng nói tiếng Việt qua micro trên điều khiển tivi.
</details>

<details>
<summary><b>5. Muốn khôi phục lại như lúc mới mua thì làm sao?</b></summary>
Bạn chỉ cần vào <code>Cài đặt</code> của TV và chọn <code>Khôi phục cài đặt gốc (Factory Reset)</code> là tivi sẽ xóa toàn bộ app và trở về nguyên trạng xuất xưởng.
</details>

---

## 🤝 Đóng góp & Bản quyền

Dự án phát triển hoàn toàn vì mục đích phi thương mại hỗ trợ cộng đồng người dùng Xiaomi tại Việt Nam. Mọi đóng góp (Pull Request / Issue) đều được chào đón!

Phát hành theo giấy phép [MIT License](LICENSE).
