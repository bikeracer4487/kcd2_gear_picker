# Helmet-Off Dialog - Development Notes

This file is for modders or tech folks interested in the behind-the-scenes stuff.

---

### Development Setup

Use WSL & Docker. Check the Makefile for details.

---

### Prototype Scope

- Targets helmets with the keyword "kettle" and coifs with the keyword "coif."
- Workaround used since KCD 2 lacks functions like `inventory.GetEquippedSlots` or flags like `E_IF_IsEquipped`.

---