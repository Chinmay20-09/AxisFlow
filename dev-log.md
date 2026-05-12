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

[May 12]

✔ Refactored pending from type → transaction state
X Improved chart interaction persistence
X Fixed responsive layout issues

🧠 Insight:
Pending is a status, not a transaction direction.

📌 Next:
chart interaction,UI, remove pending and add net in line chart and add a quick section to either complete/foreit pending transaction(mainly in category)
