# Play Store listing copy

Character limits are Google's. Paste straight into Play Console.

---

## App name (30 max)

```
Luxury Finance
```

## Short description — ไทย (80 max)

```
บันทึกรายจ่ายใน 5 วินาที รู้ทันทีว่าเงินเดือนนี้หายไปกับอะไร
```
*58 characters.*

## Full description — ไทย (4000 max)

```
เงินเดือนออกแล้วหายไปไหนหมด? Luxury Finance ช่วยให้คุณเห็นคำตอบภายในหน้าจอเดียว

บันทึกเร็วจนไม่ขี้เกียจทำ
เลือกหมวดหมู่ ใส่จำนวนเงิน กดบันทึก จบใน 5 วินาที มีปุ่มลัด +20 +50 +100 +500 สำหรับรายการที่ซื้อบ่อย และเลือกวันนี้/เมื่อวานได้ในปุ่มเดียว

เห็นภาพรวมทันทีที่เปิดแอป
• เงินเหลือใช้เดือนนี้ พร้อมเปรียบเทียบกับเดือนก่อน
• กราฟรายจ่ายรายวัน รู้ว่าวันไหนใช้หนักที่สุด
• สัดส่วนแต่ละหมวดหมู่แบบโดนัทชาร์ต
• คะแนนสุขภาพการเงิน 0-100 คำนวณจากอัตราการออมและสัดส่วนของที่จำเป็น

แยก "จำเป็น" กับ "อยากได้เฉยๆ"
ทุกรายการระบุได้ว่าจำเป็นแค่ไหน แอปจะสรุปให้เห็นชัดๆ ว่าเดือนนี้เงินหายไปกับของที่ไม่จำเป็นเท่าไหร่ พร้อมข้อแนะนำจากข้อมูลจริงของคุณ เช่น ซื้อกาแฟไปกี่ครั้ง ลดได้เท่าไหร่

ตั้งเป้าหมายการออม
เก็บเงินซื้อรถ เที่ยวญี่ปุ่น หรือเงินสำรองฉุกเฉิน ตั้งเป้าหมายพร้อมกำหนดเวลา แล้วเติมเงินเข้าเป้าหมายได้ทุกเมื่อ เห็นความคืบหน้าเป็นเปอร์เซ็นต์

สรุปรายเดือน
ดูว่าเดือนนี้ทำอะไรได้ดี และอะไรที่ควรปรับปรุง ย้อนดูเดือนก่อนหน้าได้ทั้งหมด

ออกแบบมาให้ใช้สบายตา
รองรับทั้งโหมดสว่างและโหมดมืด ปรับตามระบบอัตโนมัติ

ข้อมูลของคุณอยู่ในเครื่องคุณ
ไม่ต้องสมัครสมาชิก ไม่ต้องต่ออินเทอร์เน็ต ไม่มีโฆษณา ไม่มีการเก็บหรือส่งข้อมูลออกจากเครื่องแม้แต่รายการเดียว ลบข้อมูลทั้งหมดได้ด้วยตัวเองทุกเมื่อในหน้าตั้งค่า

เริ่มต้นฟรี ไม่มีค่าใช้จ่ายแอบแฝง
```

## Short description — English (80 max)

```
Track every baht in 5 seconds and see exactly where your month went.
```
*67 characters.*

## Full description — English (4000 max)

```
Where does your salary actually go? Luxury Finance answers that on one screen.

LOGGING IS FAST ENOUGH THAT YOU'LL ACTUALLY DO IT
Pick a category, type the amount, save. Quick-add buttons (+20 +50 +100 +500) and one-tap Today/Yesterday mean most entries take five seconds.

SEE THE WHOLE MONTH AT A GLANCE
• Money left this month, compared against last month
• A daily spending chart that shows which days hurt
• A donut breakdown by category
• A 0-100 financial health score built from your savings rate and how much of your spending was necessary

SEPARATE "NEEDED IT" FROM "JUST WANTED IT"
Every expense is tagged by how necessary it was, so the app can show you exactly how much went on things you didn't need — plus specific suggestions drawn from your own data, like how many coffees you bought and what cutting back would save.

SAVINGS GOALS
A car, a trip to Japan, an emergency fund. Set a target and a deadline, add money whenever you like, watch the percentage climb.

MONTHLY REVIEW
What went well, what to improve, and full history for every previous month.

EASY ON THE EYES
Full light and dark themes that follow your system setting.

YOUR DATA STAYS ON YOUR PHONE
No account. No internet connection needed. No ads. Nothing is collected, uploaded or shared — ever. Wipe everything yourself from Settings at any time.

Free, with nothing hidden.
```

---

## Content rating questionnaire

| Question | Answer |
| --- | --- |
| Category | Finance / Utility |
| Violence, sexual content, profanity, drugs | None |
| User-generated content or sharing | No |
| Does the app let users interact? | No |
| Shares location | No |
| Digital purchases | No |
| Expected rating | Everyone / PEGI 3 |

## Store settings

- **Category:** Finance
- **Tags:** budgeting, expense tracker, personal finance
- **Contains ads:** No
- **In-app purchases:** No
- **Target audience:** 18+ (personal finance), no children's category
- **Countries:** Thailand first; the UI is Thai throughout

## Graphic assets

| Asset | Spec | File |
| --- | --- | --- |
| App icon | 512×512 PNG, no alpha | `play_store_icon_512.png` |
| Feature graphic | 1024×500 PNG/JPG | `feature_graphic_1024x500.png` |
| Phone screenshots | 2–8, min 320px, 9:16 | `screenshots/` |

Screenshots in `screenshots/` were captured from the running app with the
sample data loaded, so they show realistic numbers without exposing anyone's
real spending. They are 375x812, which clears Play's 320px minimum but is on
the small side — for a crisper listing, retake them on a real phone or an
emulator at 1080x2400:

```bash
flutter run --release
adb exec-out screencap -p > store/screenshots/1-dashboard.png
```

Load the sample data first (Settings -> โหลดข้อมูลตัวอย่างใหม่) so the numbers
look lived-in.
