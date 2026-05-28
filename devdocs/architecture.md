# AxisFlow Architecture

## Philosophy
Keep architecture lightweight, modular, and maintainable.

Avoid overengineering.

---

## Folder Structure

lib/
 ├── core/
 ├── controller/
 ├── data/
 ├── ui/

---

## Rules

- Screens compose widgets only
- Avoid business logic inside UI
- Reusable widgets go into widgets/
- Use centralized theme tokens
- Avoid hardcoded styles