# Hướng dẫn Lume tiếng Việt và thử Pro trên iPhone (không thanh toán thật)

## Phạm vi
- Nhánh: `feat/vi-localization-pro-test-codemagic`. Nhánh `main` không được chỉnh sửa bởi tính năng này.
- Thêm bản dịch tiếng Việt vào các String Catalog dùng sẵn của Lume và widget, bổ sung `vi` vào các ngôn ngữ hệ thống nhận diện được. Giữ nguyên 9 ngôn ngữ cũ.
- **Ngôn ngữ giao diện** được iOS chọn tự động theo ưu tiên ngôn ngữ của thiết bị / ngôn ngữ ưu tiên riêng cho ứng dụng trong Settings. **Ngôn ngữ âm thanh / phụ đề** trong Lume là tùy chọn độc lập.
- Biên dịch kèm `PRO_TEST` để thử nâng cấp Pro mà không tạo giao dịch Apple. Giữ StoreKit 2 hiện tại nguyên vẹn trong build thương mại.

## Build Codemagic
1. Kết nối repository `kuquan33333/Lume` với Codemagic.
2. Chọn chính xác nhánh `feat/vi-localization-pro-test-codemagic` và dò `codemagic.yaml`.
3. Chọn workflow **iOS Pro Test - Unsigned IPA for Sideloadly** rồi chạy.
4. Workflow tự tải `bilipp/LumeEngine` tại `v0.3.2`, `bilipp/LumeRecorder` tại `v0.1.1` vào hai thư mục ngang hàng với Lume. Các bản này được ghim theo workflow sideload sẵn có của Lume.
5. Xcode build **iPhoneOS** với cấu hình `Sideload`, bật `SIDE_LOAD PRO_TEST`, vô hiệu hóa code signing, rồi đóng gói **`Lume-iOS-ProTest-unsigned.ipa`**.
6. Tải IPA trong phần artifacts của Codemagic.

Không thêm chứng chỉ / provisioning profile hoặc thông tin Apple Developer vào Codemagic. Đây là cách đóng gói IPA **chưa ký**, không phải bản đã ký để đưa trực tiếp lên iPhone.

## Cài đặt bằng Sideloadly trên Windows / macOS
1. Cài Sideloadly trên máy tính; kết nối iPhone bằng cáp (hoặc Wi-Fi nếu đã thiết lập).
2. Chọn `Lume-iOS-ProTest-unsigned.ipa`.
3. Đăng nhập Apple ID trong Sideloadly để Sideloadly **ký lại ứng dụng** và cài đặt. Có thể dùng Apple ID miễn phí; không nhất thiết phải mua Apple Developer Program.
4. Hoàn tất các bước tin cậy nhà phát triển / Developer Mode nếu iPhone yêu cầu.
5. Với Apple ID miễn phí, ứng dụng có thể cần ký lại định kỳ và chịu giới hạn số lượng ứng dụng. Không có cách hợp pháp chung để loại bỏ giới hạn này chỉ bằng đổi cấu hình IPA.

### Thử giao dịch Pro
1. Mở ứng dụng: trạng thái ban đầu là **Free** (trừ khi từng thử Pro trước đây và dữ liệu vẫn còn).
2. Vào **Settings > Lume Pro**, xem danh sách quyền lợi, chọn **Monthly** hoặc **Lifetime**.
3. Hộp thoại **Confirm Test Purchase** xuất hiện; chọn **Unlock Pro (No Charge)**.
4. Ứng dụng ghi quyền Pro **mô phỏng** vào dữ liệu cục bộ và mở khóa tính năng qua `PremiumManager.isPremium`; không gọi `Product.purchase()`, không trừ tiền và không tạo thuê bao thật.
5. Quay lại **Settings > Lume Pro**, dùng **Reset Pro Test to Free** để kiểm thử lại quy trình.
6. **Restore** trong giao diện test chỉ đọc quyền thử nghiệm đã lưu, không gọi đồng bộ hóa giao dịch Apple.

### Những gì chế độ thử nghiệm KHÔNG kiểm chứng
- Không phải kiểm thử StoreKit, cửa sổ xác thực mua hàng thật, gia hạn/hủy thuê bao hay biên lai của App Store.
- Bản Sideload vô hiệu hóa CloudKit theo thiết kế của Lume. Apple ID miễn phí cũng có giới hạn entitlement; các tính năng phụ thuộc iCloud, push hoặc App Groups có thể không hoạt động đầy đủ. Mở Pro **không** vượt qua quyền hệ thống Apple.
- Các tính năng cần máy chủ, API key, nguồn IPTV, kết nối mạng hoặc tài khoản dịch vụ riêng vẫn cần cấu hình tương ứng. Mở khóa Pro không tự tạo những dịch vụ đó.

## Ghi chú build
- Yêu cầu máy macOS trên Codemagic, Xcode tương thích và thời lượng build đủ tải VLCKit / FFmpeg.
- Nếu lỗi Metal: kiểm tra `xcodebuild -downloadComponent MetalToolchain`.
- Nếu lỗi thiếu local package: kiểm tra log clone `../LumeEngine` và `../LumeRecorder/Kit`.
- Nếu thiếu tính năng media tích hợp: kiểm tra các khóa tùy chọn trong `.env.example` (không commit bí mật vào repo).
- Nếu app không cài được sau khi xuất IPA: xem log ký của Sideloadly, entitlement, bundle ID, phiên bản iOS và trạng thái Developer Mode. Không nhầm IPA chưa ký với IPA đã ký.
- Giữ giấy phép AGPL-3.0 và ghi công theo dự án gốc.

## Kiểm tra bản dịch
- Mọi khóa giao diện hiện có ở snapshot catalog đã được dịch theo từng ngữ cảnh, không thay dữ liệu ngôn ngữ cũ.
- Đảm bảo kiểm tra `vi` ở app chính, widget, quyền Mạng cục bộ và màn hình Pro.
- Thử iPhone đặt Tiếng Việt, sau đó đổi ưu tiên ngôn ngữ sang tiếng Anh / ngôn ngữ khác để kiểm tra fallback.
- Test chuỗi động, số ít/nhiều, ngày giờ, các nhãn dài, giao diện landscape và tvOS.
