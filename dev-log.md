dev-log.md
[May 4]

✔ Fixed:
- Changed name of the app
- Cause: Changed brutely though it ignored the title
- Fix: searched and replace all

🔧 Changed:
- Switched ListTile → custom Row/Column layout
- Reason: needed better alignment control

🧠 Insight:
- Even if i change name there can be chance a line won't budge until locate it manually

[May 5]

✔ Fixed:
- Transaction tile overflow issue
- Cause: Spacer + Flexible conflict
- Fix: moved date below using Column

🔧 Changed:
- Switched ListTile → custom Row/Column layout
- Reason: needed better alignment control

🧠 Insight:
- Layout issues are space problems, not widget problems

📌 Next:
- Add filters (Today/Week/Month)