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

### TODO

- Release a beta version for community feedback.
- Scrap the prototype afterward and rebuild it with Test-Driven Development (TDD) using Busted on Docker for a solid release. TDD is done for the dialogue event so far.
- Open-source the project on GitHub alongside the NexusMods release to share the equipped-item workaround.
- Since it doesn’t use new KCD 2 APIs, it works with KCD 1 too—needs testing.

---

### Planned Features

- Add an alternate version where the helmet unequips randomly (e.g., off for one dialogue, on for the next). Could refine it to a cycle, like 5 dialogues on, 5 off.
