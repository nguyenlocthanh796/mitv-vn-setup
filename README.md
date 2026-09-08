# MiTV Vietnam Toolkit

### Bộ công cụ 1-Click ADB tối ưu hóa & cài đặt giao diện Android TV cho Tivi Xiaomi / Redmi nội địa

[![CI Quality Gate](https://img.shields.io/github/actions/workflow/status/nguyenlocthanh796/mitv-vn-setup/ci.yml?branch=main&style=flat-square&logo=githubactions&logoColor=white&label=CI)](https://github.com/nguyenlocthanh796/mitv-vn-setup/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/nguyenlocthanh796/mitv-vn-setup?style=flat-square&color=3DDC84&logo=github&logoColor=white&label=Release)](https://github.com/nguyenlocthanh796/mitv-vn-setup/releases)
[![Platform: Android TV](https://img.shields.io/badge/Platform-Android%20TV-3DDC84?style=flat-square&logo=android&logoColor=white)](https://android.com/tv/)
[![Hardware: Xiaomi | Redmi](https://img.shields.io/badge/Hardware-Xiaomi%20%7C%20Redmi-FF6900?style=flat-square&logo=xiaomi&logoColor=white)](https://mi.com)
[![Shell: PowerShell](https://img.shields.io/badge/Shell-PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white)](setup.ps1)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)](setup.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square&logo=open-source-initiative&logoColor=white)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg?style=flat-square&logo=git&logoColor=white)](https://github.com/nguyenlocthanh796/mitv-vn-setup/pulls)

> [!IMPORTANT]
> **Giải pháp kỹ thuật tự động hoá 100% qua Android Debug Bridge (ADB):** Loại bỏ quảng cáo PatchWall tiếng Trung, thiết lập Projectivy Launcher làm màn hình chính vĩnh viễn qua Accessibility Service, giảm độ trễ hoạt ảnh hệ thống về `0.5x` và cài đặt trọn gói 16 ứng dụng truyền hình & giải trí thuần Việt.

*Keywords: cài tiếng việt tivi xiaomi, xóa giao diện patchwall, xóa quảng cáo tivi xiaomi, cài youtube không quảng cáo tivi xiaomi, tối ưu tivi xiaomi nội địa, projectivy launcher xiaomi tv, xiaomi tv debloat, vtv go cho tivi xiaomi.*

---

## Mục lục

- [1. Động lực phát triển & Giải pháp kỹ thuật](#1-động-lực-phát-triển--giải-pháp-kỹ-thuật)
- [2. Hướng dẫn cài đặt nhanh](#2-hướng-dẫn-cài-đặt-nhanh)
  - [2.1. Chạy trực tuyến (Online 1-Line Execution)](#21-chạy-trực-tuyến-online-1-line-execution)
  - [2.2. Chạy độc lập không cần mạng (Offline Release Package)](#22-chạy-độc-lập-không-cần-mạng-offline-release-package)
- [3. Cài đặt bằng thiết bị di động (Android & iOS)](#3-cài-đặt-bằng-thiết-bị-di-động-android--ios)
- [4. Kích hoạt giao thức ADB trên Tivi](#4-kích-hoạt-giao-thức-adb-trên-tivi)
- [5. Danh mục 16 ứng dụng tích hợp (Leanback UI)](#5-danh-mục-16-ứng-dụng-tích-hợp-leanback-ui)
- [6. Ma trận tương thích phần cứng](#6-ma-trận-tương-thích-phần-cứng)
- [7. Bộ tài liệu kỹ thuật & Tiêu chuẩn phát triển](#7-bộ-tài-liệu-kỹ-thuật--tiêu-chuẩn-phát-triển)
- [8. Các câu hỏi thường gặp (FAQ)](#8-các-câu-hỏi-thường-gặp-faq)
- [9. Giấy phép & Tác quyền](#9-giấy-phép--tác-quyền)

---

## 1. Động lực phát triển & Giải pháp kỹ thuật

Tivi Xiaomi và Redmi nội địa Trung Quốc có thị phần lớn nhờ cấu hình phần cứng tối ưu trên giá thành. Tuy nhiên, rào cản phần mềm gây khó khăn cho người dùng gia đình:
* Giao diện mặc định **PatchWall** chứa nhiều quảng cáo tiếng Trung, không tích hợp Google Services.
* Can thiệp nạp ROM cook qua USB tiềm ẩn rủi ro **brick phần cứng**, mất bảo hành và mất quyền cập nhật OTA.

**MiTV Vietnam Toolkit** giải quyết bài toán trên thông qua tầng giao thức ADB chuẩn của AOSP:
* **Zero Root / Zero Brick**: Chỉ giao tiếp qua cổng ADB Userland, bảo toàn 100% phân vùng hệ thống và chế độ bảo hành nhà sản xuất.
* **Accessibility Interception**: Khóa phím Home phần cứng vào Projectivy Launcher qua `ProjectivyAccessibilityService`, ngăn chặn triệt để PatchWall chiếm quyền hiển thị.
* **Performance Tuning**: Thiết lập `window_animation_scale`, `transition_animation_scale`, `animator_duration_scale` về `0.5x`, phản hồi giao diện tăng 200%.
* **Curated App Ecosystem**: Tự động triển khai 16 ứng dụng Leanback UI điều khiển hoàn hảo qua remote D-pad.

---

## 2. Hướng dẫn cài đặt nhanh

### 2.1. Chạy trực tuyến (Online 1-Line Execution)

Yêu cầu máy tính kết nối cùng mạng Wi-Fi/LAN với Tivi.

* **Windows (PowerShell 5.1 / PowerShell 7+)**:
  ```powershell
  irm https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/setup.ps1 | iex
  ```

* **macOS / Linux**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/nguyenlocthanh796/mitv-vn-setup/main/setup.sh | bash
  ```

---

### 2.2. Chạy độc lập không cần mạng (Offline Release Package)

Thích hợp cho kỹ thuật viên hoặc khu vực mạng Wi-Fi nội bộ tốc độ quốc tế hạn chế:

1. Tải bản đóng gói độc lập tại mục **[Releases](https://github.com/nguyenlocthanh796/mitv-vn-setup/releases)** (`MiTV-Vietnam-Full-Offline-v1.0.0.zip` - 520MB).
2. Giải nén trên máy tính hoặc USB.
3. Chạy file `setup.bat` ➔ Nhập IP Tivi ➔ Quá trình cài đặt diễn ra tự động nội bộ trong 60 giây.

---

## 3. Cài đặt bằng thiết bị di động (Android & iOS)

Không bắt buộc sử dụng máy tính. Bộ script hỗ trợ thực thi trực tiếp từ điện thoại thông minh:

* **Android**: Thực thi qua **Termux** (CLI native) hoặc nạp APK trực tiếp qua giao diện **Bugjaeger**.
* **iPhone / iPad**: Thực thi qua môi trường Linux giả lập **iSH Shell** (Alpine Linux).

> [!TIP]
> Chi tiết từng câu lệnh và thao tác cấp quyền trên điện thoại được mô tả tại tài liệu chuyên sâu:  
> ➔ **[Hướng dẫn cài đặt từ thiết bị di động (docs/GUIDE-MOBILE.md)](docs/GUIDE-MOBILE.md)**

---

## 4. Kích hoạt giao thức ADB trên Tivi

### Bước 1: Mở tùy chọn nhà phát triển (Developer Options)
* **Giao diện tiếng Trung**: `设置` (Cài đặt) ➔ `关于` (Giới thiệu) ➔ `型号` (Model) ➔ Nhấn phím **OK** trên remote **5 đến 7 lần liên tục** cho đến khi hệ thống báo mở quyền nhà phát triển.
* **Giao diện tiếng Anh**: `Settings` ➔ `Device Preferences` ➔ `About` ➔ Nhấn phím **OK** 5 lần vào dòng `Build` (hoặc `Model`).

![Bật Tùy chọn nhà phát triển trên Tivi Xiaomi](docs/images/step1_enable_developer_options.png)

### Bước 2: Cho phép gỡ lỗi ADB (ADB Debugging)
* **Giao diện tiếng Trung**: `账号与安全` (Tài khoản & Bảo mật) ➔ `ADB调试` (ADB Debugging) ➔ Chọn **开启 (Bật)**.
* **Giao diện tiếng Anh**: `Developer Options` ➔ Chuyển `USB Debugging` (hoặc `ADB Debugging`) sang **ON**.

![Bật Gỡ lỗi USB Debugging trên Tivi Xiaomi](docs/images/step2_enable_usb_debugging.png)

### Bước 3: Xác định địa chỉ IP nội mạng của Tivi
* Vào mục `Network / Wi-Fi` trên Tivi ➔ Chọn mạng đang kết nối ➔ Ghi nhận địa chỉ IP (Ví dụ: `192.168.1.50`).

---

## 5. Danh mục 16 ứng dụng tích hợp (Leanback UI)

![Giao diện Projectivy Launcher và 16 ứng dụng sau khi tối ưu](docs/images/step3_projectivy_home_screen.png)

Tất cả các gói phần mềm đều được kiểm định tương thích hoàn toàn với điều khiển cầm tay:

| Phân nhóm | Ứng dụng | Gói định danh (Package ID) | Mô tả chức năng |
| :--- | :--- | :--- | :--- |
| **Giao diện** | Projectivy Launcher | `com.spocky.projhost` | Launcher tùy biến cao, khóa phím Home, chặn PatchWall |
| **Truyền hình** | VTV Go TV | `vn.vtv.vtvgo` | Kênh truyền hình quốc gia trực tiếp chất lượng cao |
| | TV360 Smart TV | `com.viettel.tv360.tv` | Truyền hình giải trí, bóng đá Ngoại Hạng Anh, phim truyện |
| | FPT Play TV | `com.fptplay.atv` | Kênh thể thao bản quyền Cúp C1, V-League, HBO Go |
| | VieON TV | `com.vieon.tv` | Phim truyền hình, show thực tế, kênh truyền hình HD |
| | OTT Navigator | `studio.scillarium.ottnavigator` | Trình phát danh sách IPTV mượt mà, hỗ trợ EPG |
| **Video & Cinema**| YouTube for TV | `com.google.android.youtube.tv` | Bản YouTube Android TV chính thức |
| | SmartTube | `org.smarttube.stable` | YouTube TV không quảng cáo, tích hợp SponsorBlock |
| | Cloudstream | `com.lagradost.cloudstream3` | Kho phim điện ảnh, series, anime đa nguồn miễn phí |
| | Stremio TV | `com.stremio.one` | Trình xem phim chuẩn 4K HDR qua giao thức torrent/addons |
| | VLC for Android | `org.videolan.vlc` | Trình phát đa phương tiện từ USB hoặc mạng nội bộ SMB |
| **Thể thao** | SportzX Live | `com.sportzx.tv` | Trực tiếp các giải đấu thể thao quốc tế |
| **Âm nhạc** | Spotify TV | `com.spotify.tv.android` | Nền tảng nghe nhạc trực tuyến, điều khiển từ xa qua Connect |
| **Tiện ích hệ thống**| Send Files to TV | `com.yablio.sendfilestotv` | Truyền tệp tin, ảnh, APK từ điện thoại sang TV qua Wi-Fi |
| | TV Bro | `com.phlox.tvwebbrowser` | Trình duyệt web remote có sẵn chặn quảng cáo web |
| | RS File Manager | `com.rs.transfer.files` | Trình quản lý tập tin, giải nén zip trực tiếp |
| | Speedtest TV | `com.ookla.telematics` | Đo lường băng thông mạng internet của tivi |

---

## 6. Ma trận tương thích phần cứng

Hỗ trợ 100% các dòng Tivi Xiaomi, Redmi và TV Box chạy Android 7.0 (API 24) đến Android 13+:

| Dòng sản phẩm | Các Model hỗ trợ thực tế |
| :--- | :--- |
| **Xiaomi TV EA Series** | EA32, EA40, EA43, EA50, EA55, EA65, EA70, EA75 (Đời 2022–2025) |
| **Xiaomi TV A / A Pro Series** | A32, A43, A50, A55, A65, A70, A75, A85 |
| **Redmi TV Series** | Redmi X50, X55, X65, X75, X85, Redmi Gaming TV XT Series |
| **Redmi MAX Màn hình lớn** | Redmi MAX 85 inch, MAX 86 inch, MAX 98 inch, MAX 100 inch |
| **Xiaomi TV S / Master Series** | S55, S65, S75, S85 (Tần số quét 144Hz), Mi TV Master OLED |
| **Mi TV Series & Android Box** | Mi TV 4A/4C/4S/4X, Mi TV 5 / 5 Pro, Mi Box 3, Mi Box 4, 4S Pro |

---

## 7. Bộ tài liệu kỹ thuật & Tiêu chuẩn phát triển

Dự án tuân thủ nghiêm ngặt chuẩn kiến trúc công nghiệp mở:

* [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — Đặc tả kiến trúc hệ thống, state machine và cơ chế Accessibility Bypass.
* [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) — Bảng mã lỗi ADB, hiện tượng mất kết nối TCP:5555 và phương án xử lý.
* [docs/GUIDE-MOBILE.md](docs/GUIDE-MOBILE.md) — Cẩm nang thực thi qua Termux (Android) và iSH Shell (iOS).
* [docs/SEO-KEYWORDS.md](docs/SEO-KEYWORDS.md) — Báo cáo nghiên cứu từ khóa và chiến lược phân phối tìm kiếm.
* [SECURITY.md](SECURITY.md) — Chính sách bảo mật AOSP, quyền riêng tư và cam kết Zero Root.
* [CONTRIBUTING.md](CONTRIBUTING.md) — Hướng dẫn đóng góp mã nguồn, kiểm thử giao diện Leanback TV.
* [CHANGELOG.md](CHANGELOG.md) — Lịch sử cập nhật mã nguồn theo chuẩn Semantic Versioning (SemVer).

---

## 8. Các câu hỏi thường gặp (FAQ)

<details>
<summary><b>1. Bấm phím Home trên remote có bị văng về giao diện tiếng Trung PatchWall không?</b></summary>
<b>Không.</b> Script cấu hình dịch vụ <code>ProjectivyAccessibilityService</code> lắng nghe sự kiện phần cứng <code>KEYCODE_HOME</code>. Mỗi khi phím Home được nhấn, dịch vụ sẽ điều hướng tức thời về Projectivy Launcher, chặn đứng Intent của PatchWall.
</details>

<details>
<summary><b>2. Tivi không có Google Play Store thì cập nhật ứng dụng như thế nào?</b></summary>
Thiết bị đã được cài sẵn tiện ích <b>Send Files to TV</b> và trình duyệt <b>TV Bro</b>. Bạn có thể gửi trực tiếp file APK phiên bản mới từ điện thoại hoặc tải trực tiếp từ internet để cập nhật mà không cần CH Play.
</details>

<details>
<summary><b>3. Thiết bị có bị từ chối bảo hành hoặc lỗi bootloop (treo logo) không?</b></summary>
<b>Hoàn toàn an toàn.</b> Toolkit chỉ tương tác qua giao thức ADB ở mức Userland. Không can thiệp phân vùng <code>/system</code>, không can thiệp Bootloader. Thiết bị duy trì nguyên vẹn tính năng cập nhật OTA của nhà sản xuất.
</details>

<details>
<summary><b>4. Tìm kiếm giọng nói tiếng Việt trên remote có hoạt động không?</b></summary>
Có. Các ứng dụng như <b>SmartTube</b> và <b>YouTube for TV</b> đều nhận lệnh giọng nói tiếng Việt trực tiếp thông qua micro của điều khiển từ xa.
</details>

<details>
<summary><b>5. Khôi phục lại trạng thái ban đầu của nhà sản xuất bằng cách nào?</b></summary>
Thực hiện thao tác <code>Khôi phục cài đặt gốc (Factory Reset)</code> trong menu Cài đặt của Tivi. Toàn bộ thiết lập và ứng dụng cài thêm sẽ được xóa sạch, đưa Tivi về trạng thái xuất xưởng nguyên bản.
</details>

---

## 9. Giấy phép & Tác quyền

* **Tác giả & Quản trị dự án**: **Nguyễn Lộc Thành** ([@nguyenlocthanh796](https://github.com/nguyenlocthanh796))
* **Giấy phép mã nguồn**: Phát hành theo chuẩn mã nguồn mở [MIT License](LICENSE).
* Mã nguồn được cung cấp miễn phí nhằm hỗ trợ cộng đồng người dùng Tivi Xiaomi tại Việt Nam. Khi tái phân phối hoặc phát triển tiếp, vui lòng giữ nguyên ghi nhận tác quyền ban đầu.
